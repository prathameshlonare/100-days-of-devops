# Day 14 — Docker Networking & Volumes Quiz

Answer all 5 questions. Type your answers and I'll grade them.

**Score: 5/5** ✅

1. **Which Docker network type allows containers to reach each other by name?**
   - A) bridge (default)
   - B) host
   - C) Custom network (e.g., `my-network`) [X]
   - D) none

2. **What command creates a named Docker volume called `app-data`?**
docker volume create app-data

3. **You have a React frontend container and a backend API container. The frontend can't reach the backend at `http://backend:4000`. Both are in the same docker-compose.yml. What's the most likely cause?**
   - A) The frontend isn't exposing port 3000
   - B) They're on different Docker networks [X]
   - C) The backend container isn't running
   - D) Docker doesn't support DNS resolution

4. **True or False:** When you stop and remove a Docker container, all files written to the container's filesystem are permanently deleted.
TRUE
5. **Fill in the blank:** A bind mount maps a directory on your host machine to a directory in the container, allowing live code changes without rebuilding the image.

---

## Answers

Type your answers and I'll grade them. Good luck!
