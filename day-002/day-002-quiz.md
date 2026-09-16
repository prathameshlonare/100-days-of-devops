# Day 2 Quiz — Linux File System

Answer each question. Write your answer below the question.

---

## Q1
You need to edit the Nginx config. Which directory do you look in?

**Your answer:** /etc/nginx/

---

## Q2
Your server is running out of disk space. What command shows you which directories are eating the most space?

**Your answer:** du -sh /*

---

## Q3
What's the difference between `/bin` and `/usr/bin`?

**Your answer:** /bin has essential binary files /usr/bin has user binaries

---

## Q4
You want to check how much RAM your server has. Which virtual directory do you cat?

**Your answer:** cat /proc/meminfo

---

## Q5
Run `ls -la /home`. What does the `.` entry mean? What does `..` mean?

**Your answer:** . - current directory and .. - parent directory

---

## Q6
Where are log files stored? Name 2 files you'd find there.

**Your answer:** cd /var/log/ 1. syslog, 2. alternatives.log   

---

## Q7
What's inside `/proc`? Is it real files on disk?

**Your answer:** process, yes it is not real files on disk

---

## Q8
You find a file at `/tmp/upload_12345.csv`. Why might this file disappear?

**Your answer:** because it is inside temporary

---

## Q9
Where do you find the `passwd` file? What's in it?

**Your answer:** cd /etc/passwd, account info, user id, username

---

## Q10
You want to see all config files in `/etc` that contain the word "ssh". What command do you run?

**Your answer:**  grep -r "ssh" /etc/

---

## Score
- Total: 9.5/10
- Grade: A
