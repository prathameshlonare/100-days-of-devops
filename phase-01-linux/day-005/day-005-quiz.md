# Day 5 — Process Management Quiz

## Question 1 — Multiple Choice
Which command shows all running processes with CPU and memory usage?

A) `ps -ef`
B) `ps aux` [X]
C) `top -b` 
D) `systemctl list`

---

## Question 2 — Command Syntax
Write the command to kill process with PID 4523 gracefully (allow it to clean up).
kill 4523

---

## Question 3 — Scenario
Your web server is using 99% CPU and the site is unresponsive. Write the exact commands you'd run in order to:
1. Find the process - ps aux --sort=-%cpu
2. Kill it - kill pid 
3. Restart the service - systemctl restart service name 

---

## Question 4 — True/False
True or False: You should always use `kill -9` to stop a misbehaving process.

Explain your answer.
False, use only if process is not gracefully shutdown with cleanup

---

## Question 5 — Fill in the Blank
To run a process in the background that continues even after you log out, use `nohup long-running-command &`.

---

**Score: 5/5** ✅

Type your answers and I'll grade them.
