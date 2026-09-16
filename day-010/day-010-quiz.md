# Day 10 — Remote & Collaboration Quiz

Answer all 5 questions. Type your answers and I'll grade them.

**Score: 4/5** ✅

---

## Question 1 — Multiple Choice

What does `git pull origin main` do?

A) Downloads changes from GitHub but does NOT merge them
B) Uploads your local commits to GitHub
C) Downloads changes from GitHub AND merges them into your local branch [X]
D) Creates a copy of the repo on your desktop

---

## Question 2 — Command Syntax

Write the command to:
1. Connect your local repo to a GitHub remote
2. Push your `main` branch for the first time with upstream tracking

git remote add origin <github-remote-url>
git push -u origin main
---

## Question 3 — Scenario

You cloned a repo yesterday. Today, your teammate pushed 3 new commits. You want to see what they changed BEFORE you merge anything.

What commands do you run?
git fetch origin
git log main..origin/main --oneline
git diff main origin/main
---

## Question 4 — True/False

**Statement:** "After creating a Pull Request on GitHub, you can merge it directly from the terminal without going to the GitHub website."

Is this TRUE or FALSE? Explain.
TRUE
merge can be directly done from terminal using Github CLI GH
---

## Question 5 — Fill in the Blank

Complete these commands:

```bash
# Delete a branch after it's been merged (safe):
git branch -d <branch-name>

# Force delete a branch that is NOT merged (dangerous):
git branch -D <branch-name>
```

---

## Answers

Type your answers and I'll grade them. Good luck!
