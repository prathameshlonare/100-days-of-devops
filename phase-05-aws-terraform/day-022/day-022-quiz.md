# Day 22 Quiz — SG + NACLs Triage

Answer all 5 in your own words. I grade + explain after you reply. Questions only — no answers below.

---

**Q1. Scenario-based troubleshooting (core drill)**
Your Dorm-and-Dish web server: on-box `curl http://localhost` returns `200`, but from your laptop `curl -v http://<public-ip>` prints `Connected to <ip> port 80` and then hangs until timeout. SG allows port 80 inbound. What do you check FIRST, on which exact console screen (Service → Screen → tab), and what missing row are you looking for?

**Q2. Command syntax in context (source-rule drill)**
You SSH into `day22-web` fine, but your teammate's SSH to the same public IP times out. `curl` to port 80 works for both of you. Give the exact console path to the guilty setting, state what its Source column probably shows, and describe the one-line fix.

**Q3. Root cause analysis (stateless vs stateful)**
A teammate hardened the subnet NACL: inbound `ALLOW 80/443/22`, outbound `ALLOW 80/443` — no other rows. SG unchanged (80/443 in, all out). Site hangs + `apt update` fails + SSH works. In two sentences: why does the SG's statefulness NOT save this, and what is the single root cause covering both symptoms?

**Q4. True/False with explanation**
"Security Groups evaluate rules in numeric order like NACLs, and you can add a DENY rule to a Security Group to block one abusive IP while leaving everyone else allowed." True or false? If false, rewrite the statement correctly AND say where the block-a-single-IP rule actually belongs.

**Q5. Fill-in-the-blank investigation chain**
Complete the triage chain for "outside can't reach the box":
`curl localhost` → ___ (what result splits app vs network?) → Route table check (___ route present?) → NACL ___ tab (hang-after-Connected = missing ___ range?) → SG ___ column (timeout-before-connect = wrong ___?) → Verify with ___ + ___ + ___ (three success checks) → Record in ___ format.
