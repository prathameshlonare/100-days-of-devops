# Day 11 — Git Review Quiz

Answer all 5 questions. Type your answers and I'll grade them.

**Score: 5/5** ✅

---

## Question 1 — Multiple Choice

You merged a feature branch. What's the correct next step?

A) Leave the branch — you might need it later
B) Delete the remote branch, then pull locally [X]
C) Push to main directly
D) Create a new branch from the old one

---

## Question 2 — Command Syntax

Write the command to create a branch called `feature/add-auth` from `main` and switch to it:
git switch -c feature/add-auth main
---

## Question 3 — Scenario

You're working on Online-voting-system. You pushed 3 commits to `feature/voting-page` and opened a PR. The commits are:
1. "fix stuff"
2. "add voting page"
3. "remove console.log"

Which merge strategy should you use and why?
squash and merge, cause this will combined all 3 into one commit, and our main branch commit history will remain clean

---

## Question 4 — True/False

True or False: You should never delete a branch after merging because the code might be needed later.

Explain your answer. False
because the changes of the branch is now part of the main branch, and is safe to delete 

---

## Question 5 — Fill in the Blank

Complete the branching workflow:

```
git checkout main → git pull origin main → git checkout -b feature/our-feature
```

---

## Answers

Type your answers and I'll grade them. Good luck!
