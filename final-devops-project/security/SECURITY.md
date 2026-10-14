# Security controls (DevSecOps)

| Control | Tool | Where | Gate |
| --- | --- | --- | --- |
| SAST (Python) | Bandit 1.9.4 | CI `sast` job | Fails on medium or high severity |
| SAST (Python + JavaScript) | GitHub CodeQL | CI `sast` job | Results in GitHub Security > Code scanning |
| SCA (Python deps) | pip-audit 2.10.1 | CI `sca` job | Fails on any known vulnerability |
| SCA (npm deps) | npm audit | CI `sca` job | Fails on high or critical |
| SCA (lock files) | Trivy fs 0.74.0 | CI `sca` job | Fails on fixable HIGH/CRITICAL |
| Secret scanning | Gitleaks 8.30.1 | CI `secret-scan` job | Fails on any finding |
| Container image scanning | Trivy image 0.74.0 | CI `build-images` job | Fails on fixable HIGH/CRITICAL |
| Security gate | `security-gate` job | CI | Images are pushed only if every check above passed |

Hardening in the images and manifests:

- Non-root users (backend uid 10001, nginx uid 101, PostgreSQL uid 70); `runAsNonRoot` is enforced in Kubernetes.
- `readOnlyRootFilesystem`, `allowPrivilegeEscalation: false`, all Linux capabilities dropped, `seccompProfile: RuntimeDefault`.
- pip is removed from the backend runtime image (it bundles libraries scanners flag, and is not needed after install).
- No secrets in Git: the DB password is generated at deploy time (`kubernetes/create-db-secret.sh`, `docker/.env` is git-ignored), and CI uses the short-lived `GITHUB_TOKEN`.
- Image tags are commit SHAs (immutable, traceable), never `latest`.
