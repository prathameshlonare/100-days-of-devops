# Day 022 — Notes + Troubleshooting Record

**Date:** 2026-09-15
**Lab:** SG + NACLs Triage (day-022.md)
**Status:** Break-fix Drill A done + verified. Part 8 script skipped (on Windows — run on the box later). Cleanup done 2026-09-15.

## Troubleshooting Record — Day 022

**Problem:** curl to day22-web timed out; localhost returned 200
**Symptoms:**
- Laptop: `curl -v http://13.61.18.78 --max-time 10` → `Trying 13.61.18.78:80...` then `Connection timed out after 10014 milliseconds`, no `Connected` line
- On-box: `curl -s -o /dev/null -w "%{http_code}" http://localhost` → `200`
- SSH OK throughout
**Environment:** AWS eu-north-1 (Stockholm) — lab specifies ap-south-1 Mumbai, rebuild there next time. Scratch VPC day22-lab-vpc, public subnet + IGW, EC2 day22-web (nginx), SG day22-lab-web-sg.
**What I checked:**
1. On-box `curl localhost:80` → 200 (app alive — network filters suspected, not nginx)
2. VPC → Network ACLs → subnet NACL → Outbound rules tab (found 80/443 only, no 1024-65535)
3. EC2 → Security Groups → day22-lab-web-sg → Inbound (80 open — SG clean, confirming NACL)

**Commands used:**
- `curl -v http://13.61.18.78 --max-time 10` (laptop) — Trying, then timeout (reply dropped)
- `curl -s -o /dev/null -w "%{http_code}" http://localhost` (on-box) — 200 (server fine)
- `ss -tulpn | grep 80` — LISTEN confirmed

**Evidence:** Outbound NACL had `100 ALLOW TCP 80` + `110 ALLOW TCP 443` only; no ephemeral row. Implicit `* DENY` dropped the SYN-ACK + HTTP replies (server `:80` → client ephemeral port).
**Hypothesis:** Stateless subnet gate dropping return traffic (ephemeral miss).
**Root Cause:** Hardened NACL allowed service ports but not the ephemeral return range 1024-65535. SG was irrelevant — it auto-allows returns (stateful); the NACL drops them (stateless).
**Fix:** VPC → Network ACLs → Edit outbound rules → restored `ALLOW ALL → 0.0.0.0/0` → Save → waited ~30s.
**Verification:** Laptop `curl -v` → `HTTP/1.1 200 OK` + nginx welcome body; SSH still OK.
**Prevention:** Every NACL change ships with its ephemeral pair both directions + screenshot tabs in notes; prefer SGs for allow-lists, NACLs only for explicit DENY/subnet boundaries.
**What I learned:** Timeout-at-`Trying` with localhost-200 = reply path dead (NACL ephemeral). Timeout-before-connect generally = SG source/route. `curl localhost` splits app vs network in seconds. (Lab text says "Connected then hangs" — my curl prints `Connected` only after handshake completes, and the handshake reply itself needs the ephemeral port, so `Trying`-timeout is the same signature.)

## Side incident (same day, pre-lab): Windows SSH key permissions

- Symptom: `WARNING: UNPROTECTED PRIVATE KEY FILE`, `Load key "...devops key.pem": bad permissions`, then `Permission denied (publickey)`.
- Fix (PowerShell):
  `icacls "<key>.pem" /inheritance:r`
  `icacls "<key>.pem" /grant:r "$($env:USERNAME):(R)"`
- Verify output shows only `<PC>\<user>:(R)`, no `SYSTEM`/`Administrators`/inherited entries. Quote the path (space in filename). If `Permission denied` persists after the warning is gone, the .pem doesn't match the instance's key pair name — check EC2 → Instances → Details → Key pair name.

## TODO

- [ ] Part 8: create + run `sg-nacl-diagnose.sh` on the box (skipped — was on Windows)
- [x] Part 13 cleanup: terminate day22-web → delete SG → disassociate + delete route table → detach + delete IGW → delete subnet → delete VPC; verify zero running instances and VPC gone (done 2026-09-15)
