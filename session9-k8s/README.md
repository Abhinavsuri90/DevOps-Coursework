# Session 9: Kubernetes fundamentals

**Course:** SST DevOps & Cloud · **Author:** Abhinav

These commands were run in a temporary Minikube v1.39.0 / Kubernetes v1.37.0 cluster. The complete observed output is in [cluster-lifecycle.txt](evidence/cluster-lifecycle.txt). The four PNGs below are labeled renders of that real transcript; direct desktop screenshots were not captured.

| Task | One-line description | Exact command | Terminal output | Screenshot |
| --- | --- | --- | --- | --- |
| 1 | Verify the Minikube and kubectl installations. | `minikube version`<br>`kubectl version --client` | Minikube `v1.39.0`; kubectl `v1.37.0` | [01-version-check.png](screenshots/01-version-check.png) |
| 2 | Start the local Kubernetes cluster. | `minikube start --driver=docker --cpus=2 --memory=4096` | `Done! kubectl is now configured to use "minikube" cluster` | [02-minikube-start.png](screenshots/02-minikube-start.png) |
| 3 | Check the control plane and node readiness. | `minikube status`<br>`kubectl get nodes -o wide` | Host, kubelet, API server running; node `Ready` | [03-minikube-status.png](screenshots/03-minikube-status.png) |
| 4 | Stop the cluster and confirm its state. | `minikube stop`<br>`minikube status` | `1 node stopped`; host, kubelet, API server stopped | [04-minikube-stop.png](screenshots/04-minikube-stop.png) |

## Cluster architecture

[Kubernetes' architecture reference](https://kubernetes.io/docs/concepts/architecture/) describes the control plane as the part that maintains desired cluster state and worker nodes as the machines that run Pods.

| Component | Role |
| --- | --- |
| `kube-apiserver` | Exposes the Kubernetes API; kubectl and other components communicate through it. |
| `etcd` | Consistent key-value store for API data and cluster state. Backups are essential. |
| `kube-scheduler` | Assigns unscheduled Pods to suitable nodes based on resources and constraints. |
| `kube-controller-manager` | Runs reconciliation controllers, including Node and ReplicaSet controllers. |
| `kubelet` | Node agent that makes assigned Pods run and reports their status. |
| Container runtime | Runs containers for the kubelet, commonly containerd or CRI-O. |
| `kube-proxy` | Implements Service networking on nodes when that component is used. |

A deployment sent through `kubectl` reaches the API server, which persists the desired state in etcd. Controllers create the needed Pods; the scheduler assigns nodes; each node's kubelet asks its runtime to start containers and reports status through the API. Service traffic reaches healthy Pod endpoints using the cluster's networking implementation. Minikube commonly hosts both control-plane and worker components on one node.

Submit the raw GitHub URL for this file after pushing the completed screenshots and command output.
