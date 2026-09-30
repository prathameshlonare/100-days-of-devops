# Day 8 — Git Basics Quiz

Answer all 5 questions. Type your answers and I'll grade them.

**Score: 5/5** ✅

---

## Question 1 — Multiple Choice

What does `git init` do?

A) Downloads a repo from GitHub
B) Turns a folder into a Git repository [X]
C) Creates a new file called .git
D) Connects your local repo to a remote

---

## Question 2 — Command Syntax

Write the full command to stage all changed files and commit them with the message "update README".
git add .
git commit -m "update README"

---

## Question 3 — Scenario

You edited three files: `index.html`, `style.css`, and `app.js`. You only want to commit changes to `index.html` and `style.css`. What commands do you run?
git add index.html style.css
git commit -m "<message>"

---

## Question 4 — True/False

True or False: After running `git add file.txt`, you can still see the changes with `git diff`.

Explain your answer. False
git stage the file ready to be commited with the commit message, git only shows the unstaged diff file, for staged files git diff --staged, this command has to used 

---

## Question 5 — Fill in the Blank

Run `git log --oneline` and you see:

```
a1b2c3d (HEAD -> master) add notes.txt
e4f5g6h add hello.txt
i7j8k9l first commit
```

The most recent commit is `add hello.txt`. The commit you're currently on is `add notes.txt`.
