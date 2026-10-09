# Day 012 Quiz — Docker Basics (scenario-heavy)

Answer all 5. Type answers, I grade. Scenarios only — no definition recall.

---

1. You run `docker run -d --name day12-lab-run -p 3000:3000 day12-lab-frontend`. `docker ps -a` shows `Exited (1) 4s ago`. `curl http://localhost:3000` fails. List your first 3 checks in order and what each proves. What output confirms app-crash vs port-block?

2. `docker logs day12-lab-run` shows `Error: Cannot find module '/app/serverr.js'`. Your dir has `server.js`. Your Dockerfile ends with `CMD ["node", "serverr.js"]`. What is root cause, exact fix, and why must you rebuild after fixing the Dockerfile instead of `docker exec` into the container?

3. Teammate says "I added `EXPOSE 3000` so `-p` is not needed." You run without `-p`, `docker ps` shows `Up` but `curl localhost:3000` refuses. Explain why Up + refuse happens, the difference `EXPOSE` vs `-p host:container`, and the one command that verifies publish mapping.

4. Your `server.js` listens on `127.0.0.1:3000` inside the container. You run `-p 3000:3000`, container is `Up`, but `curl localhost:3000` gives empty reply. `docker exec <c> netstat -tulpn` shows `127.0.0.1:3000`. What is wrong, why does `0.0.0.0` fix it, and what change + rebuild verifies it?

5. You change one line in `server.js` and rebuild. Build re-runs `npm ci` for 2 min every time because your Dockerfile is `COPY . .` then `RUN npm ci`. Rewrite the 3-line ordering to enable layer caching, explain why `COPY package*.json` first saves time, and state what `npm ci` guarantees over `npm install`.

---

**Submit with `done day 012` + your 5 answers. I grade pass/fail per scenario.**
