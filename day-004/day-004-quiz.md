# Day 4 Quiz — File Permissions

Answer each question. Write your answer below the question.

---

## Q1
You run `ls -l` and see `-rwxr-xr--`. What numeric permission does this equal?

**Your answer:** 754

---

## Q2
What command makes a script executable?

**Your answer:** chmod 777 or chmod +x

---

## Q3
What's the difference between `chmod 644` and `chmod 755`?

**Your answer:** 644 - regular files owner can write, other can read, 755 - scripts, executables owner can write, other can run

---

## Q4
Why does `/etc/shadow` have `640` permissions instead of `644`?

**Your answer:** cause it contains passwords, and only root can read, if 644 then root can write and other can see 

---

## Q5
What command changes file ownership to `www-data:www-data`?

**Your answer:** chown www-data:www-data file

---

## Q6
What does the sticky bit (`t`) do on `/tmp`?

**Your answer:** means use can create files, but only deletes their own and not other, that's why /tmp is safe for everyone

---

## Q7
What is setuid and why does `/usr/bin/passwd` need it?

**Your answer:** when file runs it runs as file owner as root, that's why passwd can change passwords

---

## Q8
You get "Permission denied" on `deploy.sh`. What two commands fix this?

**Your answer:** chmod +x deploy.sh 

---

## Q9
What does `chown -R www-data:www-data /var/www/` do?

**Your answer:** it changes ownership recursively

---

## Q10
What permission should private SSH keys have and why?

**Your answer:** 600

---

## Score
- Total: 9/10
- Grade: A
