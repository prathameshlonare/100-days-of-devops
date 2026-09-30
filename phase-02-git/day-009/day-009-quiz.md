# Day 9 — Branching & Merging Quiz

Answer all 5 questions. Type your answers and I'll grade them.

**Score: 5/5** ✅

---

## Question 1 — Multiple Choice

What does `git checkout -b feature-login` do?

A) Switches to the `feature-login` branch
B) Creates a new branch called `feature-login`
C) Creates a new branch AND switches to it in one step [X]
D) Merges `feature-login` into the current branch

---

## Question 2 — Command Syntax

Write the exact command sequence to:
1. Create a branch called `fix-timeout` - git branch fix-timeout
2. Switch to it - git switch fix-timeout
3. Then switch back to `main` - git checkout main

---

## Question 3 — Scenario

You're on `main`. You create a branch called `feature-api`, add a file `api.md`, and commit it. Meanwhile, another developer adds `api.md` on `main` with different content. You try to merge `feature-api` into `main`. What happens?
there will be merge conflict
---

## Question 4 — True/False

True or False: Deleting a branch with `git branch -d feature-xyz` also deletes all the commits that were on that branch.

Explain your answer. False
only deletes the pointer and not the commits, can be recovered by reflog, or commit hash

---

## Question 5 — Fill in the Blank

Run `git branch` and you see:

```
  feature-dashboard
  feature-login
* main
```

The branch you're currently on is `main`. The branches available but not checked out are `feature-login` and `feature-dashboard`.
