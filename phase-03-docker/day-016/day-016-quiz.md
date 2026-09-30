# Day 016 — Phase 3 Milestone Quiz: Docker & Containers Complete

Answer all 5 questions. Type your answers and I'll grade them.

**Score: 5/5** ✅

## Question 1: Multiple Choice

In a docker-compose.yml with network isolation, which statement is true?

A. All services can reach all other services by default
B. Frontend can reach DynamoDB directly if they're in the same compose file
C. Services on different custom networks cannot communicate unless explicitly connected [X]
D. Docker networks only work with Docker Swarm, not standalone Docker

---

## Question 2: Command Syntax

Write the docker compose commands to:
1. Start all services in production mode using the production compose file
2. Verify all containers are running
3. Check which network the backend service is connected to

docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml ps
docker inspect <backend-container-name> 

---

## Question 3: Scenario-Based

Your docker-compose.yml defines three services: `frontend`, `backend`, and `dynamodb`. You've set up network isolation with `frontend-net` and `backend-net`. The frontend can't reach the backend anymore.

What's the most likely cause, and how would you fix it?
frontend and backend are isolated on seperate networks, attach backend to both frontend-net and backend-net, frontend -> backend -> backend -> dynamodb

---

## Question 4: True/False with Explanation

**Statement:** When you run `docker compose down` (without `-v` flag), named volumes are preserved and data survives the next `docker compose up`.

True or False? Explain why.
TRUE
docker compose down preserves name volumes by default, i.e. -v flag is used for named volume removal

---

## Question 5: Fill-in-the-Blank

Complete this multi-stage Dockerfile snippet so that the final image uses nginx instead of node:

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
```

What is the size difference between a typical node:18 image and nginx:alpine image?
node:18 - GBs
nginx:alpine - MBs

---

## Bonus Question

Your team has two compose files: `docker-compose.yml` for development and `docker-compose.prod.yml` for production. The production file overrides the frontend service to use a multi-stage Dockerfile.

How do you run the production compose file without manually merging them? Write the exact command.
docker compose -f docker/docker-compose.prod.yml up -d


---

## Answers

Type your answers and I'll grade them. Good luck!
