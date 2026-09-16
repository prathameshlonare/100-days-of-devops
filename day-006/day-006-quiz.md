# Day 6 — Networking Basics Quiz

**Score: 5/5** ✅

Answer all 5 questions. Type your answers and I'll grade them.

---

### Q1. Multiple Choice

Which command shows all listening TCP ports along with the process names?

A) `netstat -a`
B) `ss -tlnp` [X]
C) `ip link show`
D) `curl -v localhost`

---

### Q2. Command Syntax

Write the curl command to fetch ONLY the HTTP headers (not the body) from `https://api.example.com/health`.
curl -I https://api.example.com/health

---

### Q3. Scenario

Your web application is running on port 8080 but users report it's unreachable. You run `ss -tlnp | grep 8080` and get no output. What does this mean and what should you check next?
it means nothing is listening on 8080, the next step should be the curl to check the http layer/endpoints

---

### Q4. True/False

**Statement:** `dig +short example.com` and `nslookup example.com` return identical output formats.

**Your answer:** True or False? False

**Explain why:** because nslookup gives simpler answer while dig give lots of details but using +short dig gives the ip 

---

### Q5. Fill in the Blank

Complete this command to check the IP address and subnet mask of your network interface:

```
ip addr show eth0
```

---

## Ready to submit?

Type your answers and I'll grade each one with explanations.
