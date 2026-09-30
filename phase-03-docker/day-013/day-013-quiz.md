# Day 13 — Practice Quiz: Docker Compose

**Score: 5/5** ✅

## Question 1: Multiple Choice

What does `docker compose down` do compared to `docker compose stop`?

A. It stops containers but keeps them for restart 
B. It stops containers AND removes them, along with networks created by the compose file [x]
C. It only removes networks, not containers
D. It restarts all containers

---

## Question 2: Command Syntax

Write the docker compose command to:
1. Start all services in the background - docker compose up -d
2. View live logs from only the `backend` service - docker compose logs backend
3. Drop into a shell inside the running `frontend` container - docker compose exec frontend sh

---

## Question 3: Scenario-Based

Your `docker-compose.yml` defines three services: `frontend`, `backend`, and `database`. You run `docker compose up -d` and check with `docker compose ps`. The frontend and backend show "Up" but the database shows "Exit 1".

What steps would you take to diagnose why the database failed to start?
docker compose logs database
docker compose logs --tail=100 database
docker compose ps -a
docker inspect database

---

## Question 4: True/False with Explanation

**Statement:** If you define `depends_on: backend` in the `frontend` service, Docker Compose guarantees that the backend's application (not just the container) is ready to accept connections before starting the frontend.

True or False? Explain why.
False
it does not guarantees the readiness, it means that backend starts before frontend, depends on gurantees the startup order
---

## Question 5: Fill-in-the-Blank

Complete this docker-compose.yml snippet so that the `backend` service gets its configuration from an external file:

```yaml
services:
  backend:
    build: ./backend
    ports:
      - "4000:4000"
    env_file:
      - ./backend/.env
```

What is the filename format that Docker Compose expects by default when you use this directive?

---

## Bonus Question

Your team has two compose files: `docker-compose.yml` for development and `docker-compose.prod.yml` for production. How do you run the production compose file without manually merging them?
