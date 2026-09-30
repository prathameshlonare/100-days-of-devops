# Day 24 Quiz — Terraform Fundamentals

**1. You just added a new AWS VPC block to your `main.tf` file in a brand new directory, but when you run `terraform plan`, you get an error saying the provider is missing. What command did you forget to run?**
A) `terraform validate`
B) `terraform apply`
C) `terraform init`
D) `terraform get`

**2. You write a Terraform configuration to create an S3 bucket with a name that is already taken by someone else globally. Which of the following is true?**
A) `terraform plan` will fail because it checks global name uniqueness.
B) `terraform plan` will succeed, but `terraform apply` will fail when AWS rejects the API call.
C) `terraform apply` will automatically append random characters to make the name unique.
D) The local `.tfstate` file will become corrupted.

**3. A colleague suggests opening the `terraform.tfstate` file in VS Code to quickly manually change the IP address of a subnet without writing a Terraform configuration for it. Why is this a terrible idea?**
A) The state file is encrypted and cannot be opened in VS Code.
B) The state file only tracks metadata, not actual resource attributes like IP addresses.
C) Modifying the state file causes it to drift from both your `.tf` code and reality, potentially destroying infrastructure on the next apply.
D) AWS blocks any API calls if it detects a manually edited state file.

**4. In your code, you assign `vpc_id = aws_vpc.main.id` inside a subnet resource block. What does this accomplish beyond just setting the ID?**
A) It creates an implicit dependency, guaranteeing Terraform will create the VPC before trying to create the subnet.
B) It triggers a `terraform init` automatically.
C) It creates an explicit dependency using the `depends_on` meta-argument.
D) It prevents the VPC from ever being destroyed by `terraform destroy`.

**5. When you run `terraform destroy`, how does Terraform know which resources to delete first so it doesn't get a dependency error from AWS?**
A) It deletes them alphabetically by resource name.
B) It deletes them in the reverse order they are written in the `.tf` file.
C) It relies on the AWS console to force the deletion.
D) It uses the dependency graph stored in the state file to delete them in the correct reverse order (e.g., Subnet before VPC).

---
*Answers:*
*1. C (init downloads the required provider plugins)*
*2. B (plan checks syntax and local state; apply executes the AWS API call which will throw the duplication error)*
*3. C (state files map code to reality; manual edits destroy this mapping)*
*4. A (referencing one resource's attribute in another creates an implicit dependency)*
*5. D (Terraform builds a dependency graph from the state and code)*
