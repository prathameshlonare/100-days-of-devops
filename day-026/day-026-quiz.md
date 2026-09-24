# Day 26 Quiz — Terraform State Backend (S3 + DynamoDB State Locking)

**1. A developer attempts to parameterize their remote S3 backend configuration using variables, writing `bucket = var.state_bucket_name` inside `terraform { backend "s3" { ... } }`. When they run `terraform init`, what happens?**
A) Terraform prompts the user interactively to enter the value of `var.state_bucket_name`.
B) Terraform throws a syntax error stating that variables, locals, and data sources are not allowed inside a backend configuration block. [x]
C) Terraform automatically reads the value from `terraform.tfvars`.
D) Terraform initializes the backend successfully and creates the bucket dynamically.

**2. Two developers on your team accidentally execute `terraform apply` at the exact same moment on a project configured with an S3 backend and DynamoDB state locking. What mechanism prevents state corruption?**
A) S3 automatically rejects the second PUT request using POSIX file locks.
B) Terraform acquires an atomic lock in DynamoDB using conditional write `attribute_not_exists(LockID)`; the second apply fails with `ConditionalCheckFailedException`. [x]
C) Git merges both state files using a three-way merge algorithm.
D) The AWS EC2 API queues the second request until the first instance finishes launching.

**3. A Jenkins CI/CD worker was forcefully terminated by an out-of-memory (OOM) killer while executing `terraform apply`. Subsequent pipeline builds now fail with `Error: Error acquiring the state lock: ConditionalCheckFailedException`. After confirming no other process is active, how should you safely clear the lock?**
A) Delete the entire DynamoDB table and re-run `terraform init`.
B) Execute `terraform force-unlock <Lock-ID>` using the unique lock ID displayed in the error message. [x]
C) Re-run the pipeline with the flag `-lock=false` permanently in your CI script.
D) Empty the S3 bucket to reset state.

**4. When creating an AWS DynamoDB table specifically for Terraform state locking, which attribute is strictly required as the primary partition key?**
A) `id` (String)
B) `StateKey` (Binary)
C) `LockID` (String) [x]
D) `TerraformLock` (Number)

**5. Why is enabling S3 Bucket Versioning considered a mandatory best practice for Terraform remote state backends?**
A) It makes `terraform plan` execute 50% faster by caching historical state locally.
B) Versioning compresses the JSON file to save S3 storage costs.
C) If an apply fails or human error corrupts the remote state file, you can immediately inspect historical versions and restore a previous known-good state. [x]
D) Terraform requires versioning in order to encrypt state files with KMS.

---

### Answers & Explanations

**1. B**
*Explanation:* Terraform backend blocks cannot reference input variables, local values, or data sources. This is because the backend must be initialized and configured during `terraform init` before Terraform parses variables or evaluates the resource dependency graph. If dynamic backend values are required, they must be supplied via backend configuration files (`-backend-config=path/to/file.tfvars`) or CLI key-value flags.

**2. B**
*Explanation:* S3 is an object store and does not support native file locking. To provide distributed mutual exclusion (mutex), the Terraform AWS provider uses DynamoDB conditional writes (`PutItem` with `attribute_not_exists(LockID)`). The first process writes its unique lock ID; the second process detects the existing row and halts with `ConditionalCheckFailedException`, protecting the remote state JSON from concurrent write corruption.

**3. B**
*Explanation:* If a process crashes or is killed before it can call DynamoDB's `DeleteItem`, the lock entry remains orphaned in the table. The safe and standard resolution is `terraform force-unlock <Lock-ID>`, passing the ID displayed in the CLI error. You should never leave `-lock=false` in CI/CD, as that permanently disables concurrency protection.

**4. C**
*Explanation:* The Terraform AWS provider specifically looks for a partition key named `LockID` of type `String`. If you name the primary key `id`, `lock_id`, or anything else, DynamoDB will reject the conditional write requests with a schema mismatch error.

**5. C**
*Explanation:* Terraform state is the single source of truth mapping your code to physical cloud infrastructure. Because every successful apply overwrites `terraform.tfstate`, enabling S3 Versioning ensures that AWS retains every previous version of the state JSON. If a state file becomes corrupted or truncated, you can roll back to the previous version object in S3 to recover.
