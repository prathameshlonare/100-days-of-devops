# Day 12 Quiz — Docker Basics

Answer these questions. Type your answers and I'll check them.

**Score: 5/5** ✅

---

## Question 1: Multiple Choice

What is the main difference between a Docker image and a Docker container?

A) An image is a running instance; a container is a frozen snapshot
B) An image is a frozen snapshot; a container is a running instance [x]
C) They are the same thing with different names
D) Images are for production; containers are for development

---

## Question 2: Command Syntax

Write the Docker command to:
1. Build an image tagged "my-app" from a Dockerfile in the current directory
2. Run that image in detached mode, mapping port 8080 on your machine to port 3000 in the container, with the container named "my-app-server"

docker build -t my-app .
docker run -d -p 8080:3000 --name my-app-server my-app
---

## Question 3: Scenario

Your Dockerfile has these lines:

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
```

Your friend says the build is slow. They're changing one line of React code and rebuilding. Looking at the Dockerfile, why is each rebuild slow? What would you suggest?
because it does not have cached the build and dependencies, if cached then only the new changes get build and build time would reduce build time, also use multi stage builds file, use .dockerignore 
---

## Question 4: True/False with Explanation

**True or False:** When you run `docker run -p 3000:3000 voting-app`, the number on the left (3000) is the port inside the container, and the number on the right (3000) is the port on your machine.

Explain your answer.
False
because the left side is the HOST-PORT while the right side is the CONTAINER-PORT
---

## Question 5: Fill in the Blank

Complete this Dockerfile to create a multi-stage build that:
1. Builds a React app in the first stage (named "builder")
2. Copies only the built files to a second stage using nginx:alpine
3. Exposes port 80

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

**Submit your answers and I'll grade them.**
