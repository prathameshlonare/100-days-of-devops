# Day 023 Quiz — IAM + S3 Policy Conflicts

Answer from the lab, not from memory. No answers here — you type, I grade.

---

## Q1 — Scenario troubleshooting

Your incognito lab-user download 403s on `menu.json`, but the Policy Simulator says the same action is Allowed. The bucket policy was edited an hour ago; the IAM user policy is untouched. Name the exact console screen holding the guilty statement and state in one sentence why the two verdicts disagree.

## Q2 — Command/policy syntax

Write the smallest bucket-policy statement that denies `s3:Get*` on `day23-lab-dish-assets-XXXX` (bucket + objects) for every principal EXCEPT requests arriving through `vpce-0abc123`. Include Effect, Principal, Action, Resource, and Condition. Then state the one-line fix you applied in the lab and why deleting the whole statement was acceptable there but not in production.

## Q3 — Root cause

Fresh IAM user, zero policies, tries `GetObject` → 403. No bucket policy exists, no boundary, no SCP. Is this an explicit deny or an implicit deny? What single console action converts it to Allowed for one specific object — and what would over-broadening that action's Resource to `*` risk?

## Q4 — True/False (explain the false ones in one line each)

1. An explicit Deny in a bucket policy overrides an Allow in an IAM user policy for the same action.
2. The IAM Policy Simulator evaluates the bucket policy on your live request path.
3. Attaching a permissions boundary can grant an app access its identity policy doesn't Allow.
4. With Block Public Access all-ON, a bucket policy can still 403 your own IAM users.

## Q5 — Fill in the blank (investigation chain)

Fill the blanks, then state the rule of thumb each blank encodes:

1. Admin `head-object` 404 → the problem is ___ , not a policy.
2. Simulator-Denied → fix the ___ half first (IAM / boundary).
3. Simulator-Allowed + live-403 → read the ___ tab and grep for `"Effect": ___`.
4. Both screens clean but 403 persists → escalate to ___ (boundary / KMS key policy / SCP) in that order.
