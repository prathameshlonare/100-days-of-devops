# Day 019 — Full Pipeline Quiz

Answer these questions. Type your answers and I'll check them.

**Score: 5/5** ✅

---

## Question 1 — Multiple Choice

What does the `exit-code: '1'` flag do in the Trivy action?

A) Exits the pipeline if any vulnerabilities are found (including LOW) [x]
B) Exits the pipeline only if CRITICAL or HIGH vulnerabilities are found 
C) Outputs results as JSON instead of table
D) Skips scanning for unfixed vulnerabilities

---

## Question 2 — Command Syntax

Write the GitHub Actions step that logs into Amazon ECR using the official AWS action:

```yaml
- name: Login to ECR
  id: login-ecr
  uses: aws-actions/amazon-ecr-login@v2
```

Fill in the two blanks.

---

## Question 3 — Scenario

Your Docker build job fails in GitHub Actions. The error is: `denied: The repository does not exist`. What's the most likely cause?

A) The Dockerfile has a syntax error 
B) The ECR repository doesn't exist in your AWS account [x]
C) GitHub Actions doesn't support Docker builds
D) The image tag is too long

---

## Question 4 — True/False

True or False: Using `${{ secrets.AWS_ACCESS_KEY_ID }}` in your workflow file is secure because GitHub encrypts secrets and masks them in logs.

Explain why hardcoding AWS keys in the workflow file is dangerous.
TRUE
because anyone can see the hardcoded any keys and use them to exploit and over use them, that can cause our confidential data to be compromised

---

## Question 5 — Fill in the Blank

The `paths:` trigger in GitHub Actions restricts the workflow to run only when specific files change. Complete this trigger to run only when files in `docker/` or `frontend/` directories change:

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'docker/**'
      - 'frontend/**'
```

---

Type your answers and I'll grade them. Good luck!
