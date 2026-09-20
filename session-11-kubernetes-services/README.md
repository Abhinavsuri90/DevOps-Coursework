# Session 11: Kubernetes Services and DNS

Run from this directory after `minikube start`. All examples use the `default` namespace and are designed to be applied separately. The [Service and DNS output](evidence/services.txt) and [external access output](evidence/external-access.txt) came from the temporary Minikube run. [PNG renders of recorded output](screenshots/README.md) are included; direct desktop screenshots were not captured.

## 1. Port path

```text
Client → nodePort 30080 on a node → Service port 80 → targetPort 80 on a Pod → nginx listens on 80
```

`containerPort` documents a container's listening port; it does not open a firewall rule. `targetPort` selects the destination Pod port. `port` is the Service's ClusterIP port. `nodePort` exposes the Service on eligible nodes. Inspect schemas with `kubectl explain pod.spec.containers.ports.containerPort` and `kubectl explain service.spec.ports`.

## 2. ClusterIP

```bash
kubectl apply -f 01-clusterip/
kubectl rollout status deployment/web-app-clusterip
kubectl get pods -l app=web-clusterip -o wide
kubectl get service web-service-clusterip
kubectl get endpointslice -l kubernetes.io/service-name=web-service-clusterip
kubectl exec curl-client -- wget -qO- http://web-service-clusterip:8080
kubectl exec curl-client -- wget -qO- http://web-service-clusterip.default.svc.cluster.local:8080
kubectl exec curl-client -- wget -qO- http://$(kubectl get service web-service-clusterip -o jsonpath='{.spec.clusterIP}'):8080
```

The Service is reachable only from inside the cluster unless a separate ingress path is configured. EndpointSlices list the selected ready Pod addresses.

## 3. NodePort

```bash
kubectl apply -f 02-nodeport/
kubectl rollout status deployment/web-app-nodeport
kubectl get service web-service-nodeport
curl -I "http://$(minikube ip):30080"
minikube service web-service-nodeport --url
```

Use the printed `minikube service --url` address if Docker-driver networking prevents direct access to the node IP.

## 4. LoadBalancer

```bash
kubectl apply -f 03-loadbalancer/
kubectl rollout status deployment/web-app-loadbalancer
kubectl get service web-service-loadbalancer
# In a separate terminal:
minikube tunnel
# Back in this terminal:
kubectl get service web-service-loadbalancer
curl -I "http://$(kubectl get service web-service-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
```

Without a cloud provider or tunnel, the external IP can remain pending. A LoadBalancer Service usually also has a ClusterIP and, unless `allocateLoadBalancerNodePorts: false`, NodePorts.

## 5. ExternalName

```bash
kubectl apply -f 04-externalname/
kubectl get service external-database-service
kubectl exec dns-test-client -- nslookup external-database-service.default.svc.cluster.local
```

The alias points to `api.github.com` via DNS CNAME. It has no cluster IP and no selected Pod endpoints. The name is intentionally a DNS example; HTTPS clients should connect using the destination hostname so TLS hostname verification succeeds.

## 6. Headless Service

```bash
kubectl apply -f 05-headless/
kubectl rollout status statefulset/web-stateful --timeout=180s
kubectl get pods -l app=web-headless -o wide
kubectl get service web-service-headless
kubectl exec headless-dns-client -- nslookup web-service-headless.default.svc.cluster.local
kubectl exec headless-dns-client -- nslookup web-stateful-0.web-service-headless.default.svc.cluster.local
kubectl exec headless-dns-client -- wget -qO- http://web-stateful-0.web-service-headless
```

The headless Service has `clusterIP: None` and DNS can return each ready Pod's address. The StatefulSet gives Pods stable ordinal names.

## 7. Service without selectors

```bash
kubectl apply -f 06-no-selector/service.yaml
kubectl get endpoints external-legacy-db || echo 'No Endpoints object yet'
kubectl apply -f 06-no-selector/endpoints.yaml
kubectl get endpoints external-legacy-db
kubectl get endpointslice -l kubernetes.io/service-name=external-legacy-db
```

`192.0.2.10` is a documentation-only address. Replace it with a reachable backend address before a connectivity test. On Kubernetes v1.37, no `Endpoints` object existed before manual creation; the command returned `NotFound`. A selector-free Service needs manually maintained endpoints; an EndpointSlice is the modern endpoint API, though this exercise uses an `Endpoints` object as assigned. The API warned that v1 Endpoints is deprecated.

## 8. FQDN and CoreDNS

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl exec curl-client -- cat /etc/resolv.conf
kubectl exec curl-client -- nslookup web-service-clusterip
kubectl exec curl-client -- nslookup web-service-clusterip.default.svc.cluster.local
```

The FQDN consists of `<service>.<namespace>.svc.<cluster-domain>`. The usual cluster domain is `cluster.local`, but clusters can change it. Search suffixes complete short names. With `ndots:5`, names with fewer than five dots are tried with search suffixes before an absolute lookup; external names can trigger extra DNS queries. An absolute name ending in `.` avoids search expansion.

## 9. Deployment and StatefulSet identities

```bash
kubectl get pods -l app=web-clusterip
kubectl get pods -l app=web-headless
DEPLOY_POD=$(kubectl get pods -l app=web-clusterip -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod "$DEPLOY_POD"
kubectl delete pod web-stateful-0
kubectl get pods -l app=web-clusterip
kubectl get pods -l app=web-headless
```

Deployment Pod names have a ReplicaSet hash plus a random suffix. Replacement gets a new suffix. StatefulSet replacement keeps the ordinal name `web-stateful-0`, though it is a new Pod object with a new UID.

## 10. Controller comparison

| Property | Deployment | StatefulSet | DaemonSet |
| --- | --- | --- | --- |
| Desired placement | Fixed replica count | Fixed replica count | One Pod per eligible node |
| Pod identity | Replaceable random name | Stable ordinal name | Bound to node placement, recreated if needed |
| Ordering | Rolling strategy | Ordered creation/deletion by default | Node-driven |
| Storage | PVC can be shared or separately managed | `volumeClaimTemplates` bind stable PVC per ordinal | Often host logs or node-local mounts |
| Common Service | ClusterIP | Headless for stable Pod DNS | Often none; metrics may use a Service |
| Typical use | Stateless web API | Database or ordered peer | Log collector or node agent |

## 11. Service choice and cost

Use ClusterIP for internal traffic; NodePort for simple direct node exposure; LoadBalancer when a cloud-managed external IP is needed; ExternalName for a DNS alias; headless when callers need direct Pod identity. Many cloud LoadBalancers can each have a recurring cost. A common architecture places many ClusterIP services behind one Ingress controller and one external LoadBalancer. Check the provider's current pricing rather than assuming a fixed monthly amount.

## 12. Minikube Docker-driver networking

With the Docker driver, the node IP can live on a container bridge inaccessible from the host, especially on macOS and Windows. `minikube service web-service-nodeport --url` establishes an accessible local URL. `minikube tunnel` adds routing for LoadBalancer services and may require elevated local privileges. Keep the terminal running while testing, and stop the tunnel with Ctrl-C when finished.

On this macOS Docker driver, direct `<minikube-ip>:30080` access timed out, while `minikube service --url` returned a localhost URL and HTTP 200. `minikube tunnel` assigned `127.0.0.1` to the LoadBalancer, but binding privileged port 80 required a sudo prompt and the HTTP probe could not connect. The Ingress lab uses unprivileged port forwarding for host-side checks.

## Cleanup

```bash
kubectl delete -f 01-clusterip/ -f 02-nodeport/ -f 03-loadbalancer/ -f 04-externalname/ -f 05-headless/ -f 06-no-selector/ --ignore-not-found
```
