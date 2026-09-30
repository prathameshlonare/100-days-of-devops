# Day 30 Quiz — Checkpoint 2: AWS Networking & Terraform Mastery

**1. When an engineer executes `terraform import aws_s3_bucket.my_bucket existing-bucket-name`, what does Terraform physically do?**
A) It deletes the existing bucket in AWS and recreates it using default settings.
B) It reads the existing bucket's attributes from the AWS API and writes them into `terraform.tfstate` without modifying or destroying the physical cloud resource.
C) It automatically writes HCL code into `main.tf` and deploys it immediately.
D) It converts the S3 bucket into an encrypted DynamoDB table.

**2. A production web server in a public subnet can receive incoming HTTP requests on port 80, but outbound responses are dropped and client connections time out. The Security Group allows inbound port 80 and all outbound traffic. What is the most likely root cause?**
A) The EC2 instance ran out of disk space on the root EBS volume.
B) The Subnet Network Access Control List (NACL) is missing an outbound rule allowing ephemeral return ports (TCP 1024–65535).
C) The Internet Gateway was deleted from the VPC.
D) Terraform state lock prevented the network route table from updating.

**3. Why do production Terraform configurations use `data "aws_ssm_parameter"` to resolve Ubuntu AMIs instead of hardcoding an AMI ID like `ami-0123456789abcdef0` in the resource block?**
A) Hardcoded AMI IDs are encrypted and cannot be parsed by Terraform.
B) Hardcoded AMI IDs are regional snapshots that fail when deploying to a different AWS region and rot when Canonical deregisters outdated, unpatched images.
C) AWS charges an additional fee for every hardcoded AMI reference.
D) `data` sources allow the EC2 instance to bypass VPC route tables.

**4. Two automated GitHub Actions pipelines simultaneously trigger `terraform apply` on the same production infrastructure stack. Which AWS service and mechanism prevents state corruption?**
A) S3 Object Versioning blocks the second pipeline using POSIX file locks.
B) AWS CloudTrail automatically pauses the second pipeline runner.
C) DynamoDB uses an atomic conditional write (`attribute_not_exists(LockID)`), causing the second pipeline to fail safely with `ConditionalCheckFailedException`.
D) AWS IAM revokes the deployment role's credentials temporarily.

**5. While running `terraform destroy` to decommission an ephemeral test environment, Terraform halts with `DependencyViolation: The subnet has active dependencies and cannot be deleted.` What command immediately reveals the blocker?**
A) `terraform refresh -force`
B) `aws ec2 describe-network-interfaces --filters "Name=subnet-id,Values=<subnet-id>"`
C) `aws iam get-user --user-name admin`
D) `terraform state rm aws_subnet.public`

---

### Answers & Explanations

<details>
<summary>Click to view Answer for Question 1</summary>

**Correct Answer: B**  
*Explanation:* `terraform import` is strictly a state-binding operation. It queries the cloud provider API for the specified resource ID and writes the existing attributes into `terraform.tfstate`. It never modifies, stops, or destroys the physical cloud resource in AWS.
</details>

<details>
<summary>Click to view Answer for Question 2</summary>

**Correct Answer: B**  
*Explanation:* Unlike Security Groups (which are stateful and automatically track return connections), Network Access Control Lists (NACLs) are stateless. Inbound packets on port 80 establish client sessions that return on random ephemeral ports (typically 1024–65535). If the NACL lacks an outbound rule allowing ephemeral ports to `0.0.0.0/0`, the return packet is dropped at the subnet boundary.
</details>

<details>
<summary>Click to view Answer for Question 3</summary>

**Correct Answer: B**  
*Explanation:* AMI IDs are unique per region and are frequently deregistered by operating system vendors when security vulnerabilities are patched. Hardcoding an AMI string breaks cross-region deployment and causes `InvalidAMIID.NotFound` errors over time. Resolving AMIs dynamically via SSM Parameter Store guarantees that Terraform always queries the latest verified image in whichever region it executes.
</details>

<details>
<summary>Click to view Answer for Question 4</summary>

**Correct Answer: C**  
*Explanation:* S3 is an object store without native file locking. To provide distributed mutual exclusion, Terraform leverages DynamoDB conditional writes. Before reading or writing state, Terraform attempts to write a lock record with `attribute_not_exists(LockID)`. If another process holds the lock, DynamoDB rejects the write, stopping the second pipeline from overwriting or corrupting the state file.
</details>

<details>
<summary>Click to view Answer for Question 5</summary>

**Correct Answer: B**  
*Explanation:* Subnets cannot be deleted while any Elastic Network Interface (ENI) has an allocated private IP inside that subnet. Querying `aws ec2 describe-network-interfaces` with the subnet filter immediately outputs the ID, description, and status of the lingering interface (whether an unmanaged network card, a Lambda VPC interface, or a load balancer).
</details>
