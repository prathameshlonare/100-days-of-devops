# Day 31 Interview Scenarios: Kubernetes Architecture & Cluster Triage

> **Purpose:** Real-world incident drills and technical interview questions covering Kubernetes control plane internals, worker node mechanics, and Pod lifecycle boundaries. These drills reflect technical interview loops for Cloud Support Associate, Site Reliability Engineer (SRE), and Junior DevOps Engineer roles at cloud consultancies and enterprise infrastructure teams.

---

### Scenario 1: The "Mortal Pod" Production Outage (Bare Pods vs Controllers)

#### The Incident Alert
> **Severity:** P1 (Payment Processing Failure)  
> **Context:** During an automated OS kernel patch rollout on a Kubernetes cluster, a node running an essential payment processing worker was drained (`kubectl drain node-worker-02`). The payment worker immediately terminated and never came back online, causing customer checkout failures.  
> The junior on-call engineer says: *"Kubernetes documentation claims the platform is self-healing. Why didn't Kubernetes automatically restart the payment worker on another healthy node?"*

#### The Interviewer Question
*"Why did Kubernetes fail to recreate the payment worker on another node? Explain the fundamental architectural boundary between container-level self-healing and cluster-level self-healing."*

#### Why the Bottom 80% Candidate Fails
- *The Generic Answer:* "The cluster must have run out of memory, or the scheduler was broken. You should reboot the cluster."
- *Why it fails:* The candidate does not understand the difference between a standalone Pod (`kind: Pod`) and a controller (`kind: Deployment` or `kind: ReplicaSet`). They assume Kubernetes magically recreates anything defined in a YAML file.

#### The Top 1% Senior Response
"The failure occurred because the engineer deployed a **bare Pod** (`kind: Pod`) rather than wrapping the workload inside a controller like a `Deployment`, `ReplicaSet`, or `StatefulSet`.

Here is the precise architectural boundary:

1. **Container-Level Recovery (Worker Node Scope):**
   `kubelet` runs locally on each worker node. If an active container crashes inside a healthy Pod, `kubelet` detects the exit code and restarts the container based on `spec.restartPolicy: Always`. However, `kubelet` has zero authority across the rest of the cluster. If the node itself is drained, powered off, or deleted, `kubelet` cannot reschedule the workload onto another host.

2. **Pod-Level Recovery (Control Plane Scope):**
   Standalone Pods are mortal computing objects. When you create a bare Pod, `etcd` records that specific Pod instance. There is **no controller tracking desired replica count**. When node-worker-02 was drained, the API server instructed the node to terminate the Pod. Because no controller object existed to say *'Desired replicas: 1, Current replicas: 0'*, the Pod remained dead.

3. **The Production Fix:**
   Never deploy standalone Pods in production. All workloads must be governed by a `Deployment` (or `StatefulSet` for stateful workloads). The `kube-controller-manager` runs an active reconciliation loop. If a node running a Deployment's Pod is drained or dies, the `DeploymentController` detects that actual count (0) does not match desired count (1), and immediately requests the API server to create a replacement Pod, which `kube-scheduler` places onto a healthy node."

---

### Scenario 2: The Worker Node "NotReady" Black Hole (Kubelet Diagnostics)

#### The Incident Alert
> **Severity:** P2 (Degraded Cluster Capacity)  
> **Context:** Monitoring triggers an alert: Worker node `k8s-node-worker-03` changed status from `Ready` to `NotReady`. Existing Pods on that node are stopping health checks, and no new Pods can be scheduled on it.  
> An engineer suggests: *"Let's delete the node object using `kubectl delete node k8s-node-worker-03` and restart the physical machine."*

#### The Interviewer Question
*"Why is deleting the node object premature? What internal mechanisms cause a node to become `NotReady`, and what is your step-by-step triage sequence on the node host?"*

#### Why the Bottom 80% Candidate Fails
- *The Generic Answer:* "I would delete the node, restart Docker, or rerun the Terraform script to spin up a new EC2 instance."
- *Why it fails:* Deleting a node object from the API server without diagnosing the root cause drops running workloads abruptly and leaves the underlying host in an unmanaged, corrupted state. It demonstrates no familiarity with node system daemons.

#### The Top 1% Senior Response
"A node reports `NotReady` when the control plane stops receiving regular heartbeats from the node's `kubelet` daemon, or when `kubelet` reports a critical condition like `DiskPressure`, `MemoryPressure`, or `PIDPressure`.

Before touching cluster objects or rebooting, I follow a disciplined 4-step host triage procedure:

1. **Inspect Control Plane Node Conditions:**
   ```bash
   kubectl describe node k8s-node-worker-03
   ```
   I examine the `Conditions` block (`Ready`, `MemoryPressure`, `DiskPressure`, `PIDPressure`) and the `Events` section at the bottom. This reveals whether the node ran out of disk inodes, exhausted local memory, or lost network communication.

2. **Log in to the Host and Inspect the `kubelet` Systemd Service:**
   I SSH into `k8s-node-worker-03` and inspect the daemon status:
   ```bash
   sudo systemctl status kubelet
   sudo journalctl -u kubelet -e --no-pager -n 100
   ```
   Common failures include: expired client TLS certificates for the API server, misconfigured flags, or the Linux Out-Of-Memory (OOM) killer terminating `kubelet`.

3. **Inspect the Container Runtime Socket:**
   `kubelet` relies on the Container Runtime Interface (CRI) to manage containers. If the container runtime daemon crashes, `kubelet` fails its internal health check:
   ```bash
   sudo systemctl status containerd
   sudo crictl pods
   ```
   If containerd is unresponsive or the Unix domain socket `/run/containerd/containerd.sock` is locked, `kubelet` cannot report container statuses.

4. **Verify Host Storage and Network Connectivity:**
   ```bash
   df -h /var/lib/docker /var/lib/kubelet
   curl -k https://<control-plane-ip>:6443/livez
   ```
   If `/var/lib/kubelet` or `/var/log` reaches 100% disk utilization, the node enters `DiskPressure` and refuses new workloads. If the `curl` check fails, the issue is an AWS security group, route table, or local firewall rule blocking outbound traffic to the API server on port 6443."

---

### Scenario 3: Decoupling the Control Plane from the Data Plane

#### The Incident Alert
> **Severity:** P1 (Cluster Management Blocked)  
> **Context:** An SRE accidentally cuts network access between the control plane master node and the external network. Any engineer typing `kubectl get pods` or attempting to deploy via CI/CD gets a connection timeout error (`Unable to connect to the server: dial tcp ...:6443: i/o timeout`).  
> An executive asks: *"Does this mean our entire customer-facing website is completely down right now?"*

#### The Interviewer Question
*"Explain why existing customer traffic may still be served normally despite the control plane being completely unreachable. What works and what breaks during a control plane outage?"*

#### Why the Bottom 80% Candidate Fails
- *The Generic Answer:* "Yes, if the master node goes down, the whole cluster is dead and all containers stop running immediately."
- *Why it fails:* The candidate assumes Kubernetes is a monolithic runtime where every request flows through the master node. They do not comprehend the separation between the Control Plane and the Data Plane.

#### The Top 1% Senior Response
"No, customer-facing applications do not automatically go down when the control plane fails. Kubernetes separates the **Control Plane** from the **Data Plane**.

Here is what happens in the cluster during a control plane outage:

1. **What Remains Operational (The Data Plane):**
   - The worker nodes already have their containers running under `containerd`.
   - The Linux kernel namespaces, cgroups, and network bridges (`veth` pairs) remain active.
   - Local routing rules managed by `kube-proxy` (iptables or IPVS) and cloud load balancers remain programmed.
   - If external traffic arrives via an AWS Application Load Balancer or direct NodePort into the worker nodes, the containers continue processing requests, reading from databases, and returning HTTP 200 responses without needing permission from the master node.

2. **What Breaks (The Control Plane):**
   - **No State Mutations:** `kubectl apply`, `kubectl delete`, and CI/CD pipelines fail because `kube-apiserver` cannot be contacted.
   - **No New Scheduling:** If a new Pod is submitted, `kube-scheduler` cannot bind it.
   - **No Node-Level Self-Healing:** If an entire worker node hardware fails, `kube-controller-manager` cannot detect it to reschedule Pods on surviving nodes.
   - **No Horizontal Autoscaling:** The Horizontal Pod Autoscaler (HPA) cannot read metrics or scale replica counts.

3. **Key Architectural Takeaway:**
   Kubernetes worker nodes are autonomous execution engines. The control plane dictates *what* should run, but the worker nodes physically *execute* the workloads independently."

---

### Scenario 4: The 5-Stage Journey of `kubectl apply -f pod.yaml`

#### The Interviewer Question
*"Walk me step-by-step through the lifecycle of a Kubernetes Pod from the exact millisecond an engineer executes `kubectl apply -f pod.yaml` until the container is in `Running` state on a worker node. Name every component involved and its exact duty."*

#### Why the Bottom 80% Candidate Fails
- *The Generic Answer:* "Kubectl sends the file to the master node, the master picks a node, Docker downloads the image, and the container runs."
- *Why it fails:* Surface-level summary with zero understanding of the reconciliation loop, etcd persistence, scheduling algorithms, CRI/CNI plugin boundaries, or watch API streams.

#### The Top 1% Senior Response
"The lifecycle flows across 5 distinct stages involving 6 core components:

1. **Stage 1: Client-Side Validation and Transport**
   - `kubectl` parses the local YAML file, validates the client-side schema against OpenAPI specs, and extracts the cluster endpoint and client TLS certificates from `~/.kube/config`.
   - It issues an authenticated HTTP POST/PUT request over TLS to `kube-apiserver` on port 6443.

2. **Stage 2: API Server Authentication, Authorization, and Persistence**
   - **Authentication:** `kube-apiserver` verifies the client's TLS certificate or Bearer token.
   - **Authorization:** It checks RBAC rules (e.g., does user `prathamesh` have permission to `create` pods in namespace `default`?).
   - **Admission Control:** Mutating and Validating Admission Webhooks inspect the PodSpec (e.g., injecting default resource limits, sidecar containers, or enforcing security policies).
   - **Persistence:** Once valid, `kube-apiserver` commits the PodSpec as a JSON object into `etcd`. At this moment, the Pod exists in state with `status.phase: Pending` and an empty `spec.nodeName: ""` field.

3. **Stage 3: The Scheduling Decision**
   - `kube-scheduler` maintains an active HTTP long-polling watch stream with `kube-apiserver` for unassigned Pods.
   - When it detects the new Pod, it initiates its 2-phase placement cycle:
     - **Filtering (Predicates):** Filters out nodes that lack sufficient CPU/RAM requests, nodes with conflicting taints (unless tolerations match), or nodes with failing node selectors.
     - **Scoring (Priorities):** Scores the remaining eligible nodes based on resource balance, topology spread, and image locality.
   - The scheduler issues a binding request to `kube-apiserver`, which writes `spec.nodeName: <chosen-node>` into `etcd`.

4. **Stage 4: Worker Node Kubelet Execution**
   - The `kubelet` daemon running on the assigned worker node maintains its own watch stream with `kube-apiserver`. It observes that a Pod has been assigned to its specific node name.
   - **CRI Interaction:** `kubelet` sends gRPC requests over a local Unix domain socket to the Container Runtime (`containerd`) via the Container Runtime Interface.
   - containerd checks its local cache. If the image is missing, it pulls the image layers from the remote container registry.
   - **CNI Interaction:** `kubelet` calls the Container Network Interface (CNI) plugin (e.g., AWS VPC CNI, Calico, or Flannel) to allocate an IP address from the Pod CIDR block and attach a virtual ethernet pair (`veth`) connecting the Pod network namespace to the host network bridge.
   - containerd configures Linux cgroups (CPU/memory limits) and namespaces (IPC, UTS, PID, Mount, Net), and launches the container processes.

5. **Stage 5: Status Synchronization Loop**
   - `kubelet` runs periodic liveness and readiness probe checks against the container.
   - It sends an HTTP PATCH request back to `kube-apiserver` updating the Pod status to `status.phase: Running` and recording the allocated Pod IP.
   - `kube-apiserver` commits the updated status into `etcd`.
   - The Pod is now fully initialized and discoverable within the cluster network."
