# Trivy — Quick Crash Course

> Trivy is an open-source security scanner by Aqua Security. It scans Docker images, filesystems, and repos for known vulnerabilities (CVEs), misconfigurations, and secrets.

---

## Why Trivy in DevOps?

Your Docker image uses `node:18-alpine`. That image has OS packages and dependencies — each with potential security holes. Trivy finds them before you deploy to production.

**Without Trivy:** Ship images with known CVEs → get hacked.
**With Trivy:** Scan in CI/CD → block deploys with critical vulns → sleep better.

---

## Install

```bash
# macOS
brew install trivy

# Ubuntu/Debian
sudo apt-get install trivy

# Run without install (Docker)
docker run --rm aquasec/trivy image node:18-alpine
```

---

## Core Commands

### Scan a Docker Image

```bash
trivy image node:18-alpine
```

Output:
```
node:18-alpine (debian 12.4)

Total: 156 (UNKNOWN: 0, LOW: 98, MEDIUM: 42, HIGH: 14, CRITICAL: 2)

┌────────────────┬──────────────┬──────────┬─────────────────┬───────────┬──────────────────────────────┐
│    Library     │ Vulnerability │ Severity │    Installed    │  Fixed    │           Title              │
├────────────────┼──────────────┼──────────┼─────────────────┼───────────┼──────────────────────────────┤
│ libssl3        │ CVE-2024-xxx │ CRITICAL │ 3.0.11          │ 3.0.13    │ OpenSSL: buffer overflow     │
└────────────────┴──────────────┴──────────┴─────────────────┴───────────┴──────────────────────────────┘
```

### Scan with Severity Filter

```bash
# Only show HIGH and CRITICAL
trivy image --severity HIGH,CRITICAL node:18-alpine
```

### Scan a Local Filesystem

```bash
# Scan current directory (Dockerfile, package.json, etc.)
trivy fs .

# Scan for misconfigurations
trivy config .
```

### Output Formats

```bash
# Human-readable table (default)
trivy image --format table node:18-alpine

# Machine-readable JSON
trivy image --format json node:18-alpine

# CSV for spreadsheets
trivy image --format csv node:18-alpine
```

---

## Key Flags Reference

| Flag | What it does | Example |
|------|-------------|---------|
| `image-ref` | Which image to scan | `trivy image nginx:latest` |
| `--severity` | Filter by severity | `--severity HIGH,CRITICAL` |
| `--exit-code` | Exit code on findings | `--exit-code 1` (fail on vulns) |
| `--ignore-unfixed` | Skip vulns with no fix | `--ignore-unfixed` |
| `--format` | Output format | `--format json` |
| `--output` | Save to file | `--output results.json` |
| `--timeout` | Scan timeout | `--timeout 5m` |
| `--vuln-type` | Filter vuln types | `--vuln-type os,library` |

---

## Severity Levels

| Level | What it means | Action |
|-------|--------------|--------|
| CRITICAL | Remote code exec, data leak | Block deploy immediately |
| HIGH | Significant security risk | Block deploy, fix ASAP |
| MEDIUM | Limited impact | Fix in next sprint |
| LOW | Minimal risk | Track, fix when convenient |
| UNKNOWN | Can't determine severity | Review manually |

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | No vulnerabilities found (or below threshold) |
| 1 | Vulnerabilities found (when `--exit-code 1`) |
| 2 | Trivy error (timeout, invalid image, etc.) |

**In CI/CD:** Use `exit-code: 1` to fail the pipeline when vulns are found.

---

## Trivy in GitHub Actions

```yaml
security-scan:
  name: Security Scan
  needs: [build]
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Run Trivy
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ secrets.AWS_REGISTRY }}/my-app:${{ github.sha }}
        format: 'table'
        exit-code: '1'
        severity: 'CRITICAL,HIGH'
        ignore-unfixed: true
```

### What Each Parameter Does

| Parameter | Value | Why |
|-----------|-------|-----|
| `image-ref` | ECR image URI | Scan the image we just built |
| `format` | `table` | Human-readable in CI logs |
| `exit-code` | `1` | Fail pipeline if vulns found |
| `severity` | `CRITICAL,HIGH` | Don't block on low/medium |
| `ignore-unfixed` | `true` | Skip vulns with no available fix |

---

## Common Use Cases

### 1. Block Critical Vulnerabilities

```bash
trivy image --exit-code 1 --severity CRITICAL my-app:latest
```
Pipeline fails only if CRITICAL vulns exist.

### 2. Scan Before Push

```bash
# Build
docker build -t my-app:latest .

# Scan locally before pushing
trivy image --exit-code 1 --severity HIGH,CRITICAL my-app:latest

# Only push if scan passes
docker push my-app:latest
```

### 3. Scan Dockerfile for Misconfigurations

```bash
trivy config ./Dockerfile
```
Finds things like running as root, hardcoded secrets, outdated base images.

### 4. Generate Report for Compliance

```bash
trivy image --format json --output trivy-report.json my-app:latest
```
Save JSON report for audit/compliance purposes.

---

## Trivy vs Other Scanners

| Feature | Trivy | Snyk | Docker Scout |
|---------|-------|------|-------------|
| Open source | ✅ Yes | ❌ Freemium | ❌ Docker-only |
| Scan images | ✅ | ✅ | ✅ |
| Scan filesystem | ✅ | ✅ | ❌ |
| Scan IaC (Terraform) | ✅ | ✅ | ❌ |
| CI/CD integration | ✅ Excellent | ✅ Good | ✅ Good |
| Speed | Fast | Medium | Fast |
| Free tier | Unlimited | 100 tests/mo | Limited |

---

## Interview Questions

**Q: Why scan images in CI/CD instead of locally?**
A: CI/CD ensures every image is scanned consistently. Local scans can be skipped accidentally. Automated gates prevent vulnerable images from reaching production.

**Q: What does `ignore-unfixed: true` mean?**
A: Skip vulnerabilities that don't have a fix yet. No point blocking a deploy for something nobody can fix — track it separately.

**Q: What's the difference between `trivy image` and `trivy fs`?**
A: `trivy image` scans a built Docker image (OS packages + app dependencies). `trivy fs` scans a directory (source code, Dockerfile, package.json) for misconfigurations and secrets.

**Q: How would you handle a CRITICAL vulnerability with no fix?**
A: Use `ignore-unfixed: true` in CI, but create a ticket to track it. Monitor for fix availability. Consider alternative base images if possible.

---

## Quick Reference Card

```bash
# Scan image
trivy image <image-name>

# Scan with severity filter
trivy image --severity HIGH,CRITICAL <image-name>

# Fail pipeline on vulns
trivy image --exit-code 1 --severity CRITICAL <image-name>

# Scan filesystem
trivy fs .

# Scan Dockerfile
trivy config ./Dockerfile

# JSON output
trivy image --format json <image-name>

# Save to file
trivy image --output results.json <image-name>
```
