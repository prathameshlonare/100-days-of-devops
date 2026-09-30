# Day 29 Interview Scenarios — Teardown Failures, Dependency Graphs & Cloud Audits

> **Purpose:** Real-world incident scenarios asked in Cloud Support, Platform Engineering, and Junior DevOps technical interviews. These scenarios evaluate your troubleshooting methodology, command-line triage skills, and architectural defense when cloud teardowns fail.

---

### Scenario 1: The Stuck Ephemeral Pipeline (`DependencyViolation` on Subnet)

#### The Incident Alert
> **Severity:** P2 (CI/CD Pipeline Blocker)  
> **Alert:** GitHub Actions preview environment teardown failed on branch `feature-auth-v2`.  
> **Error Output:**  
> `Error: deleting EC2 Subnet (subnet-04a8b1c99): DependencyViolation: The subnet 'subnet-04a8b1c99' has dependencies and cannot be deleted.`  
> All subsequent feature deploys to this test account are blocked due to VPC CIDR exhaustion.

#### The Interviewer Question
*"Terraform says it deleted the EC2 instance and Security Group, but it halts on the Subnet with `DependencyViolation`. The local state shows no other resources. Walk me through your step-by-step triage: how do you identify what is holding the subnet hostage, and how do you resolve it?"*

#### Why the Bottom 80% Candidate Fails
- *The Generic Answer:* "I would log into the AWS Console, click around the subnet, see if an instance is still shutting down, wait 5 minutes, and try `terraform destroy` again."
- *Why it fails:* It reveals reliance on manual click-ops, lacks understanding of the underlying AWS networking primitives (ENIs), and wastes time waiting when the issue is an active dependency that will never delete itself.

#### The Top 1% Senior Response
"Subnets in AWS cannot be deleted while **any** Elastic Network Interface (ENI) has an IP allocated inside that subnet's CIDR block. Even if the EC2 instance is terminated, other AWS services or unmanaged resources may have created an interface.

Here is my triage chain:

1. **Query the AWS API directly for active ENIs:**
   Instead of clicking around the console, I immediately query the AWS EC2 API using the CLI:
   ```bash
   aws ec2 describe-network-interfaces \
     --filters "Name=subnet-id,Values=subnet-04a8b1c99" \
     --query "NetworkInterfaces[].[NetworkInterfaceId,InterfaceType,Description,Attachment.InstanceOwnerId,Status]" \
     --output table
   ```
2. **Classify the Dependency:**
   - **Case A: Orphaned/Unmanaged ENI (`Status: available`):** If a developer manually created a network interface or attached a secondary card, I grab the `NetworkInterfaceId` and delete it:
     ```bash
     aws ec2 delete-network-interface --network-interface-id eni-0123456789abcdef0
     ```
   - **Case B: AWS Managed Service Interface (`InterfaceType: lambda` or `nat_gateway` or `network_load_balancer`):** AWS will reject direct deletion of managed ENIs. The `Description` field will reveal the parent (e.g. `ELB app/my-alb/...` or `AWS Lambda VPC ENI`). I must delete or dissociate the parent service first.
   - **Case C: EC2 Instance in `shutting-down` State:** If an instance was just terminated, its primary ENI takes up to 60 seconds to release. I check `aws ec2 describe-instances` for status `terminated` before retrying.
3. **Resume Teardown:**
   Once the ENI table returns empty, I re-run `terraform destroy` to cleanly wipe the subnet and VPC."

#### Socratic Follow-Up Pressure
- **Interviewer:** *"What if the ENI belongs to an AWS Application Load Balancer created outside Terraform? Can you run `aws ec2 delete-network-interface` with `--force`?"*
- **Candidate Defense:** *"No. AWS explicitly forbids deleting an ENI managed by an AWS service (requester-managed). The API returns `UnauthorizedOperation` or `InvalidParameterValue`. You must delete the ALB or target group first, which then triggers AWS to delete its own ENIs."*

---

### Scenario 2: The \$1,200 "Zombie" Billing Surprise After Teardown

#### The Incident Alert
> **Severity:** Financial Escalation  
> **Context:** A project team finished testing an infrastructure stack in `eu-north-1` three weeks ago and ran `terraform destroy`. The terminal printed `Destroy complete! Resources: 14 destroyed.`  
> Today, the finance team flags a **\$1,200 monthly charge** on the account for idle storage and network penalties.

#### The Interviewer Question
*"If `terraform destroy` reported complete success with zero errors, how could an AWS account still rack up over \$1,000 in charges? Where do you look first?"*

#### Why the Bottom 80% Candidate Fails
- *The Generic Answer:* "Someone must have lied about running destroy, or someone re-ran apply by mistake."
- *Why it fails:* It demonstrates zero operational experience with AWS billing traps and unmanaged resource lifecycles.

#### The Top 1% Senior Response
"`terraform destroy` only destroys resources **tracked in `terraform.tfstate`**. In AWS, several metered resources easily detach or persist outside of Terraform's view:

1. **Unattached Elastic IP Penalties:**
   AWS provides in-use public IPs, but charges **\$0.005/hr for every allocated Elastic IP that is NOT attached to a running instance**. If an EIP was provisioned outside Terraform (or imported incorrectly), it bills continuously.
   *Audit command:*
   ```bash
   aws ec2 describe-addresses --query "Addresses[?InstanceId==null].[PublicIp,AllocationId]"
   ```
2. **Dangling EBS Volumes (`delete_on_termination = false`):**
   By default, secondary EBS volumes (e.g. `/dev/sdb`) or volumes where `delete_on_termination` was explicitly disabled remain in `available` state when an EC2 instance terminates. A few 1 TB `gp3` or `io2` volumes sitting idle cost hundreds of dollars every month.
   *Audit command:*
   ```bash
   aws ec2 describe-volumes --filters "Name=status,Values=available" --query "Volumes[].[VolumeId,Size,VolumeType]"
   ```
3. **S3 Bucket Noncurrent Versions & Delete Markers:**
   If an S3 bucket has Versioning enabled, deleting objects via normal `DeleteObject` calls only places a 0-byte delete marker. All historical versions (GBs or TBs of database snapshots or state files) remain fully billed in S3 Standard storage.
4. **NAT Gateway Idle Billing:**
   NAT Gateways incur a flat hourly rate (~$0.045/hr) simply for existing, regardless of whether any traffic flows through them."

#### Socratic Follow-Up Pressure
- **Interviewer:** *"How do you guarantee this never happens again in non-production scratch accounts?"*
- **Candidate Defense:** *"Three controls: First, set up an AWS Budget Alert with anomaly detection that triggers a Slack/email notification at 50% of the threshold. Second, enforce `aws ec2 describe-volumes` and `describe-addresses` audit sweeps as the final step of our teardown pipeline. Third, for sandbox accounts, run open-source tools like `aws-nuke` on a nightly cron to obliterate un-tagged resources."*

---

### Scenario 3: The Surgical Teardown (`-target` Risk & Recovery)

#### The Incident Alert
> **Severity:** P1 (Production Outage Risk)  
> **Context:** A junior engineer wanted to redeploy a misconfigured EC2 instance in production. Instead of running a standard deployment, they executed:  
> `terraform destroy -target=aws_instance.web`  
> The instance terminated, but when they ran `terraform apply`, half the application crashed with connection timeouts.

#### The Interviewer Question
*"When is using `terraform destroy -target` justified, and why is using `-target` in production generally considered an operational anti-pattern?"*

#### Why the Bottom 80% Candidate Fails
- *The Generic Answer:* "Target is great when you want to save time and only delete the one thing you are working on."
- *Why it fails:* Fails to understand dependency graph truncation and state divergence.

#### The Top 1% Senior Response
"Using `-target` breaks Terraform's core design principle: **declarative full-graph reconciliation**.

1. **The Danger of Dependency Truncation:**
   When you target a single resource for destruction, Terraform isolates that resource but ignores implicit downstream relationships. If another resource (e.g. a DNS record, a target group attachment, or a database connection pool) relies on that instance's private IP, Terraform does not update the dependents. The dependent resources are left pointing to a terminated black hole.
2. **State Graph Divergence:**
   Targeted applies and destroys leave `terraform.tfstate` partially refreshed. If subsequent engineers run a normal `terraform apply`, Terraform may plan unexpected cascading updates or replacements across untouched services.
3. **When is `-target` Actually Justified?**
   Only in **emergency break-fix recovery**:
   - Clearing an orphaned, corrupt resource that is deadlocking the provider API.
   - Bootstrapping circular dependencies (e.g. creating an IAM role before attaching a policy).
   In routine operations, changes should always be made by editing the code and letting Terraform plan the entire dependency graph."

---

### Scenario 4: Circular Security Group Dependencies During Teardown

#### The Incident Alert
> **Context:** An application tier has two security groups: `app-sg` and `db-sg`. `app-sg` allows outbound traffic to `db-sg`, and `db-sg` allows inbound traffic from `app-sg`.  
> When running `terraform destroy`, Terraform hangs for 15 minutes and errors out:  
> `DependencyViolation: resource sg-0123 has active dependencies`

#### The Interviewer Question
*"Why does Terraform get deadlocked trying to delete mutually referencing security groups, and how do you architect your Terraform code to prevent this?"*

#### The Top 1% Senior Response
"This occurs when security group rules are defined **inline** within the `aws_security_group` resource block:
```hcl
# ANTIPATTERN: Inline mutual reference
resource "aws_security_group" "app" {
  ingress { security_groups = [aws_security_group.db.id] }
}
resource "aws_security_group" "db" {
  ingress { security_groups = [aws_security_group.app.id] }
}
```
During destruction, Terraform tries to delete `app-sg`, but AWS blocks it because `db-sg` still references it. Terraform tries to delete `db-sg`, but `app-sg` still references it. This is a cyclic dependency deadlock.

**The Solution:**
Never use inline ingress/egress blocks for cross-group references. Always declare rules as independent standalone resources using **`aws_security_group_rule`**:
```hcl
# PRODUCTION STANDARD: Decoupled rules
resource "aws_security_group" "app" { name = "app-sg" }
resource "aws_security_group" "db"  { name = "db-sg" }

resource "aws_security_group_rule" "app_to_db" {
  type                     = "ingress"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.app.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
}
```
When destroying, Terraform's DAG can cleanly delete the `aws_security_group_rule` first, breaking the cycle, and then delete the parent security groups without any `DependencyViolation`."
