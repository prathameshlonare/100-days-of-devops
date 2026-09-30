# Day 015 — Dockerfile Best Practices Quiz

Answer all 5 questions. Type your answers and I'll grade them.

**Score: 5/5** ✅

## Question 1: Multiple Choice

What is the primary benefit of multi-stage Docker builds?

A. They make Dockerfiles easier to read
B. They reduce final image size by separating build and runtime stages [X]
C. They automatically optimize network settings
D. They provide built-in security scanning

---

## Question 2: Command Syntax

Write a multi-stage Dockerfile that:
1. Builds a React app using node:18-alpine
2. Copies the build output to nginx:alpine
3. Runs as a non-root user called "appuser"

```
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
RUN adduser -S appuser
COPY --from=builder /app/build /usr/share/nginx/html
USER appuser
```

---

## Question 3: Scenario-Based

Your Dockerfile copies all files before running `npm install`. Every time you change a single line of code, Docker reinstalls all dependencies (taking 2 minutes). How would you optimize this using layer caching?

COPY package*.json ./
RUN npm ci
COPY . .

---

## Question 4: True/False with Explanation

**Statement:** Using `npm ci` instead of `npm install` in a Dockerfile ensures deterministic builds and can reduce rebuild time when only application code changes.

True or False? Explain why.
TRUE
npm ci installs the exact version of dependencies in package-lock.json making builds deterministic, npm ci cached the dependencies and reuse it when only source code changes. 

---

## Question 5: Fill-in-the-Blank

Complete this Dockerfile snippet to add a non-root user and run the app as that user:

```dockerfile
FROM node:18-alpine
RUN adduser -S appuser
WORKDIR /app
COPY . .
RUN npm ci
USER appuser
CMD ["npm", "start"]
```

Why is running as a non-root user important for production containers?
becuase non-root user can not break the code or functionality, whether root user has access to everything and can break things

---

## Bonus Question

Your Docker image is 1.42GB. After implementing multi-stage builds, it's 23MB. List three specific changes you made that contributed to this size reduction.
1. multi stage
2. layered caching and removed build time dependency only copies the build folder 
3. alpine base image 

---

## Answers

Type your answers and I'll grade them. Good luck!
