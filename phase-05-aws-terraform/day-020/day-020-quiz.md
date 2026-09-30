# Day 20 Quiz — AWS EC2 + SSH

---

## Q1. Scenario — SSH Timeout

You launch a new EC2 instance (Ubuntu 22.04, t2.micro). The instance shows "Running" in the console. You try to SSH:

```
ssh -i ~/.ssh/my-key.pem ubuntu@54.123.45.67
```

After 30 seconds, you get: `ssh: connect to host 54.123.45.67 port 22: Connection timed out`

You then try:
```
ping -c 2 54.123.45.67
```

Ping works. What's the most likely cause?

A) The SSH service isn't running on the instance
B) The key pair file has wrong permissions
C) The Security Group doesn't allow inbound SSH (port 22) [x]
D) The instance is in a private subnet 

---

## Q2. Command Syntax — SSH Connection

Write the full SSH command to connect to an EC2 instance with:
- Private key at `C:\Users\me\.ssh\dorm-key.pem`
- Username: `ubuntu`
- Public IP: `34.201.100.50`

-> ssh -i C:\Users\me\.ssh\dorm-key.pem ubuntu@34.201.100.50

---

## Q3. Scenario — Security Group Rules

Your Security Group has these inbound rules:
1. SSH (22) — Source: `My IP`
2. HTTP (80) — Source: `0.0.0.0/0`

A friend in another city wants to check your website. They open `http://34.201.100.50` in their browser. Does it work? Why or why not?
yes, cause we have set http (80) to 0.0.0.0/0 that means anyone from internet can access our website

---

## Q4. True/False — Security Groups

**Statement:** If a Security Group blocks inbound traffic on port 22, the SSH client will immediately receive a "Connection refused" error.

**True or False?** Explain in one sentence.
False - port is open but nothing is listening on it

---

## Q5. Fill-in-the-Blank — EC2 Launch

Complete the EC2 launch configuration:

| Setting | Value |
|---------|-------|
| AMI | ubuntu 22.04 LTS (OS for Dorm-and-Dish) |
| Instance Type | t3.micro (free tier eligible) |
| Key Pair | dorm-and-dish.pem (your SSH key) |
| Security Group | Inbound: port 22 from My IP, port 80 from 0.0.0.0/0 |
| Auto-assign Public IP | enable |

---
