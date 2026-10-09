# Day 013 Quiz — Docker Compose (scenario-heavy)

Answer all 5. Type answers, I grade.

---

1. `docker compose -p day13lab ps` shows both `Up`. `logs frontend` shows `[API-CHECK] FAIL connect ECONNREFUSED 127.0.0.1:4000 url=http://localhost:4000`. Backend logs show nothing. List 3 checks in order, state what each proves, and name root cause + exact one-line fix.

2. You change `API_URL` in `docker-compose.yml` but run `docker compose -p day13lab up -d` without `--build` after editing a Dockerfile. Frontend still shows old behavior. Explain why compose did not rebuild, the difference `up -d` vs `up -d --build`, and the verify command that proves new image is live.

3. Frontend `curl http://backend:4000/api/health` from inside via `exec` returns JSON, but `curl http://localhost:4000/api/health` via same exec refuses. Both services share one compose network. Explain why one works and the other fails, referencing net namespace + `nslookup backend` evidence.

4. You remove `depends_on: [backend]` and cold-start the stack. Frontend log shows one `FAIL` then `OK` on retry, backend is fine. Explain what `depends_on` actually guarantees vs what it does not (health), and one prevention (retry or healthcheck) for production.

5. You run `docker compose -p day13lab up -d` twice with different `-p` names (`day13lab` vs `day13b`). Now `curl localhost:3000` fails with port conflict. Explain why project name isolates networks/containers but host ports still collide, and the fix (down one project or change host port).

---

**Submit with `done day 013` + your 5 answers.**
