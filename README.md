# DevOps Coursework

**Course:** SST DevOps & Cloud · **Author:** Abhinav (24BCS10282)

This repository holds all of my DevOps homework, from Linux basics to a complete DevOps project. Every session folder has a `README.md` with explanations, the commands I ran, and screenshots. Command output was recorded from real runs and is saved next to each README (in `evidence/` folders and session transcripts).

## Final project: SpendWise

**[final-devops-project/](final-devops-project/README.md)** is a student expense tracker that I wrote myself: a FastAPI backend, a React frontend and PostgreSQL. It is taken through the whole DevOps life cycle:

- **Tests:** pytest, with a SQLite test database.
- **Docker:** a multi-stage frontend image; both images run as non-root.
- **CI/CD:** a GitHub Actions pipeline with DevSecOps gates (Bandit, CodeQL, pip-audit, npm audit, Gitleaks, Trivy). Images are pushed to GHCR tagged with the commit SHA.
- **Kubernetes and Helm:** a Helm chart (Deployments, StatefulSet + PVC, ConfigMap, Secret, Ingress, HPA, probes, PDB).
- **Monitoring:** Prometheus, Grafana and Alertmanager.
- **GitOps:** Argo CD.
- **Infrastructure:** Terraform for AWS (VPC + EKS).
- **Troubleshooting:** a five-fault troubleshooting challenge.

## Sessions

| Session | Topic | README |
| --- | --- | --- |
| 1 & 2 | Linux fundamentals | [linux-fundamentals](linux-fundamentals/README.md) |
| 3 | Shell scripting | [shell-scripting](shell-scripting/README.md) |
| 4 | Networking | [networking](networking/README.md) |
| 5 | Git & GitHub | [git-and-github](git-and-github/README.md) |
| 6 | Docker fundamentals | [docker-fundamentals](docker-fundamentals/README.md) |
| 7 | Docker images & multi-stage builds | [docker-images](docker-images/README.md) |
| 8 | Docker networking & volumes | [docker-networking](docker-networking/README.md) |
| 9 | Kubernetes basics | [session9-k8s](session9-k8s/README.md) |
| 10 | Pods, ReplicaSets & Deployments | [session10-k8s-core-objects](session10-k8s-core-objects/README.md) |
| 11 | Kubernetes networking & Services | [session-11-kubernetes-services](session-11-kubernetes-services/README.md) |
| 12 | Ingress, ConfigMaps & Secrets | [session-12-ingress-configmaps-secrets](session-12-ingress-configmaps-secrets/README.md) |
| 13 | Storage, HPA & probes | [session-13-storage-hpa-probes](session-13-storage-hpa-probes/README.md) |
| 14 | Kubernetes troubleshooting | [session-14-kubernetes-troubleshooting](session-14-kubernetes-troubleshooting/README.md) |
| 15 | Helm | [session-15-helm](session-15-helm/README.md) |
| 16 | CI/CD & GitHub Actions | [session-16-github-actions](session-16-github-actions/README.md) |
| 17 | Complete CI/CD & DevSecOps | [session-17-devsecops](session-17-devsecops/README.md) |
| 18 | Terraform & Infrastructure as Code | [session18-terraform-iac](session18-terraform-iac/README.md) |
| 19 | Cloud & Terraform in action | [session19-cloud-terraform](session19-cloud-terraform/README.md) |
| 20 | Monitoring, observability & GitOps | [session20-monitoring-observability-gitops](session20-monitoring-observability-gitops/README.md) |
| 21 | Final DevOps project & troubleshooting | [final-devops-project](final-devops-project/README.md) |

## Pipelines

GitHub Actions workflows live in [.github/workflows/](.github/workflows/):

- `session16-ci.yml` and `session16-cd.yml`
- `session17-devsecops.yml`
- `final-devops-project.yml`

Each one runs only when its own folder changes. Runs are listed under the repository's **Actions** tab.

## Tools used

Linux · Bash · Git/GitHub · Docker & Compose · Kubernetes (Minikube, kind, EKS) · Helm · GitHub Actions · GHCR · Trivy · Gitleaks · Bandit · CodeQL · Terraform · AWS · Prometheus · Grafana · Alertmanager · Argo CD

Shared helper scripts are in [scripts/](scripts/):

- [evidence.sh](scripts/evidence.sh) records commands and their output to transcripts.
- [render-evidence-png.py](scripts/render-evidence-png.py) turns a transcript into a screenshot that cites its source lines.
- [capture-webpage.py](scripts/capture-webpage.py) captures a web UI with headless Chrome.
