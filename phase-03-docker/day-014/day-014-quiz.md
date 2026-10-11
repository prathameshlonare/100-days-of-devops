# Day 014 Quiz — Networks & Volumes (scenario-heavy)

Answer all 5. Type answers, I grade.

---

1. `ps` shows 3/3 Up. After `down` + `up -d`, votes reset `1` not `5`. `exec backend ls /data` fresh, `exec db ls /data` old. Logs clean. List 3 checks in order, state split-brain evidence, root cause + exact compose fix.

2. `exec frontend nslookup db` resolves `172.x` when it should time out. `compose config` shows frontend on `frontend-net, backend-net`. Explain the security violation, why it resolves, and the one-networks change that restores `frontend -/-> db` while keeping `frontend -> backend -> db`.

3. You run `down -v` on a stateful stack "to be clean". Votes gone, `volume ls` empty. Explain `down` vs `down -v`, why named volume did not save you, and the prevention (doc + CI `config` assert) for prod.

4. Backend `inspect` shows `"Mounts": []` but `volume ls` shows `day14lab_voting-data` exists. `cat compose` shows no `volumes:` under backend. Explain why volume exists yet unused, where writes went (overlay vs volume), and verify command after fix that proves both backend and db see same file.

5. Frontend `curl backend:4000` works via exec, but browser `curl localhost:3000` shows stale `api=http://localhost:4000` from Day 13. Explain why exec works but env is stale, the file to fix (`API_URL`), and the `up -d` vs `up -d --build` rule for env-only vs Dockerfile changes.

---

**Submit with `done day 014` + your 5 answers.**
