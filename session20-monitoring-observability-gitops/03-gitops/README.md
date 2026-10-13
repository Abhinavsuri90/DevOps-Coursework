# GitOps with Argo CD

**Session 20 · Task 3** · Author: Abhinav (24BCS10282)

## What is GitOps?

GitOps is a way of operating infrastructure and applications where **the desired state of the system is declared in Git**, and an automated agent running in the cluster **continuously makes the live state match Git**. Deployments happen by changing Git (commit, pull request, merge) rather than by running `kubectl apply` or a deploy script against production.

The OpenGitOps principles:

1. **Declarative:** the whole system is described as desired state (YAML, Helm values, Kustomize), not as a list of steps.
2. **Versioned and immutable:** that description is stored in Git, which gives history, review, and a revert for every change.
3. **Pulled automatically:** an agent in the cluster pulls the desired state. CI does not push credentials into the cluster.
4. **Continuously reconciled:** the agent keeps comparing desired and actual state and corrects any drift.

## Git as the source of truth

- **One place to look:** what is running equals what is on the `main` branch of the config path.
- **Audit trail:** `git log` shows who changed what and when, and why (commit message, PR).
- **Review before production:** changes go through pull requests and checks.
- **Rollback = `git revert`:** the agent rolls the cluster back to the previous commit's state.
- **Disaster recovery:** a new cluster plus the same Git repo rebuilds the same system.

In this demo the desired state is [`app/`](app/) in **github.com/Abhinavsuri90/DevOps-Coursework**, and the Argo CD `Application` ([argocd-application.yaml](argocd-application.yaml)) points at that path on `main`.

## Declarative configuration

[`app/`](app/) contains only *what* should exist: a Namespace, a ConfigMap with the page, a Deployment with `replicas: 2`, and a Service. There are no imperative steps. Kubernetes controllers and Argo CD work out *how* to get there.

## Continuous reconciliation

```mermaid
flowchart LR
    Dev[Developer] -->|git commit + push| Git[(GitHub repo: app/)]
    Git -->|poll every 60s or webhook| Argo[Argo CD application-controller]
    Argo -->|compare desired vs live| Diff{In sync?}
    Diff -->|OutOfSync| Apply[Apply the changes]
    Apply --> K8s[(Kubernetes API)]
    Diff -->|Synced| Wait[wait for next poll]
    K8s -->|live state| Argo
    Ops[Someone runs kubectl scale] -.->|drift| K8s
```

- **Sync:** apply Git's state to the cluster.
- **Self-heal** (`selfHeal: true`): if someone changes the live state by hand, Argo CD puts it back to match Git.
- **Prune** (`prune: true`): resources deleted from Git are deleted from the cluster.

## GitOps workflow

```text
1. Developer changes app/deployment.yaml (e.g. replicas 2 -> 3) on a branch
2. Pull request -> review -> CI validates the manifests
3. Merge to main
4. Argo CD notices the new commit (poll or webhook) -> OutOfSync
5. Argo CD applies the change -> Synced / Healthy
6. If anyone edits the cluster directly, Argo CD reverts it (self-heal)
7. Rollback = git revert <commit> -> Argo CD syncs the previous state
```

In the final project, CI builds and pushes an image tagged with the commit SHA, then commits the new tag to the GitOps values file, and Argo CD deploys it. CI never needs cluster credentials.

## Kubernetes + GitOps

| Tool | Notes |
| --- | --- |
| **Argo CD** | Web UI and CLI, `Application`/`AppProject` CRDs, health assessment, sync waves, multi-cluster (used here) |
| Flux CD | Set of controllers (`GitRepository`, `Kustomization`, `HelmRelease`), CNCF graduated |
| Argo Rollouts / Flagger | Progressive delivery (canary, blue-green) on top of GitOps |

Argo CD's main components are the **repo-server** (clones Git and renders manifests from Helm, Kustomize or plain YAML), the **application-controller** (compares and syncs), the **API server and UI**, and **Redis** (cache).

## Files

| File | Purpose |
| --- | --- |
| [argocd-values.yaml](argocd-values.yaml) | Small Argo CD install: no Dex/notifications/ApplicationSet, 60 s Git polling, read-only anonymous UI for local screenshots |
| [argocd-application.yaml](argocd-application.yaml) | `Application` gitops-demo → this repo, path `session20-monitoring-observability-gitops/03-gitops/app`, automated sync with prune and self-heal |
| [app/](app/) | The desired state that Argo CD syncs |
