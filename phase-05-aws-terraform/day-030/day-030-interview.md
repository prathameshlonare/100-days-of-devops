# Day 30 Interview Scenarios — Checkpoint 2: The Cloud Support & DevOps Gate

> **Purpose:** Real-world scenario and incident drills covering Phase 5 (AWS Networking, Cloud Triage, and Terraform Architecture). These questions reflect technical interview loops for Cloud Support Associate, Cloud Operations, and Junior DevOps Engineer roles at AWS, Cloud Consultancies, and Tier-1 Tech teams.

---

### Scenario 1: The Brownfield Migration (Adopting Live Production Data into IaC)

#### The Incident Alert
> **Context:** A company has an unmanaged AWS S3 bucket containing 10 TB of critical customer documents and legal contracts created two years ago in the AWS Console. Management mandates that all infrastructure must be codified in Terraform within 30 days.  
> A junior engineer writes a `resource "aws_s3_bucket"` block and says: *"I'm ready to run `terraform apply` on production."*

#### The Interviewer Question
*"What will happen if that engineer runs `terraform apply`? How do you safely adopt live production infrastructure into Terraform without downtime, data loss, or resource recreation?"*

#### Why the Bottom 80% Candidate Fails
- *The Generic Answer:* "If they run apply, Terraform will just detect the bucket and start managing it. If not, they should delete the old bucket and create a new one with Terraform."
- *Why it fails:* Recreating a bucket deletes 10 TB of customer data! Running apply on an un-imported bucket crashes with `BucketAlreadyExists`. It demonstrates complete ignorance of how Terraform state relates to live cloud resources.

#### The Top 1% Senior Response
"If the engineer runs `terraform apply` with an empty state file, Terraform assumes the resource does not exist and calls the S3 `CreateBucket` API. AWS rejects the request with an HTTP 409 `BucketAlreadyExists` error. If this were a resource that AWS *allows* duplicate names for (like an EC2 instance), Terraform would provision a duplicate, unneeded instance and cause billing waste.

Here is the 5-step production adoption protocol:

1. **Write the Skeleton Resource Block:**
   Declare the resource block in `main.tf` matching the existing bucket name.
2. **Execute State Adoption (`terraform import` or `import {}` block):**
   ```bash
   terraform import aws_s3_bucket.customer_docs company-production-customer-docs
   ```
   *Crucial mechanism:* This queries the AWS API and writes the bucket's existing live configuration directly into `terraform.tfstate`. **No cloud resources are touched, modified, or stopped.**
3. **Execute Delta Reconciliation (`terraform plan`):**
   Run `terraform plan`. Terraform compares the live attributes recorded in state against the HCL code in `main.tf`. If there is a discrepancy (for example, server-side encryption or tags are missing in your code), `plan` will show:
   `~ update in-place`
4. **Tune Code until `Plan: 0 to add, 0 to change, 0 to destroy`:**
   Adjust your HCL code to match the existing production settings until `terraform plan` reports **zero changes**. This guarantees that applying will not trigger unexpected updates.
5. **Commit to Git:**
   Commit the codified resource to version control. The legacy console resource is now officially governed by IaC."

---

### Scenario 2: The "Ghost" Subnet Outage (Stateful SG vs Stateless NACL Triage)

#### The Incident Alert
> **Severity:** P1 (Production Outage)  
> **Symptom:** A web application server deployed in a public subnet stopped responding to external users.  
> **Investigation so far:** The on-call engineer confirmed:
> - EC2 instance status checks are **2/2 Green**.
> - Nginx web server daemon is active and listening on port 80 (`ss -tulpn` shows port 80 is `LISTEN`).
> - The Security Group allows inbound TCP port 80 from `0.0.0.0/0` and all outbound traffic (`0.0.0.0/0`).
> - Yet external users run `curl -v http://<public-ip>` and the connection **hangs indefinitely** with no response.

#### The Interviewer Question
*"The instance is healthy, Nginx is listening, and the Security Group is open. Why is external web traffic hanging? Where do you look next in the network path, and how do you prove it?"*

#### Why the Bottom 80% Candidate Fails
- *The Generic Answer:* "I would reboot the instance, restart Nginx, or check the route table."
- *Why it fails:* Pointless rebooting doesn't fix a network boundary policy drop. The candidate forgets that Security Groups are only the first line of defense; Network ACLs govern the subnet boundary.

#### The Top 1% Senior Response
"Because the connection is hanging rather than returning `Connection Refused`, packets are being silently dropped at a network boundary. Since the Security Group is verified open, the blocker is almost certainly the **Subnet Network Access Control List (NACL)**.

Here is the technical mechanism:
1. **Security Groups are Stateful:** When a client sends a SYN packet on port 80, the Security Group automatically tracks the connection and allows return traffic back to the client regardless of outbound rules.
2. **NACLs are Stateless:** NACLs inspect every packet independently in both directions. When a web client connects to port 80, the return traffic from the web server goes back to the client on a randomly negotiated **ephemeral port** (TCP 1024–65535).
3. **The Root Cause:** If the subnet's outbound NACL only allows port 80 outbound (or has a custom deny), the server accepts the inbound request, but the return SYN-ACK packet is **blocked at the subnet boundary** because outbound ephemeral ports are dropped.

**How to Prove It:**
1. Check VPC Flow Logs in CloudWatch:
   Query for the EC2 private IP. You will see an `ACCEPT` record on port 80, but a corresponding `REJECT` on outbound port 49152+ caused by the NACL.
2. **The Fix:**
   Add an outbound rule to the subnet NACL:
   - Rule Number: 100
   - Type: Custom TCP
   - Port Range: `1024-65535`
   - Destination: `0.0.0.0/0`
   - Allow."

---

### Scenario 3: The State Lock Collision Deadlock in CI/CD

#### The Incident Alert
> **Context:** An automated deployment pipeline running `terraform apply` on AWS infrastructure was terminated when an engineer clicked "Cancel Build" in GitHub Actions.  
> Subsequent pipeline builds halt with:  
> `Error: Error acquiring the state lock: ConditionalCheckFailedException`  
> A junior engineer asks: *"Can I just add `-lock=false` to our deployment script, or run `terraform force-unlock` right now?"*

#### The Interviewer Question
*"Why is adding `-lock=false` a catastrophic anti-pattern? And before you run `terraform force-unlock`, what exact verification steps must you execute to prevent destroying production?"*

#### Why the Bottom 80% Candidate Fails
- *The Generic Answer:* "Just run `terraform force-unlock` with the Lock ID so the pipeline can keep going."
- *Why it fails:* Running force-unlock blindly can cause catastrophic state corruption if the previous process was not actually dead (e.g. still writing state in the background).

#### The Top 1% Senior Response
"Adding `-lock=false` to an automated CI/CD pipeline permanently disables concurrency protection. If two pipelines trigger simultaneously (e.g. two pull requests merging or a scheduled cron colliding with a hotfix), both processes write to state simultaneously, corrupting the JSON graph and leaving orphan infrastructure in AWS.

Before running `terraform force-unlock`, I execute this 3-step verification:

1. **Verify the Process is Genuinely Dead:**
   I read the `Lock Info` output displayed in the terminal:
   - `Who`: Identifies the machine and user (e.g. `runner-worker-4`).
   - `Created`: UTC timestamp.
   I inspect the GitHub Actions worker node or process tree to confirm that process ID is 100% terminated and not hanging on a slow AWS API response.
2. **Inspect CloudTrail for Active In-Flight API Calls:**
   I check AWS CloudTrail event history for the deployment IAM role over the last 15 minutes. If CloudTrail shows ongoing `ec2:CreateVolume` or `rds:ModifyDBInstance` calls, Terraform is still executing in AWS! Releasing the lock while an apply is active causes split-brain state corruption.
3. **Execute `force-unlock` Surgically:**
   Only once I confirm that zero active processes and zero active cloud mutations exist, I release the lock:
   ```bash
   terraform force-unlock <Lock-ID>
   ```
   And re-run `terraform plan` to confirm state integrity before reapplying."

---

### Scenario 4: Out-of-Band Cloud Drift vs Immutable Infrastructure

#### The Incident Alert
> **Context:** During a security compliance audit, the security operations center flags that a database security group has an active rule allowing incoming traffic on port 22 (SSH) from `0.0.0.0/0`.  
> An on-call engineer says: *"Someone must have added that manually during a production incident last week. I'll just go into the AWS Console and delete it."*

#### The Interviewer Question
*"Why should the engineer NOT just delete the rule in the AWS Console? How should drift be detected, resolved, and permanently prevented using Terraform and AWS governance?"*

#### The Top 1% Senior Response
"Deleting the rule manually in the AWS Console reinforces the exact anti-pattern that caused the issue: **Click-Ops Drift**. If engineers make manual fixes, nobody knows who made the change, there is no audit trail, and future automated deployments may reintroduce errors.

Here is the correct engineering procedure:

1. **Let Terraform's Reconciliation Engine Prove the Drift:**
   Run `terraform plan` in the deployment pipeline. During the **Refresh Phase**, Terraform queries the live AWS EC2 API (`DescribeSecurityGroups`), compares it to `main.tf`, and flags the rogue SSH rule:
   ```text
   ~ resource "aws_security_group" "db_sg" {
       - ingress {
           - from_port   = 22
           - to_port     = 22
           - cidr_blocks = ["0.0.0.0/0"]
         }
     }
   Plan: 0 to add, 1 to change, 0 to destroy.
   ```
2. **Reconcile via Code:**
   Execute `terraform apply`. Terraform calls the AWS API to delete the rogue rule, bringing physical cloud infrastructure into 100% compliance with source code.
3. **Permanent Prevention (Defense-in-Depth):**
   - **Revoke Console Write Permissions:** Restrict engineer IAM roles using least-privilege policies. Engineers should have `ReadOnlyAccess` in production AWS accounts; only the CI/CD pipeline's assumed IAM role should have write permissions.
   - **Service Control Policies (SCPs):** In AWS Organizations, enforce an SCP that denies `ec2:AuthorizeSecurityGroupIngress` unless called by the approved deployment pipeline role.
   - **Automated Drift Detection:** Schedule a nightly `terraform plan -detailed-exitcode` in GitHub Actions. If exit code `2` is returned (meaning drift was detected), trigger an alert to the engineering team."
