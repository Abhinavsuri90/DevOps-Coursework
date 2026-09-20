# Session 10: Kubernetes core objects and deployment strategies

Run from the repository root with an active Minikube cluster. The `.yaml` and `.yml` files use JSON syntax, which is valid YAML and accepted by `kubectl`. Actual run output is in [evidence](evidence/), with [PNG renders of recorded output](screenshots/README.md). Direct desktop screenshots were not captured. The intentionally invalid selector manifest is expected to fail API validation.

## 1. Cluster baseline

```bash
minikube start
kubectl version --output=yaml
kubectl cluster-info
kubectl get nodes -o wide
```

Confirm the node is `Ready` and the API and CoreDNS addresses are shown.

## 2–4. Pods, image errors, and transient phases

```bash
kubectl apply -f session10-k8s-core-objects/pod.yml
kubectl wait --for=condition=Ready pod/nginx --timeout=120s
kubectl get pod nginx -o wide
kubectl logs nginx
kubectl delete -f session10-k8s-core-objects/pod.yml

kubectl apply -f session10-k8s-core-objects/pod-lifecycle/06-imagepullbackoff.yaml
kubectl describe pod lifecycle-bad-image
kubectl get pod lifecycle-bad-image -w
kubectl delete -f session10-k8s-core-objects/pod-lifecycle/06-imagepullbackoff.yaml

kubectl apply -f session10-k8s-core-objects/hello.yml
kubectl get pod hello -w
kubectl logs hello
kubectl delete -f session10-k8s-core-objects/hello.yml
```

An invalid image can still produce a valid Pod API object; image download fails later on the node. `ErrImagePull` can become `ImagePullBackOff`. A short batch Pod may finish before polling captures `ContainerCreating` or `Running`; inspect events with `kubectl describe pod hello`. `Completed` is the displayed status for phase `Succeeded`.

## 5. Twelve Pod lifecycle labs

```bash
kubectl apply -f session10-k8s-core-objects/pod-lifecycle/
kubectl get pods -w
kubectl describe pod lifecycle-pending
kubectl describe pod lifecycle-readiness
kubectl describe pod lifecycle-liveness
kubectl describe pod lifecycle-startup
kubectl logs lifecycle-multi -c sidecar
kubectl delete pod lifecycle-termination --wait=false
kubectl delete -f session10-k8s-core-objects/pod-lifecycle/ --ignore-not-found
```

The files cover running, unschedulable, succeeded, failed, crash loop, image pull failure, readiness, liveness, startup, init container, sidecar, and graceful termination. The intentionally bad Pods need deletion after inspection. For termination, start `kubectl logs -f lifecycle-termination` in one terminal before deleting it in another.

## 6–7. ReplicaSet, StatefulSet, and DaemonSet

```bash
kubectl apply -f session10-k8s-core-objects/replicaset.yml
kubectl get pods -l app=course-rs
kubectl delete pod "$(kubectl get pod -l app=course-rs -o jsonpath='{.items[0].metadata.name}')"
kubectl get pods -l app=course-rs -w
kubectl delete -f session10-k8s-core-objects/replicaset.yml

kubectl apply -f session10-k8s-core-objects/k8s-core-objects/mysql-secret.yml
kubectl create secret generic mysql-demo-auth \
  --from-file=root-password=<(openssl rand -hex 16 | tr -d '\n') \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f session10-k8s-core-objects/k8s-core-objects/mysql-service.yml
kubectl apply -f session10-k8s-core-objects/k8s-core-objects/statefulset.yml
kubectl rollout status statefulset/mysql --timeout=300s
kubectl get pods -l app=mysql
kubectl get pvc data-mysql-0 data-mysql-1
kubectl get pods mysql-0 mysql-1
kubectl delete -f session10-k8s-core-objects/k8s-core-objects/statefulset.yml
kubectl delete -f session10-k8s-core-objects/k8s-core-objects/mysql-service.yml
kubectl delete -f session10-k8s-core-objects/k8s-core-objects/mysql-secret.yml
# Delete demo PVCs separately if their data is no longer needed:
kubectl delete pvc data-mysql-0 data-mysql-1

kubectl apply -f session10-k8s-core-objects/daemonset/node-agent-ds.yaml
kubectl get daemonset node-agent -o wide
kubectl get pods -l app=node-agent -o wide
kubectl delete -f session10-k8s-core-objects/daemonset/node-agent-ds.yaml
```

The MySQL demo password is generated at runtime and is not stored in Git. StatefulSet PVCs survive deletion by default.

## 8. Rolling update and rollback

```bash
kubectl apply -f session10-k8s-core-objects/01-rolling-update/deployment-v1.yaml
kubectl rollout status deployment/rolling-demo
kubectl apply -f session10-k8s-core-objects/01-rolling-update/deployment-v2.yaml
kubectl rollout status deployment/rolling-demo
kubectl rollout history deployment/rolling-demo
kubectl rollout undo deployment/rolling-demo
kubectl rollout status deployment/rolling-demo
kubectl delete deployment rolling-demo
```

`maxSurge: 1` allows one extra Pod above three replicas. `maxUnavailable: 0` keeps all three desired replicas available during a healthy rollout.

## 9. Troubleshooting drills

```bash
kubectl apply -f session10-k8s-core-objects/troubleshooting/fixed-image.yaml
kubectl rollout status deployment/troubleshoot-image
kubectl apply -f session10-k8s-core-objects/troubleshooting/broken-image.yaml
kubectl get pods -l app=troubleshoot-image
kubectl describe deployment troubleshoot-image
kubectl rollout undo deployment/troubleshoot-image
kubectl rollout status deployment/troubleshoot-image
kubectl delete deployment troubleshoot-image

kubectl apply -f session10-k8s-core-objects/troubleshooting/selector-mismatch.yaml
# Expected API validation error: selector does not match Pod template labels.
kubectl apply -f session10-k8s-core-objects/troubleshooting/selector-fixed.yaml
kubectl delete -f session10-k8s-core-objects/troubleshooting/selector-fixed.yaml
```

The bad image is a deliberately invalid registry address. A rolling update with zero unavailable replicas keeps old Pods available while new Pods cannot pull their image.

## 10. Concepts

| Field | Meaning |
| --- | --- |
| `containerPort` | Informational port declared on a container; it does not publish traffic. |
| `targetPort` | Service destination port on selected Pods. |
| `port` | Port on the Service's ClusterIP. |
| `nodePort` | Port on each node for a NodePort or LoadBalancer Service. |

Labels are key-value metadata on objects. Selectors match those labels to choose Pods; Deployment selectors must match template labels. Requests reserve scheduling capacity; limits cap usage. CPU is measured in cores or millicores, memory in bytes with units such as `Gi` (2³⁰ bytes) and `G` (10⁹ bytes). For three replicas, `maxSurge: 25%` rounds up to one extra Pod and `maxUnavailable: 25%` rounds down to zero unavailable Pods.

RollingUpdate replaces Pods gradually. Recreate stops old Pods before starting new ones. Blue-green keeps two complete versions and switches a Service selector. Canary adds a small number of new Pods behind a shared Service before widening exposure.

## 11. Blue-green cutover

```bash
kubectl apply -f session10-k8s-core-objects/02-blue-green/deployment-blue.yaml
kubectl apply -f session10-k8s-core-objects/02-blue-green/deployment-green.yaml
kubectl rollout status deployment/app-blue
kubectl rollout status deployment/app-green
kubectl apply -f session10-k8s-core-objects/02-blue-green/service-blue.yaml
kubectl get endpointslice -l kubernetes.io/service-name=blue-green
kubectl apply -f session10-k8s-core-objects/02-blue-green/service-green.yaml
sleep 8 # wait for EndpointSlice and node routing updates
kubectl get endpointslice -l kubernetes.io/service-name=blue-green
kubectl apply -f session10-k8s-core-objects/02-blue-green/service-blue.yaml
sleep 8
kubectl delete -f session10-k8s-core-objects/02-blue-green/service-blue.yaml
kubectl delete -f session10-k8s-core-objects/02-blue-green/deployment-blue.yaml
kubectl delete -f session10-k8s-core-objects/02-blue-green/deployment-green.yaml
```

Both Services have the same name; applying either manifest updates its selector. Endpoint propagation takes time. In the actual run, an immediate request after switching still returned v1; after an eight-second wait, Blue returned v1, Green returned v2, and rollback returned v1. See [verified cutover output](evidence/blue-green-verified.txt).

## 12. Canary by replica ratio

```bash
kubectl apply -f session10-k8s-core-objects/03-canary/deployment-stable.yaml
kubectl apply -f session10-k8s-core-objects/03-canary/deployment-canary.yaml
kubectl apply -f session10-k8s-core-objects/03-canary/service.yaml
kubectl rollout status deployment/canary-stable
kubectl rollout status deployment/canary-release
kubectl get endpointslice -l kubernetes.io/service-name=canary
sleep 10 # allow Service routing rules to observe the new endpoints
kubectl scale deployment/canary-stable --replicas=7
kubectl scale deployment/canary-release --replicas=3
kubectl scale deployment/canary-release --replicas=0
kubectl delete -f session10-k8s-core-objects/03-canary/
```

Use `kubectl run curl-check --rm -it --restart=Never --image=curlimages/curl -- sh` and request `http://canary` repeatedly from inside the cluster. Ratios are approximate: connection reuse and endpoint routing can skew short samples. After propagation, 100 requests returned 88 v1 / 12 v2 at 9:1 and 73 v1 / 27 v2 at 7:3; see [canary output](evidence/canary-verified.txt).

## 13. Recreate and deliberate outage

```bash
kubectl apply -f session10-k8s-core-objects/04-recreate/deployment-v1.yaml
kubectl apply -f session10-k8s-core-objects/04-recreate/service.yaml
kubectl rollout status deployment/recreate-demo
# In another terminal, request http://recreate-demo repeatedly from an in-cluster curl Pod.
kubectl apply -f session10-k8s-core-objects/04-recreate/deployment-v2.yaml
kubectl rollout status deployment/recreate-demo
kubectl rollout undo deployment/recreate-demo
kubectl rollout status deployment/recreate-demo
kubectl delete -f session10-k8s-core-objects/04-recreate/service.yaml
kubectl delete -f session10-k8s-core-objects/04-recreate/deployment-v1.yaml
```

Recreate intentionally leaves a period with no ready endpoints. Capture real terminal output and screenshots for each task after running the lab.

The [Recreate run](evidence/recreate.txt) captured four v1 responses, two failed requests during replacement, and 39 v2 responses. [Pod output](evidence/pods.txt), [lifecycle output](evidence/pod-lifecycle.txt), [controller output](evidence/controllers.txt), and [rolling update and troubleshooting output](evidence/rolling-troubleshooting.txt) cover the other executed labs.
