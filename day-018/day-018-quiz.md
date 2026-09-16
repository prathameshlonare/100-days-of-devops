# Day 018 — GitHub Actions Basics Quiz

Answer these questions. Type your answers and I'll check them.

**Score: 5/5** ✅

---

## Question 1 — Multiple Choice

In GitHub Actions, what does the `needs` keyword do?

A) Specifies which runner to use
B) Defines job dependencies — one job waits for another to finish [x]
C) Sets environment variables
D) Triggers the workflow manually

---

## Question 2 — Command Syntax

Write a GitHub Actions step that runs `npm test` with the environment variable `NODE_ENV` set to `test`:

```yaml
- run: npm test
  env:
    NODE_ENV: test
```

Fill in the two blanks.

---

## Question 3 — Scenario

Your workflow has three jobs: lint, test, and build. You want build to run only if both lint AND test pass. How do you configure this?

A) Put build before lint and test
B) Add `needs: [lint, test]` to the build job 
C) Add `if: success()` to the build job
D) Both B and C [x]

---

## Question 4 — True/False

True or False: The `actions/checkout@v4` action clones your repository to the GitHub Actions runner, so subsequent steps can access your code.

Explain why this step is necessary.
TRUE
to run the code and perform the steps written in ci/cd pipeline

---

## Question 5 — Fill in the Blank

Complete this workflow trigger to run on:
1. Push to the `main` branch
2. Pull requests targeting the `main` branch

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

---

Type your answers and I'll grade them.
