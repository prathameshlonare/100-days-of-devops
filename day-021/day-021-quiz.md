# Day 21 Quiz — AWS VPC + Subnet Routing Triage

**5 scenario-heavy questions. Type your answers — I grade and explain. No answers below.**

---

### Question 1 — Scenario Troubleshooting

Your EC2 instance is in a private subnet. You can ping other instances in the same VPC, but `sudo apt update` hangs forever. The security group allows all outbound traffic. The NAT Gateway exists and is in a "Available" state.

What's the first thing you check, and why?

---

### Question 2 — Route Table Analysis

A route table has these entries:

```
Destination       Target
10.0.0.0/16       local
0.0.0.0/0         igw-0abc123
```

This route table is associated with a subnet containing an EC2 instance. Answer:
1. Can instances in this subnet reach other instances in the VPC?
2. Can instances in this subnet reach the internet?
3. Is this a public or private subnet's route table? How do you know?

---

### Question 3 — Root Cause Analysis

A customer deploys a new EC2 instance in a private subnet. They attach an existing NAT Gateway. They can ping internal VPC resources but cannot reach the internet. After investigation, you find the route table has:

```
Destination       Target
10.0.0.0/16       local
```

The NAT Gateway is in a public subnet with a working route to the IGW. What's wrong?

---

### Question 4 — True/False with Explanation

**Statement:** "A NAT Gateway can be placed in a private subnet and still provide internet access to other private subnets."

Is this true or false? Explain why.

---

### Question 5 — Fill in the Blank

Complete this troubleshooting chain for "private-subnet EC2, internal pings work, `curl` times out":

1. SYMPTOM: `curl` times out, internal pings work → narrows to _____ path.
2. CHECK: `aws ec2 describe-route-tables --filters "Name=_____,Values=subnet-xxx"` → look for the _____ route.
3. EXPECTED: private subnet needs `_____ → _____`.
4. VERIFY after fix: `_____ http://example.com` returns 200 and `_____` succeeds.

What goes in each blank, and why?

---

*End of questions — reply with your answers for grading.*
