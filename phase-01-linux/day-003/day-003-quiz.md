# Day 3 Quiz — Linux Commands

Answer each question. Write your answer below the question.

---

## Q1
You want to recursively search for the text "error" in all files under `/var/log`. What command do you run?

**Your answer:** grep -r "error" /var/log/

**✅ Correct** — `grep -r` searches recursively

---

## Q2
You need to find all `.sh` files in the current directory and subdirectories. What command?

**Your answer:** find . -name "*.sh" 

---

## Q3
What does the pipe `|` do in `cat file | grep error`?

**Your answer:** cat -> grep

---

## Q4
You want to see the last 50 lines of `/var/log/syslog` and follow new lines as they're added. What command?

**Your answer:** tail -f -n 50 /var/log/syslog

---

## Q5
What's the difference between `>` and `>>` when redirecting output?

**Your answer:** > - redirect, >> - append

---

## Q6
You have a script `deploy.sh` that says "Permission denied" when you run it. What command fixes it?

**Your answer:** chmod 700 deploy.sh

---

## Q7
How do you search your command history for a command containing "docker"?

**Your answer:**  history | grep "docker"

---

## Q8
What does `du -sh /var/log` show you?

**Your answer:** size of the /var/log location 

---

## Q9
You want to create directories `a/b/c/d` in one command. What flag do you use with `mkdir`?

**Your answer:** mkdir -p a/b/c/d

---

## Q10
What does `ps aux | grep nginx` show you?
 
**Your answer:** processes related to nginx

---

## Score
- Total: 7.5/10
- Grade: B