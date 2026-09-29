# Day 27 Quiz — Terraform Modules for VPC

**1. Your root `main.tf` calls `module "sg" { source = "./modules/sg" ... }`, but `terraform plan` fails with `Error: Module not installed`. You definitely ran `terraform init`. What is the most likely cause?**
A) The AWS provider version `~> 5.0` is incompatible with modules.
B) `init` was run inside a child directory (e.g. `modules/ec2/`) instead of the root, so the root's module manifest was never written — re-run `terraform init` from `day-27-tf/`. [x]
C) The S3 backend DynamoDB lock table is missing.
D) The `allowed_ssh_cidr` variable has no default.

**2. `terraform apply` fails with `InvalidAMIID.NotFound: The image id '[ami-0abc123]' does not exist` on `module.ec2.aws_instance.this`. `validate` and `plan` were green. What is the root cause and durable fix?**
A) The VPC CIDR overlaps another VPC — pick a new CIDR and re-apply.
B) AMI IDs are regional snapshots; the hardcoded ID has no `eu-north-1` backing (or was deregistered). Fix with a `data "aws_ssm_parameter"` lookup for Canonical Ubuntu inside `modules/ec2`, resolved per region at plan time. [x]
C) The security group blocks SSM — open port 443 in the SG.
D) The instance type `t3.micro` is unavailable in `eu-north-1a` — switch to `m5.large`.

**3. In root `outputs.tf` you write `value = module.vpc.subnet` and `terraform validate` fails with `Error: Unsupported attribute`. The subnet resource exists. What broke?**
A) The `aws_subnet` resource was not created yet — run `apply` first.
B) Root can only read names declared in the child's `outputs.tf` — the child exposes `subnet_id`, not `subnet`, so the reference must be `module.vpc.subnet_id`. [x]
C) Outputs cannot cross module boundaries — copy the subnet resource into root.
D) The `source = "./modules/vpc"` path needs a version argument.

**4. A teammate adds `provider "aws" { region = "us-east-1" }` inside `modules/sg/main.tf` to "make the SG multi-region". What happens?**
A) The SG launches in `us-east-1` while everything else is in `eu-north-1` — flexible multi-region design.
B) Terraform errors or creates provider confusion — child modules must not declare providers; the root owns the provider and children inherit it. Pass region-dependent values as variables instead. [x]
C) The module becomes a registry module automatically.
D) Nothing — duplicate provider blocks are silently merged.

**5. After the SSM fix, a second developer applies the same stack in `eu-north-1` without passing any AMI variable and gets the current Ubuntu 22.04 automatically. Why does this work while the old hardcoded `ami-0deadbeef` failed?**
A) SSM Parameter Store holds a stable parameter *name* Canonical updates per release; the data source resolves the *current* regional ID fresh on every plan, whereas a hardcoded ID is a frozen snapshot tied to one region/build. [x]
B) Data sources skip AWS API calls and reuse the local state cache.
C) `terraform init` downloads all regional AMIs into `.terraform/`.
D) The DynamoDB lock table replicates the AMI across regions.

---

### Answers & Explanations

**1. B**
*Explanation:* `terraform init` installs modules relative to your CWD. Running it in `modules/ec2/` initializes the child, not the root — siblings are never installed and the root manifest is untouched. Fix: `cd` to the root (`day-27-tf/`) and re-run `init`. Never run Terraform from inside `modules/*`; CI `working-directory` must be the root.

**2. B**
*Explanation:* `validate` checks syntax/wiring, `plan` renders config — neither calls EC2 `RunInstances`, so a bogus AMI passes both and dies only at `apply` (400 `InvalidAMIID.NotFound`, prefixed `module.ec2` to scope the fault). AMIs are per-region and get deregistered; the durable fix is `data.aws_ssm_parameter` on Canonical's stable path, owned by the EC2 module so every caller inherits it.

**3. B**
*Explanation:* `module.<label>.<output>` is the ONLY cross-module channel, and `<output>` must exactly match an `output` block in the child's `outputs.tf`. The child exposes `subnet_id`; `subnet` does not exist. Fix the reference, don't duplicate the resource.

**4. B**
*Explanation:* Provider/backend blocks belong to the root only. A provider inside a child either errors or silently fights the root's provider, and it breaks reuse (the module is now pinned to one region). Multi-region belongs in root provider aliases + variables, not in children.

**5. A**
*Explanation:* The SSM name (`/aws/service/canonical/ubuntu/server/22.04/.../ami-id`) is stable across time and regions; Canonical updates its value each release. The data source performs a live `GetParameter` at plan time in the provider's region, so every caller gets the right current ID with zero variables to pass. A hardcoded ID can only ever name one build in one region.
