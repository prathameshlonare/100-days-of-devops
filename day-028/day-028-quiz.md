# Day 28 Quiz — Terraform Workspaces & Cloud Drift Detection

**1. When using Terraform Workspaces with a local backend, where does Terraform store the state file for a workspace named `prod`?**
A) In the root directory as `terraform-prod.tfstate`
B) Inside `.terraform/prod/terraform.tfstate`
C) Inside `terraform.tfstate.d/prod/terraform.tfstate` [x]
D) Overwriting the default `terraform.tfstate` file every time you switch workspaces

**2. A junior engineer logs into the AWS Console and manually adds an inbound rule allowing port 3306 (MySQL) to a Security Group managed by Terraform. No changes are made to the `.tf` files. What happens when someone runs `terraform plan`?**
A) Terraform detects nothing because `main.tf` was not modified.
B) Terraform halts with a fatal syntax error because the cloud state and code state do not match.
C) Terraform refreshes state from the AWS API, detects the rogue port 3306 rule, and plans an in-place update (`~ update in-place`) to remove the manual rule. [x]
D) Terraform automatically commits the port 3306 rule into `main.tf`.

**3. In your Terraform code, you want to provision a `t3.micro` instance in the `dev` workspace, but a `t3.small` instance in the `prod` workspace. Which HCL expression correctly accomplishes this?**
A) `instance_type = var.workspace == "prod" ? "t3.small" : "t3.micro"`
B) `instance_type = terraform.workspace == "prod" ? "t3.small" : "t3.micro"` [x]
C) `instance_type = env.WORKSPACE == "prod" ? "t3.small" : "t3.micro"`
D) `instance_type = lookup(aws_instance.type, terraform.workspace)`

**4. You want to delete the `dev` workspace using the command `terraform workspace delete dev`. However, the CLI returns an error: `Error: Cannot delete current workspace`. How do you resolve this?**
A) Pass the `-force` flag to force-delete the active workspace.
B) Delete the `.terraform` directory and re-run `terraform init`.
C) Switch to a different workspace first (such as `terraform workspace select default`), then run `terraform workspace delete dev`. [x]
D) Workspaces cannot be deleted once created; they can only be renamed.

**5. Why do many enterprise DevOps and platform engineering teams avoid using Terraform Workspaces to separate production and development environments, preferring directory-based or account-based separation instead?**
A) Workspaces do not support AWS provider version 5.0+.
B) Workspaces share the same execution directory and AWS credentials, creating a high-risk blast radius where human error (e.g. running destroy while on the wrong workspace) can take down production. [x]
C) Workspaces cannot deploy VPCs or subnets.
D) Workspaces require a paid Terraform Cloud Enterprise subscription.

---

### Answers & Explanations

**1. C**
*Explanation:* When using local state, Terraform isolates workspace states inside a hidden directory named `terraform.tfstate.d/<workspace-name>/terraform.tfstate`. The root `terraform.tfstate` file is only used by the `default` workspace.

**2. C**
*Explanation:* During `terraform plan`, Terraform's reconciliation engine runs a Refresh phase first: it makes read-only API calls to AWS (`ec2:DescribeSecurityGroups`) to discover physical reality. When it compares the live AWS state with the code in `main.tf`, it recognizes the unmanaged port 3306 rule as architectural drift and plans to remove it (`- ingress`) to restore code compliance.

**3. B**
*Explanation:* `terraform.workspace` is a built-in HCL variable that always evaluates to the string name of the currently active workspace. Ternary operators (`condition ? true_val : false_val`) or map lookups (`lookup(local.types, terraform.workspace)`) are standard methods for dynamic environment sizing.

**4. C**
*Explanation:* Terraform safeguards you from deleting the workspace you are currently standing in. To delete any workspace, you must first switch your active context to another workspace (such as `terraform workspace select default`) and then execute the delete command.

**5. B**
*Explanation:* Workspaces couple all environments to the exact same codebase and terminal context. If an engineer forgets to check `terraform workspace show`, a command intended for `dev` can accidentally wipe out `prod`. Furthermore, true defense-in-depth requires isolating `prod` into a completely separate AWS Account with dedicated IAM roles, preventing dev credentials from having any write access to production.
