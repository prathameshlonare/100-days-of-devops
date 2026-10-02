# Day 31 Quiz: Kubernetes Architecture, Primitives, and Cluster Triage

**1. In a Kubernetes cluster, why is direct communication with `etcd` restricted exclusively to `kube-apiserver`, preventing worker nodes and other control plane components from querying it directly?**
A) Because `etcd` requires a proprietary binary protocol that only the Go runtime of `kube-apiserver` can decode.
B) Because `kube-apiserver` acts as the single gatekeeper enforcing authentication, RBAC authorization, admission control, and schema validation before any state changes are persisted.
C) Because `etcd` is an in-memory cache that resets whenever external network sockets connect to it.
D) Because worker nodes communicate exclusively using Docker Compose APIs.

**2. A container process running inside an active Pod crashes due to an unhandled exception (Exit Code 1). Which component detects the crashed process and restarts the container?**
A) `kube-scheduler` running on the control plane.
B) `kube-controller-manager` running on the control plane.
C) `kubelet` running locally on the worker node, communicating with the container runtime.
D) `kube-proxy` updating the iptables routing table.

**3. Two containers are deployed together within the same Pod specification (a multi-container Pod). How do these two containers communicate over the network?**
A) Over `localhost` using standard TCP/UDP ports, because all containers in a Pod share the same network namespace and IP address.
B) Through external DNS lookups via CoreDNS across the cluster network overlay.
C) By mounting an external AWS S3 bucket as an intermediary message queue.
D) Multi-container communication requires an external Ingress Controller to route between them.

**4. An engineer applies a manifest defining a standalone `kind: Pod` (a bare Pod) without a Deployment or ReplicaSet. If the physical worker node hosting this Pod crashes and reboots, what happens to the Pod?**
A) `kube-scheduler` immediately detects the offline node and schedules an identical Pod on a healthy node.
B) The Pod is permanently lost because standalone Pods have no controller maintaining a desired replica count.
C) Docker Desktop automatically converts the Pod into a systemd background service.
D) The Pod status enters `Paused` state until the engineer manually pays AWS EKS licensing fees.

**5. What is the specific architectural action taken by `kube-scheduler` during the placement process of a newly created Pod?**
A) It downloads the container image from Docker Hub onto the worker node filesystem.
B) It executes the container processes by calling Linux cgroups and namespaces directly.
C) It inspects Pod resource requests and node capacities, selects the optimal node, and writes `spec.nodeName` to the API server.
D) It creates iptables packet filtering rules to route external ingress traffic.

---

### Answers and Explanations

<details>
<summary>Click to view Answer for Question 1</summary>

**Correct Answer: B**  
*Explanation:* `kube-apiserver` is the front door of the control plane and the only component permitted to communicate with `etcd`. If worker nodes or random microservices wrote directly to `etcd`, there would be zero authentication, zero RBAC authorization checks, zero admission control mutation, and zero schema validation. Centralizing all state mutations through `kube-apiserver` ensures cluster integrity and consistency.
</details>

<details>
<summary>Click to view Answer for Question 2</summary>

**Correct Answer: C**  
*Explanation:* `kubelet` is the primary node agent running on every worker node. It continuously monitors the status of local containers via the Container Runtime Interface (CRI). When a container process exits unexpectedly, `kubelet` enforces the Pod's `restartPolicy` (default: `Always`) by instructing the container runtime (e.g., `containerd`) to restart the container within the existing Pod.
</details>

<details>
<summary>Click to view Answer for Question 3</summary>

**Correct Answer: A**  
*Explanation:* Containers residing within the same Pod share the same Linux network namespace (`netns`), network interface, and IP address. Because of this shared boundary, they can communicate with each other over `localhost` with minimal network overhead. They must, however, listen on distinct ports to avoid port collision.
</details>

<details>
<summary>Click to view Answer for Question 4</summary>

**Correct Answer: B**  
*Explanation:* Standalone Pods (bare Pods) are mortal. They do not possess self-healing capabilities across node failures. Only higher-level controllers like `Deployment`, `ReplicaSet`, `StatefulSet`, or `DaemonSet` run active reconciliation loops (`kube-controller-manager`) that compare actual state to desired state and spin up replacement Pods when nodes fail.
</details>

<details>
<summary>Click to view Answer for Question 5</summary>

**Correct Answer: C**  
*Explanation:* `kube-scheduler` is purely a placement decision engine. It filters nodes based on constraints (resource requests, taints, tolerations, affinities), scores the remaining candidates, and binds the Pod by setting the `spec.nodeName` field. It then sends this binding request to `kube-apiserver`. The scheduler never executes containers or pulls images; that work is delegated to `kubelet` on the assigned node.
</details>
