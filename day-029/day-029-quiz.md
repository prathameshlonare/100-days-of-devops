# Day 29 Quiz — Full Lifecycle Apply/Destroy & Dependency Triage

**1. How does Terraform determine the order in which resources are deleted when executing `terraform destroy`?**
A) Resources are deleted randomly in parallel to speed up execution.
B) Terraform inverts the Directed Acyclic Graph (DAG) used during creation, deleting downstream leaf resources (like EC2) before upstream dependencies (like VPC).
C) Terraform follows the line-by-line order in which resources are written in `main.tf`.
D) Terraform deletes networking resources first, then terminates compute instances.

**2. A continuous deployment pipeline executes `terraform destroy` on an ephemeral feature branch environment. The apply halts with the error: `DependencyViolation: The subnet 'subnet-0123' has dependencies and cannot be deleted.` What is the most likely technical cause?**
A) The AWS region experienced a temporary API timeout.
B) The subnet has an unmanaged Elastic Network Interface (ENI), AWS Lambda VPC interface, or Load Balancer holding an IP address inside the subnet.
C) Terraform cannot delete public subnets that have `map_public_ip_on_launch = true`.
D) The local `terraform.tfstate` file was deleted before running destroy.

**3. In AWS, an engineer terminates an EC2 instance that was deployed with an attached 50 GB EBS volume (`/dev/sdf`) where `delete_on_termination` was set to `false`. What happens after `terraform destroy` completes?**
A) The EBS volume is automatically deleted by AWS after 24 hours.
B) Terraform throws an error and prevents the EC2 instance from terminating.
C) The EBS volume remains in AWS in `available` state and continues to incur monthly storage charges until explicitly deleted.
D) The EBS volume is converted to an S3 bucket automatically.

**4. When running `terraform destroy`, which command-line flag can be used to destroy only one specific resource (and anything that depends on it) without wiping out the entire infrastructure?**
A) `terraform destroy -target=aws_instance.web`
B) `terraform destroy -only=aws_instance.web`
C) `terraform destroy -isolate=aws_instance.web`
D) `terraform destroy -resource=aws_instance.web`

**5. What is the fundamental difference between `terraform destroy` and deleting an environment manually via the AWS Management Console?**
A) The AWS Console is faster because it bypasses API rate limits.
B) `terraform destroy` updates the state file to reflect that zero resources exist, whereas manual Console deletion creates out-of-band state drift.
C) `terraform destroy` only deletes compute resources, while the Console deletes networking.
D) There is no difference; Terraform automatically detects console deletions without running a refresh.

---

### Answers & Explanations

<details>
<summary>Click to view Answer for Question 1</summary>

**Correct Answer: B**  
*Explanation:* Terraform models dependencies as a Directed Acyclic Graph (DAG). When creating infrastructure, it works forward (VPC -> Subnet -> Security Group -> EC2). When destroying infrastructure, it inverts the graph (EC2 -> Security Group -> Subnet -> VPC) so that parent resources are never deleted while child resources still depend on them.
</details>

<details>
<summary>Click to view Answer for Question 2</summary>

**Correct Answer: B**  
*Explanation:* The AWS EC2 control plane enforces a strict constraint: a subnet CIDR block cannot be deleted if any Elastic Network Interface (ENI) exists within it. If an unmanaged service (like an RDS database, an Application Load Balancer, an AWS Lambda VPC interface, or a manually provisioned network card) has an IP allocated in that subnet, AWS rejects the deletion with `DependencyViolation`.
</details>

<details>
<summary>Click to view Answer for Question 3</summary>

**Correct Answer: C**  
*Explanation:* Secondary EBS volumes or volumes with `delete_on_termination = false` detach when the instance terminates and transition to `available` state. They do not disappear on their own. They continue billing for provisioned gigabytes every single month until manually deleted or managed via Terraform lifecycle policies.
</details>

<details>
<summary>Click to view Answer for Question 4</summary>

**Correct Answer: A**  
*Explanation:* The `-target` flag allows targeted lifecycle operations (`terraform destroy -target=<resource_address>`). While generally discouraged in regular CI/CD runs because it can create partial state, it is an essential break-fix tool for surgically removing a corrupted or stubborn resource without tearing down an entire production VPC.
</details>

<details>
<summary>Click to view Answer for Question 5</summary>

**Correct Answer: B**  
*Explanation:* `terraform destroy` communicates with the cloud provider, destroys the resources, and clears the state file cleanly (`"resources": []`). If you delete resources via the AWS Console, the physical cloud resources vanish, but `terraform.tfstate` still thinks they exist, causing state drift and synchronization issues on subsequent runs.
</details>
