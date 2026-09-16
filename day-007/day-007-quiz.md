# Day 7 — Week 1 Review Quiz

Test your knowledge from Days 1-6. Answer all 5 questions, then check with me.

**Score: 5/5** ✅

---

## Question 1: Multiple Choice

Which command shows the top 10 memory-consuming processes?

A) `ps aux --sort=-%cpu | head -11` 
B) `ps aux --sort=-%mem | head -11` [x]
C) `top -n 10`
D) `free -h`

---

## Question 2: Command Syntax

Write the command to:
1. Find all `.log` files in `/var/log` that are larger than 10MB - find /var/log -name "*.log" -size +10M
2. Check if port 80 is listening on your server - ss -tlnp | grep :80

---

## Question 3: Scenario-Based

You SSH into a server and run `curl -I http://localhost:8080` but get "Connection refused."

What steps would you take to diagnose this? List at least 3 commands you'd run.
ss -tlnp | grep :8080
systemctl status <service-name>
journalctl -u <service-name> --no-pager -n 20
curl -I http://localhost:8080

---

## Question 4: True/False

**Statement:** "The command `chmod 755 script.sh` gives the owner read, write, and execute permissions, while group and others get read and execute only."

Is this TRUE or FALSE? Explain why.
TRUE


---

## Question 5: Fill-in-the-Blank

Complete this command to restart the nginx service and make it start automatically on boot:

```bash
sudo systemctl restart nginx
sudo systemctl enable nginx
```

---

## Answers

Type your answers and I'll check them. Good luck!
