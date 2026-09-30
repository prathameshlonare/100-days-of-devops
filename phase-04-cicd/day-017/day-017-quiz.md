# Day 017 — CI/CD Concepts Quiz

Answer these questions. Type your answers and I'll check them.

**Score: 5/5** ✅

---

## Question 1 — Multiple Choice

What is the difference between Continuous Delivery and Continuous Deployment?

A) They are the same thing
B) Delivery requires manual approval before deploy; Deployment is fully automated [X]
C) Delivery is for staging; Deployment is for production
D) Delivery runs tests; Deployment builds images

---

## Question 2 — Command Syntax

Write the GitHub Actions trigger that runs a pipeline on every push to the `main` branch:

```yaml
on:
  push:
    branches: [main]
```

Fill in the three blanks.

---

## Question 3 — Scenario

Your pipeline fails at the "Test" stage. The lint stage passed. What should happen next?

A) Skip the test stage and continue to build
B) Retry the test stage automatically
C) Stop the pipeline — don't build or deploy [x]
D) Deploy anyway with a warning

---

## Question 4 — True/False

True or False: In a CI/CD pipeline, the "Build" stage should run before the "Test" stage because you need to build the app before you can test it.

Explain your answer.
TRUE
because for testing the application we need build artifacts

---

## Question 5 — Fill in the Blank

The four stages of a typical CI/CD pipeline, in order, are:

1. Lint
2. Test
3. Build
4. Deploy

---

Type your answers and I'll grade them. Good luck!
