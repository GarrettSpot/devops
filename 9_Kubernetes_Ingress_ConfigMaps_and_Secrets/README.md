# Kubernetes Ingress, ConfigMaps & Secrets

- **ConfigMap** - plain-text, non-sensitive config (env name, log level, ports) kept outside the image.
- **Secret** - sensitive values (DB credentials, TLS certs). Values are only **base64-encoded**, not encrypted - anyone with `get secret` access can decode them.
- **Ingress** - L7 HTTP(S) routing rules (host + path -> Service). An **Ingress Controller** (here ingress-nginx) is the actual reverse proxy that implements them, so one entry point can serve many services instead of one LoadBalancer per service.

Cluster: local kind cluster `s-a`. The control-plane node is labelled `ingress-ready=true` and its ports 80/443 are mapped to `localhost:18080` / `localhost:18443`, so instead of `minikube ip` + `/etc/hosts` I use `curl --resolve` / `-H "Host: ..."` against `localhost:18080`.

## Installing the NGINX Ingress Controller (kind)

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
namespace/ingress-nginx created
serviceaccount/ingress-nginx created
serviceaccount/ingress-nginx-admission created
role.rbac.authorization.k8s.io/ingress-nginx created
role.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrole.rbac.authorization.k8s.io/ingress-nginx created
clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created
rolebinding.rbac.authorization.k8s.io/ingress-nginx created
rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
configmap/ingress-nginx-controller created
service/ingress-nginx-controller created
service/ingress-nginx-controller-admission created
deployment.apps/ingress-nginx-controller created
job.batch/ingress-nginx-admission-create created
job.batch/ingress-nginx-admission-patch created
ingressclass.networking.k8s.io/nginx created
validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s
pod/ingress-nginx-controller-596f5b6bcf-tcrzf condition met

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get pods -n ingress-nginx -o wide
NAME                                        READY   STATUS    RESTARTS   AGE   IP             NODE         NOMINATED NODE   READINESS GATES
ingress-nginx-controller-596f5b6bcf-tcrzf   1/1     Running   0          64s   10.244.2.103   s-a-worker   <none>           <none>

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.121.95   <pending>     80:31084/TCP,443:30771/TCP   65s
ingress-nginx-controller-admission   ClusterIP      10.96.184.56   <none>        443/TCP                      65s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get ingressclass
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       65s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s -o /dev/null -w "%{http_code}\n" http://localhost:18080; echo "exit code: $?"
000
exit code: 56

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get deploy ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.template.spec.nodeSelector}'; echo
{"kubernetes.io/os":"linux"}

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get nodes -l ingress-ready=true
NAME                STATUS   ROLES           AGE   VERSION
s-a-control-plane   Ready    control-plane   50m   v1.37.0

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl patch deploy ingress-nginx-controller -n ingress-nginx -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true"}}}}}'
deployment.apps/ingress-nginx-controller patched

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl rollout status deploy/ingress-nginx-controller -n ingress-nginx --timeout=300s
Waiting for deployment "ingress-nginx-controller" rollout to finish: 0 of 1 updated replicas are available...
deployment "ingress-nginx-controller" successfully rolled out

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get pods -n ingress-nginx -o wide
NAME                                        READY   STATUS    RESTARTS   AGE   IP           NODE                NOMINATED NODE   READINESS GATES
ingress-nginx-controller-575c4d8bc6-rrpvh   1/1     Running   0          33s   10.244.0.5   s-a-control-plane   <none>           <none>

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s http://localhost:18080
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```


**Problem:** the controller pod landed on `s-a-worker`, so nothing was listening on the mapped port 80 of the control-plane and `curl localhost:18080` failed (exit 56). The current kind manifest only has `kubernetes.io/os: linux` as nodeSelector. **Fix:** add `ingress-ready: "true"` to the nodeSelector so it runs on the control-plane, where the `hostPort` 80/443 is mapped to the host. Afterwards nginx answers with a 404 (no Ingress rules yet).

## Step 1 - ConfigMap

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f ./01-configmap/app-config.yaml
configmap/yatri-app-config created

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get configmap yatri-app-config
NAME               DATA   AGE
yatri-app-config   5      0s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl describe configmap yatri-app-config
Name:         yatri-app-config
Namespace:    default
Labels:       app=yatri-backend
Annotations:  <none>

Data
====
DEFAULT_CURRENCY:
----
INR

ENVIRONMENT:
----
production

LOG_LEVEL:
----
INFO

MAX_BOOKING_DAYS:
----
30

PORT:
----
5000

BinaryData
====

Events:  <none>

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get configmap yatri-app-config -o yaml
apiVersion: v1
data:
  DEFAULT_CURRENCY: INR
  ENVIRONMENT: production
  LOG_LEVEL: INFO
  MAX_BOOKING_DAYS: "30"
  PORT: "5000"
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"DEFAULT_CURRENCY":"INR","ENVIRONMENT":"production","LOG_LEVEL":"INFO","MAX_BOOKING_DAYS":"30","PORT":"5000"},"kind":"ConfigMap","metadata":{"annotations":{},"labels":{"app":"yatri-backend"},"name":"yatri-app-config","namespace":"default"}}
  creationTimestamp: "2026-10-26T09:54:22Z"
  labels:
    app: yatri-backend
  name: yatri-app-config
  namespace: default
  resourceVersion: "10198"
  uid: 8789597c-486c-439c-bfa7-02c0951acbd4

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get configmap yatri-app-config -o jsonpath='{.data.LOG_LEVEL}'; echo
INFO

…/k8s-a/session-12-ingress-configmaps-secrets ❯ cat 01-configmap/app-config.yml; wc -c 01-configmap/app-config.yml
0 01-configmap/app-config.yml

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f 01-configmap/app-config.yml
error: no objects passed to apply
```


`01-configmap/app-config.yml` is an empty file in the repo, so applying it fails with `no objects passed to apply` - `app-config.yaml` is the real manifest.

## Step 2 - Secret

`echo` adds a trailing newline (`...QK` at the end), `echo -n` doesn't (`...Q=`). `describe` hides the values, but `-o jsonpath` + `base64 --decode` reveals them.

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ echo "secretpassword" | base64
c2VjcmV0cGFzc3dvcmQK

…/k8s-a/session-12-ingress-configmaps-secrets ❯ echo -n "secretpassword" | base64
c2VjcmV0cGFzc3dvcmQ=

…/k8s-a/session-12-ingress-configmaps-secrets ❯ echo -n "yatri_admin" | base64
eWF0cmlfYWRtaW4=

…/k8s-a/session-12-ingress-configmaps-secrets ❯ echo -n "yatri_production_db" | base64
eWF0cmlfcHJvZHVjdGlvbl9kYg==

…/k8s-a/session-12-ingress-configmaps-secrets ❯ echo -n "c2VjcmV0cGFzc3dvcmQ=" | base64 --decode; echo
secretpassword

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f ./02-secret/db-secret.yaml
secret/yatri-db-secret created

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get secret yatri-db-secret
NAME              TYPE     DATA   AGE
yatri-db-secret   Opaque   3      0s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl describe secret yatri-db-secret
Name:         yatri-db-secret
Namespace:    default
Labels:       app=yatri-backend
Annotations:  <none>

Type:  Opaque

Data
====
POSTGRES_DB:        19 bytes
POSTGRES_PASSWORD:  14 bytes
POSTGRES_USER:      11 bytes

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get secret yatri-db-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 --decode; echo
secretpassword

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl create secret generic demo-literal --from-literal=API_KEY=s3cr3t --dry-run=client -o yaml
apiVersion: v1
data:
  API_KEY: czNjcjN0
kind: Secret
metadata:
  name: demo-literal
```


## Step 3 - Inject ConfigMap + Secret into the backend

`envFrom.configMapRef` injects every ConfigMap key; `env.valueFrom.secretKeyRef` injects individual Secret keys. The backend's HTTP response prints the injected values.

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f ./04-full-demo/backend.yaml
deployment.apps/yatri-backend created
service/yatri-backend-service created

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl rollout status deployment/yatri-backend --timeout=180s
Waiting for deployment "yatri-backend" rollout to finish: 0 of 2 updated replicas are available...
Waiting for deployment "yatri-backend" rollout to finish: 1 of 2 updated replicas are available...
deployment "yatri-backend" successfully rolled out

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get pods -l app=yatri-backend
NAME                             READY   STATUS    RESTARTS   AGE
yatri-backend-6c58cb99c7-tt9tn   1/1     Running   0          1s
yatri-backend-6c58cb99c7-whchq   1/1     Running   0          1s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl exec deployment/yatri-backend -- env | grep -E "POSTGRES|LOG_LEVEL|ENVIRONMENT|DEFAULT_CURRENCY|PORT" | sort
DEFAULT_CURRENCY=INR
ENVIRONMENT=production
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
LOG_LEVEL=INFO
PORT=5000
POSTGRES_DB=yatri_production_db
POSTGRES_PASSWORD=secretpassword
POSTGRES_USER=yatri_admin
YATRI_BACKEND_SERVICE_PORT_80_TCP_ADDR=10.96.144.144
YATRI_BACKEND_SERVICE_PORT_80_TCP_PORT=80
YATRI_BACKEND_SERVICE_PORT_80_TCP_PROTO=tcp
YATRI_BACKEND_SERVICE_PORT_80_TCP=tcp://10.96.144.144:80
YATRI_BACKEND_SERVICE_PORT=tcp://10.96.144.144:80
YATRI_BACKEND_SERVICE_SERVICE_PORT=80
YATRI_BACKEND_SERVICE_SERVICE_PORT_HTTP=80
```


### app/backend-with-config.yaml (envFrom for both ConfigMap and Secret)

`secretRef` under `envFrom` injects every key of the Secret at once. (`kubectl logs` is empty because Python buffers the `print()` when stdout is not a TTY and the process then just sleeps.)

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f app/backend-with-config.yaml
deployment.apps/yatri-backend configured

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl rollout status deployment/yatri-backend --timeout=180s
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "yatri-backend" rollout to finish: 1 old replicas are pending termination...
deployment "yatri-backend" successfully rolled out

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get pods -l app=yatri-backend
NAME                             READY   STATUS    RESTARTS   AGE
yatri-backend-649d5d9f7d-phgcr   1/1     Running   0          41s
yatri-backend-649d5d9f7d-wd29d   1/1     Running   0          41s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl logs yatri-backend-649d5d9f7d-phgcr

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl exec deployment/yatri-backend -- env | grep -E "POSTGRES|ENVIRONMENT" | sort
ENVIRONMENT=production
POSTGRES_DB=yatri_production_db
POSTGRES_PASSWORD=secretpassword
POSTGRES_USER=yatri_admin

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl exec deployment/yatri-backend -- python3 -c "import os; print(f'ENV={os.getenv(\"ENVIRONMENT\")} USER={os.getenv(\"POSTGRES_USER\")}')"
ENV=production USER=yatri_admin

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f ./04-full-demo/backend.yaml
deployment.apps/yatri-backend configured
service/yatri-backend-service unchanged

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl rollout status deployment/yatri-backend --timeout=180s
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "yatri-backend" rollout to finish: 1 old replicas are pending termination...
deployment "yatri-backend" successfully rolled out

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get pods -l app=yatri-backend
NAME                             READY   STATUS        RESTARTS   AGE
yatri-backend-649d5d9f7d-phgcr   1/1     Terminating   0          62s
yatri-backend-649d5d9f7d-wd29d   1/1     Terminating   0          62s
yatri-backend-6c58cb99c7-qfw6q   1/1     Running       0          20s
yatri-backend-6c58cb99c7-zwhkz   1/1     Running       0          20s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl exec deployment/yatri-backend -- wget -qO- localhost:5000
wget: can't connect to remote host: Connection refused
command terminated with exit code 1

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl exec deployment/yatri-backend -- wget -qO- 127.0.0.1:5000
Yatri Backend API
=================
ENVIRONMENT     : production
LOG_LEVEL       : INFO
DEFAULT_CURRENCY: INR
POSTGRES_USER   : yatri_admin
POSTGRES_DB     : yatri_production_db
```


At the end `04-full-demo/backend.yaml` is re-applied to get the HTTP backend back. `wget localhost:5000` is refused because `localhost` resolves to IPv6 `::1` in this Alpine image while the server listens on IPv4 `0.0.0.0` only; `127.0.0.1` works and returns the injected ConfigMap/Secret values.

## Step 4 - Frontend

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f ./04-full-demo/frontend.yaml
deployment.apps/yatri-frontend created
service/yatri-frontend-service created

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl rollout status deployment/yatri-frontend --timeout=180s
Waiting for deployment "yatri-frontend" rollout to finish: 0 of 2 updated replicas are available...
Waiting for deployment "yatri-frontend" rollout to finish: 1 of 2 updated replicas are available...
deployment "yatri-frontend" successfully rolled out

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get pods -l app=yatri-frontend
NAME                             READY   STATUS    RESTARTS   AGE
yatri-frontend-ddcfc4b5f-pmgq7   1/1     Running   0          1s
yatri-frontend-ddcfc4b5f-q92ls   1/1     Running   0          1s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get svc yatri-frontend-service yatri-backend-service
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
yatri-frontend-service   ClusterIP   10.96.245.172   <none>        80/TCP    1s
yatri-backend-service    ClusterIP   10.96.144.144   <none>        80/TCP    117s
```


## Step 5 - Ingress routes (03-ingress/ingress-routes.yaml)

`yatri.local/` -> frontend, `yatri.local/api...` -> backend. A request without the `yatri.local` Host header doesn't match any rule and gets the controller's default 404.

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f ./03-ingress/ingress-routes.yaml
ingress.networking.k8s.io/yatri-ingress created

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get ingress yatri-ingress
NAME            CLASS   HOSTS         ADDRESS     PORTS   AGE
yatri-ingress   nginx   yatri.local   localhost   80      20s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl describe ingress yatri-ingress
Name:             yatri-ingress
Labels:           app=yatri-app
Namespace:        default
Address:          localhost
Ingress Class:    nginx
Default backend:  <default>
Rules:
  Host         Path  Backends
  ----         ----  --------
  yatri.local  
               /api(/|$)(.*)   yatri-backend-service:80 (10.244.2.108:5000,10.244.1.78:5000)
               /               yatri-frontend-service:80 (10.244.1.79:80,10.244.2.109:80)
Annotations:   nginx.ingress.kubernetes.io/ssl-redirect: false
               nginx.ingress.kubernetes.io/use-regex: true
Events:
  Type    Reason  Age               From                      Message
  ----    ------  ----              ----                      -------
  Normal  Sync    8s (x2 over 20s)  nginx-ingress-controller  Scheduled for sync

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s -H "Host: yatri.local" http://localhost:18080/ | grep -i "<title>"
<title>Welcome to nginx!</title>

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s -H "Host: yatri.local" http://localhost:18080/api
Yatri Backend API
=================
ENVIRONMENT     : production
LOG_LEVEL       : INFO
DEFAULT_CURRENCY: INR
POSTGRES_USER   : yatri_admin
POSTGRES_DB     : yatri_production_db

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s -H "Host: yatri.local" http://localhost:18080/api/bookings
Yatri Backend API
=================
ENVIRONMENT     : production
LOG_LEVEL       : INFO
DEFAULT_CURRENCY: INR
POSTGRES_USER   : yatri_admin
POSTGRES_DB     : yatri_production_db

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s http://localhost:18080/ | grep -i "<title>"
<head><title>404 Not Found</title></head>
```


## Full demo (04-full-demo) - ConfigMap + Secret + Ingress with rewrite

`rewrite-target: /$2` strips the `/api` prefix before forwarding to the backend.

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f 04-full-demo/configmap.yaml
configmap/yatri-app-config configured

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f 04-full-demo/secret.yaml
secret/yatri-db-secret configured

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl describe configmap yatri-app-config | sed -n "/Data/,/BinaryData/p"
Data
====
APP_PORT:
----
5000

DEFAULT_CURRENCY:
----
INR

ENVIRONMENT:
----
production

LOG_LEVEL:
----
INFO

MAX_BOOKING_DAYS:
----
30

BinaryData

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f 04-full-demo/ingress.yaml
ingress.networking.k8s.io/yatri-ingress configured

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get ingress yatri-ingress
NAME            CLASS   HOSTS         ADDRESS     PORTS   AGE
yatri-ingress   nginx   yatri.local   localhost   80      36s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl describe ingress yatri-ingress | sed -n "/Rules:/,\$p"
Rules:
  Host         Path  Backends
  ----         ----  --------
  yatri.local  
               /api(/|$)(.*)   yatri-backend-service:80 (10.244.2.108:5000,10.244.1.78:5000)
               /               yatri-frontend-service:80 (10.244.1.79:80,10.244.2.109:80)
Annotations:   nginx.ingress.kubernetes.io/rewrite-target: /$2
               nginx.ingress.kubernetes.io/ssl-redirect: false
               nginx.ingress.kubernetes.io/use-regex: true
Events:
  Type    Reason  Age                From                      Message
  ----    ------  ----               ----                      -------
  Normal  Sync    15s (x3 over 36s)  nginx-ingress-controller  Scheduled for sync

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s --resolve yatri.local:18080:127.0.0.1 http://yatri.local:18080 | grep -i "<title>"
<title>Welcome to nginx!</title>

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s --resolve yatri.local:18080:127.0.0.1 http://yatri.local:18080/api/
Yatri Backend API
=================
ENVIRONMENT     : production
LOG_LEVEL       : INFO
DEFAULT_CURRENCY: INR
POSTGRES_USER   : yatri_admin
POSTGRES_DB     : yatri_production_db

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get configmap yatri-app-config
NAME               DATA   AGE
yatri-app-config   5      2m34s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get secret    yatri-db-secret
NAME              TYPE     DATA   AGE
yatri-db-secret   Opaque   3      2m33s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get pods      -l app=yatri-frontend
NAME                             READY   STATUS    RESTARTS   AGE
yatri-frontend-ddcfc4b5f-pmgq7   1/1     Running   0          37s
yatri-frontend-ddcfc4b5f-q92ls   1/1     Running   0          37s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get pods      -l app=yatri-backend
NAME                             READY   STATUS    RESTARTS   AGE
yatri-backend-6c58cb99c7-qfw6q   1/1     Running   0          70s
yatri-backend-6c58cb99c7-zwhkz   1/1     Running   0          70s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get svc       yatri-frontend-service yatri-backend-service
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
yatri-frontend-service   ClusterIP   10.96.245.172   <none>        80/TCP    37s
yatri-backend-service    ClusterIP   10.96.144.144   <none>        80/TCP    2m33s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get ingress   yatri-ingress
NAME            CLASS   HOSTS         ADDRESS     PORTS   AGE
yatri-ingress   nginx   yatri.local   localhost   80      36s
```


| `http://yatri.local/` (frontend) | `http://yatri.local/api/` (backend - ConfigMap + Secret values) |
|---|---|
| ![yatri frontend through ingress](yatri-frontend.png) | ![yatri backend api through ingress](yatri-backend-api.png) |

## Step 6 - TLS termination + host-based routing (ingress-tls.yaml)

Self-signed certificate for `portal.campus.local` and `api.campus.local` stored as a `kubernetes.io/tls` Secret. Plain HTTP gets a `308` redirect to HTTPS (`ssl-redirect: "true"`). Without `-k`, curl refuses the self-signed cert (exit 60).

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=campus.local/O=Campus" -addext "subjectAltName=DNS:portal.campus.local,DNS:api.campus.local"
..+........+...+....+...+............+.....+...+...+...+.+++++++++++++++++++++++++++++++++++++++*...+....+......+++++++++++++++++++++++++++++++++++++++*..+......+......+.....+.........+.........+....+......+.........+..+....+.........+...+.....+.............+...........+....+......+...+.....+...+.........+....+...............+......+...+.....+......+.+........+..........+..+.........+.+......+...+.....+.......+..+...+...+............+.........+.+...+..+.........+...+.......+......+........+......+...............+.........+.+........+......+....+...+.....+.......+..........................+....+...+........................+...........+.......+...+...............+........+......+...+..........+......+..+...+.+...+......+.....+....+...........+.+.....+........................+....+...........................+.....+....+..+...+.......+..+......+.+.....+.+..+.............+..+.+.........+..+.+........+............+...+....+...+...+......+.....+......+....+...+.....+......+.+...+..+....+.....+.......+...+.....+...............+.......+.................+...+....+...........+...............+...+....+..+...............+.+..............+.+.....+...+............+.......+..+...+...+....+.........+...............+.....+....+...+.................+.......++++++
.......+...+......+.+........+.......+........+.......+......+...+..+.......+............+...+.....+.............+............+.....+.+...........+.+...+..+.........+......+...+....+......+++++++++++++++++++++++++++++++++++++++*...+......+...+..+...+....+......+......+...........+.........+.+++++++++++++++++++++++++++++++++++++++*.+........+.........+.+..+....+...+.....+...+.........++++++
-----

…/k8s-a/session-12-ingress-configmaps-secrets ❯ openssl x509 -in tls.crt -noout -subject -ext subjectAltName
subject=CN=campus.local, O=Campus
X509v3 Subject Alternative Name: 
    DNS:portal.campus.local, DNS:api.campus.local

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl create secret tls campus-tls-cert --cert=tls.crt --key=tls.key
secret/campus-tls-cert created

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get secret campus-tls-cert
NAME              TYPE                DATA   AGE
campus-tls-cert   kubernetes.io/tls   2      0s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f ./03-ingress/ingress-tls.yaml
ingress.networking.k8s.io/campus-ingress-tls created

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get ingress campus-ingress-tls
NAME                 CLASS   HOSTS                                  ADDRESS     PORTS     AGE
campus-ingress-tls   nginx   portal.campus.local,api.campus.local   localhost   80, 443   20s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl describe ingress campus-ingress-tls | sed -n "/TLS:/,\$p"
TLS:
  campus-tls-cert terminates portal.campus.local,api.campus.local
Rules:
  Host                 Path  Backends
  ----                 ----  --------
  portal.campus.local  
                       /()(.*)   yatri-frontend-service:80 (10.244.1.79:80,10.244.2.109:80)
  api.campus.local     
                       /api(/|$)(.*)   yatri-backend-service:80 (10.244.2.108:5000,10.244.1.78:5000)
Annotations:           nginx.ingress.kubernetes.io/rewrite-target: /$2
                       nginx.ingress.kubernetes.io/ssl-redirect: true
Events:
  Type    Reason  Age               From                      Message
  ----    ------  ----              ----                      -------
  Normal  Sync    4s (x2 over 20s)  nginx-ingress-controller  Scheduled for sync

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s -o /dev/null -w "%{http_code} -> %{redirect_url}\n" --resolve portal.campus.local:18080:127.0.0.1 http://portal.campus.local:18080/
308 -> https://portal.campus.local/

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -k -s --resolve portal.campus.local:18443:127.0.0.1 https://portal.campus.local:18443/ | grep -i "<title>"
<title>Welcome to nginx!</title>

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -k -s --resolve api.campus.local:18443:127.0.0.1 https://api.campus.local:18443/api/health
Yatri Backend API
=================
ENVIRONMENT     : production
LOG_LEVEL       : INFO
DEFAULT_CURRENCY: INR
POSTGRES_USER   : yatri_admin
POSTGRES_DB     : yatri_production_db

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -k -v -s -o /dev/null --resolve portal.campus.local:18443:127.0.0.1 https://portal.campus.local:18443/ 2>&1 | grep -E "subject:|issuer:|SSL connection|HTTP/2 200"
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / X25519MLKEM768 / RSASSA-PSS
*   subject: CN=campus.local; O=Campus
*   issuer: CN=campus.local; O=Campus
< HTTP/2 200 

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s --resolve portal.campus.local:18443:127.0.0.1 https://portal.campus.local:18443/; echo "exit code: $?"
exit code: 60
```


| `https://portal.campus.local` | `https://api.campus.local/api/health` |
|---|---|
| ![portal over https](campus-portal-tls.png) | ![api over https](campus-api-tls.png) |

## Path-based ingress (03-ingress/path-based.yml)

**Problem:** the Ingress references `frontend-service` and `backend-service`, which don't exist, so the controller returns `503 Service Temporarily Unavailable` and `describe` shows `services "frontend-service" not found`. **Fix:** create Services with those names pointing at the frontend/backend deployments.

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f 03-ingress/path-based.yml
ingress.networking.k8s.io/app-ingress created

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get ingress app-ingress
NAME          CLASS   HOSTS         ADDRESS   PORTS   AGE
app-ingress   nginx   myapp.local             80      15s

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s --resolve myapp.local:18080:127.0.0.1 http://myapp.local:18080/ | grep -i title
<head><title>503 Service Temporarily Unavailable</title></head>

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl describe ingress app-ingress | sed -n "/Rules:/,/Annotations/p"
Rules:
  Host         Path  Backends
  ----         ----  --------
  myapp.local  
               /      frontend-service:80 (<error: services "frontend-service" not found>)
               /api   backend-service:80 (<error: services "backend-service" not found>)
Annotations:   <none>

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl expose deployment yatri-frontend --name=frontend-service --port=80 --target-port=80
service/frontend-service exposed

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl expose deployment yatri-backend --name=backend-service --port=80 --target-port=5000
service/backend-service exposed

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl describe ingress app-ingress | sed -n "/Rules:/,/Annotations/p"
Rules:
  Host         Path  Backends
  ----         ----  --------
  myapp.local  
               /      frontend-service:80 (10.244.2.109:80,10.244.1.79:80)
               /api   backend-service:80 (10.244.1.78:5000,10.244.2.108:5000)
Annotations:   <none>

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s --resolve myapp.local:18080:127.0.0.1 http://myapp.local:18080/ | grep -i title
<title>Welcome to nginx!</title>

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s --resolve myapp.local:18080:127.0.0.1 http://myapp.local:18080/api
Yatri Backend API
=================
ENVIRONMENT     : production
LOG_LEVEL       : INFO
DEFAULT_CURRENCY: INR
POSTGRES_USER   : yatri_admin
POSTGRES_DB     : yatri_production_db

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl delete -f 03-ingress/path-based.yml && kubectl delete svc frontend-service backend-service
ingress.networking.k8s.io "app-ingress" deleted from default namespace
service "frontend-service" deleted from default namespace
service "backend-service" deleted from default namespace
```


![myapp.local/api via path-based ingress](myapp-api.png)

## Troubleshooting - the trailing newline Secret bug

`echo "mypassword" | base64` encodes `mypassword\n` (11 bytes) -> the app receives a password with a hidden newline and DB auth fails. `echo -n` (or `kubectl create secret --from-literal`) gives the correct 10 bytes.

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ echo "mypassword" | od -c
0000000   m   y   p   a   s   s   w   o   r   d  \n
0000013

…/k8s-a/session-12-ingress-configmaps-secrets ❯ echo -n "mypassword" | od -c
0000000   m   y   p   a   s   s   w   o   r   d
0000012

…/k8s-a/session-12-ingress-configmaps-secrets ❯ echo "mypassword" | base64
bXlwYXNzd29yZAo=

…/k8s-a/session-12-ingress-configmaps-secrets ❯ echo -n "mypassword" | base64
bXlwYXNzd29yZA==

…/k8s-a/session-12-ingress-configmaps-secrets ❯ echo "c2VjcmV0cGFzc3dvcmQK" | base64 --decode | od -c
0000000   s   e   c   r   e   t   p   a   s   s   w   o   r   d  \n
0000017

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl create secret generic newline-bug --from-literal=GOOD=mypassword --dry-run=client -o yaml | grep GOOD
  GOOD: bXlwYXNzd29yZA==

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: newline-bug
data:
  BAD: bXlwYXNzd29yZAo=
  GOOD: bXlwYXNzd29yZA==
EOF
secret/newline-bug created

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get secret newline-bug -o jsonpath='{.data.BAD}' | base64 -d | od -c
0000000   m   y   p   a   s   s   w   o   r   d  \n
0000013

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get secret newline-bug -o jsonpath='{.data.GOOD}' | base64 -d | od -c
0000000   m   y   p   a   s   s   w   o   r   d
0000012

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl describe secret newline-bug | tail -3
====
BAD:   11 bytes
GOOD:  10 bytes

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl delete secret newline-bug
secret "newline-bug" deleted from default namespace
```


## What happens when a ConfigMap changes?

Environment variables are read only at container start: after patching the ConfigMap the running pods still show `production`. A `kubectl rollout restart` creates new pods that pick up `staging`.

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl patch configmap yatri-app-config --type merge -p '{"data":{"ENVIRONMENT":"staging"}}'
configmap/yatri-app-config patched

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get configmap yatri-app-config -o jsonpath="{.data.ENVIRONMENT}"; echo
staging

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl exec deployment/yatri-backend -- env | grep ENVIRONMENT
ENVIRONMENT=production

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl rollout restart deployment/yatri-backend
deployment.apps/yatri-backend restarted

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl rollout status deployment/yatri-backend --timeout=180s
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "yatri-backend" rollout to finish: 1 old replicas are pending termination...
deployment "yatri-backend" successfully rolled out

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl exec deployment/yatri-backend -- env | grep ENVIRONMENT
ENVIRONMENT=staging

…/k8s-a/session-12-ingress-configmaps-secrets ❯ curl -s --resolve yatri.local:18080:127.0.0.1 http://yatri.local:18080/api/
Yatri Backend API
=================
ENVIRONMENT     : staging
LOG_LEVEL       : INFO
DEFAULT_CURRENCY: INR
POSTGRES_USER   : yatri_admin
POSTGRES_DB     : yatri_production_db

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl patch configmap yatri-app-config --type merge -p '{"data":{"ENVIRONMENT":"production"}}'
configmap/yatri-app-config patched

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl rollout restart deployment/yatri-backend
deployment.apps/yatri-backend restarted

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl rollout status deployment/yatri-backend --timeout=180s
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "yatri-backend" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "yatri-backend" rollout to finish: 1 old replicas are pending termination...
deployment "yatri-backend" successfully rolled out
```


## Cleanup

(`02-secret/azure-pipelines.yml` is an Azure DevOps pipeline snippet, not a Kubernetes manifest, so it was not applied.)

```bash
…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl delete ingress campus-ingress-tls && kubectl delete secret campus-tls-cert
ingress.networking.k8s.io "campus-ingress-tls" deleted from default namespace
secret "campus-tls-cert" deleted from default namespace

…/k8s-a/session-12-ingress-configmaps-secrets ❯ bash 04-full-demo/cleanup.sh
[INFO] Deleting Ingress...
ingress.networking.k8s.io "yatri-ingress" deleted from default namespace
[INFO] Deleting Backend Deployment and Service...
deployment.apps "yatri-backend" deleted from default namespace
service "yatri-backend-service" deleted from default namespace
[INFO] Deleting Frontend Deployment and Service...
deployment.apps "yatri-frontend" deleted from default namespace
service "yatri-frontend-service" deleted from default namespace
[INFO] Deleting Secret...
secret "yatri-db-secret" deleted from default namespace
[INFO] Deleting ConfigMap...
configmap "yatri-app-config" deleted from default namespace
[INFO] All demo resources removed.

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get all -l app=yatri-app
No resources found in default namespace.

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get configmap yatri-app-config
Error from server (NotFound): configmaps "yatri-app-config" not found

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get secret yatri-db-secret
Error from server (NotFound): secrets "yatri-db-secret" not found

…/k8s-a/session-12-ingress-configmaps-secrets ❯ kubectl get ingress yatri-ingress
Error from server (NotFound): ingresses.networking.k8s.io "yatri-ingress" not found
```

