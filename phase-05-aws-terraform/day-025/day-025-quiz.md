# Day 25 Quiz — Terraform Variables, Outputs & EC2 Provisioning

**1. A developer defines `variable "instance_type" { default = "t3.micro" }` in `variables.tf`, specifies `instance_type = "t3.small"` in `terraform.tfvars`, sets an environment variable `TF_VAR_instance_type="t3.medium"`, and executes `terraform apply -var="instance_type=t3.large"`. Which instance type will AWS provision?**
A) `t3.micro`
B) `t3.small`
C) `t3.medium`
D) `t3.large` [x]

**2. You run `terraform plan` on a configuration that provisions an EC2 instance with `key_name = "staging-key"`. The plan succeeds with zero errors. However, during `terraform apply`, AWS returns `InvalidKeyPair.NotFound`. Why did `terraform plan` fail to detect this error?**
A) `terraform plan` is disabled from making network calls to AWS.
B) Terraform validates syntax, schema types, and the dependency graph during `plan`, but does not query the AWS API to verify if arbitrary string references like key pair names exist until `apply`. [x]
C) The AWS provider plugin was corrupted and skipped validation.
D) `key_name` is an optional argument, so Terraform ignores it completely.

**3. When you create a Security Group in the AWS Console, you can immediately run `curl` or `apt update` from inside an attached EC2 instance. However, when you create an `aws_security_group` using Terraform with only inbound `ingress` rules and no `egress` block, the instance cannot reach the internet at all. Why?**
A) AWS Console automatically adds an outbound "Allow All" rule (`0.0.0.0/0`), whereas Terraform creates security groups with zero egress rules unless explicitly declared. [x]
B) Terraform disables DNS resolution inside the VPC by default.
C) The EC2 instance must be rebooted after applying Terraform security groups.
D) NACLs override Terraform security groups and block all outbound packets.

**4. Why is using a `data "aws_ami"` block with filters preferred over hardcoding an AMI ID like `ami-0123456789abcdef0` in `main.tf`?**
A) `data` sources are free, while hardcoded AMI IDs incur AWS marketplace fees.
B) AMI IDs are region-specific and change when new OS patches are released; hardcoding breaks multi-region deployment and requires manual updates. [x]
C) Hardcoded AMI IDs cannot be read by `terraform.tfstate`.
D) AWS restricts Terraform from launching instances using direct AMI strings.

**5. In an automated GitHub Actions deployment pipeline, how should a subsequent automated testing step reliably obtain the dynamically assigned public IP of an EC2 instance provisioned by Terraform?**
A) By parsing the human-readable logs of `terraform apply` using regex.
B) By opening the AWS Console and copying the IP manually.
C) By declaring an `output "instance_public_ip"` block and querying it via `terraform output -raw instance_public_ip`. [x]
D) By inspecting the hidden `.terraform` directory files.

---

### Answers & Explanations

**1. D**
*Explanation:* Command-line flags (`-var` or `-var-file`) have the highest priority in Terraform's variable precedence order, overriding `terraform.tfvars`, environment variables (`TF_VAR_*`), and variable block defaults.

**2. B**
*Explanation:* `terraform plan` checks local HCL syntax, provider schemas (confirming `key_name` is an accepted string argument), and state mappings. It does not validate external cloud existence for plain string values against the AWS API. The verification happens on the AWS control plane during the `ec2:RunInstances` API call in `terraform apply`.

**3. A**
*Explanation:* This is one of the most common gotchas when moving from AWS Console click-ops to Terraform. The AWS Console adds an default egress rule allowing all outbound traffic (`0.0.0.0/0`). Terraform does not inject hidden rules; if you do not declare an `egress` block, the security group drops all outbound traffic.

**4. B**
*Explanation:* Every AWS region maintains independent AMI IDs for the same operating system image, and official AMIs are frequently updated with security patches. Using `data "aws_ami"` with filters like `owners = ["amazon"]` and `al2023-ami-2023.*-x86_64` dynamically resolves the latest valid AMI in whichever region the provider is configured for.

**5. C**
*Explanation:* The `output` block allows Terraform to expose computed attributes after execution. Downstream tooling and CI/CD pipelines can retrieve clean machine-readable values using `terraform output -raw <output_name>` or `terraform output -json` without scraping console logs or making custom cloud API calls.
