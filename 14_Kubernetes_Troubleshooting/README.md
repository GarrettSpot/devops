# 14

Lab run on a local **kind** cluster (`s-b`: 1 control-plane + 2 workers, Kubernetes v1.37).

Troubleshooting flow used throughout: **get -> describe -> events -> logs -> exec -> test -> fix -> verify**

## 01 - kubectl get

```bash
…/session-14-kubernetes-troubleshooting/01-kubectl-get ❯ kubectl apply -f pod.yaml
pod/get-demo created

…/session-14-kubernetes-troubleshooting/01-kubectl-get ❯ kubectl get pods
NAME       READY   STATUS    RESTARTS   AGE
get-demo   1/1     Running   0          5s

…/session-14-kubernetes-troubleshooting/01-kubectl-get ❯ kubectl get pods -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
get-demo   1/1     Running   0          5s    10.244.2.40   s-b-worker2   <none>           <none>

…/session-14-kubernetes-troubleshooting/01-kubectl-get ❯ kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   39m

…/session-14-kubernetes-troubleshooting/01-kubectl-get ❯ kubectl get deployments
No resources found in default namespace.

…/session-14-kubernetes-troubleshooting/01-kubectl-get ❯ kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
s-b-control-plane   Ready    control-plane   39m   v1.37.0
s-b-worker          Ready    <none>          39m   v1.37.0
s-b-worker2         Ready    <none>          39m   v1.37.0

…/session-14-kubernetes-troubleshooting/01-kubectl-get ❯ kubectl get all
NAME           READY   STATUS    RESTARTS   AGE
pod/get-demo   1/1     Running   0          5s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   39m

…/session-14-kubernetes-troubleshooting/01-kubectl-get ❯ timeout 15 kubectl get pods -w
NAME       READY   STATUS    RESTARTS   AGE
get-demo   1/1     Running   0          5s
get-demo   1/1     Terminating   0          9s
get-demo   1/1     Terminating   0          9s
get-demo   0/1     Completed     0          9s
get-demo   0/1     Completed     0          10s
get-demo   0/1     Completed     0          10s
```

## 02 - kubectl describe

The README says `kubectl apply -f pod.yaml`, but the file in this folder is `demo-pod.yaml`:

```bash
…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ ls
demo-chart
demo-pod.yaml
README.md

…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ kubectl apply -f pod.yaml
error: the path "pod.yaml" does not exist

…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ kubectl apply -f demo-pod.yaml
pod/describe-demo created

…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ kubectl get pod
NAME            READY   STATUS    RESTARTS   AGE
describe-demo   1/1     Running   0          5s

…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ kubectl describe pod describe-demo
Name:             describe-demo
Namespace:        default
Priority:         0
Service Account:  default
Node:             s-b-worker2/172.19.0.2
Start Time:       Mon, 26 Oct 2026 15:13:12 +0530
Labels:           app=describe-demo
Annotations:      <none>
Status:           Running
IP:               10.244.2.41
IPs:
  IP:  10.244.2.41
Containers:
  nginx:
    Container ID:   containerd://fcb446aa3b7f21bc0e62ccbe8621cbe0fe0d74e81c596ce994f45b255b9ca011
    Image:          nginx:1.27
    Image ID:       docker.io/library/nginx@sha256:6784fb0834aa7dbbe12e3d7471e69c290df3e6ba810dc38b34ae33d3c1c05f7d
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 26 Oct 2026 15:13:13 +0530
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-56dlm (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  kube-api-access-56dlm:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  5s    default-scheduler  Successfully assigned default/describe-demo to s-b-worker2
  Normal  Pulled     5s    kubelet            spec.containers{nginx}: Container image "nginx:1.27" already present on machine and can be accessed by the pod
  Normal  Created    5s    kubelet            spec.containers{nginx}: Container created
  Normal  Started    5s    kubelet            spec.containers{nginx}: Container started

…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ helm install demo demo-chart
NAME: demo
LAST DEPLOYED: Mon Oct 26 15:13:24 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=demo-chart,app.kubernetes.io/instance=demo" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
```

Describing other resources. I used the folder's `demo-chart` (stock `helm create` chart) to get a Deployment and a Service:

```bash
…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ kubectl get deploy,svc
NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/demo-demo-chart   1/1     1            1           11s

NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/demo-demo-chart   ClusterIP   10.96.218.133   <none>        80/TCP    11s
service/kubernetes        ClusterIP   10.96.0.1       <none>        443/TCP   40m

…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ kubectl describe deployment demo-demo-chart
Name:                   demo-demo-chart
Namespace:              default
CreationTimestamp:      Mon, 26 Oct 2026 15:13:25 +0530
Labels:                 app.kubernetes.io/instance=demo
                        app.kubernetes.io/managed-by=Helm
                        app.kubernetes.io/name=demo-chart
                        app.kubernetes.io/version=1.16.0
                        helm.sh/chart=demo-chart-0.1.0
Annotations:            deployment.kubernetes.io/revision: 1
                        meta.helm.sh/release-name: demo
                        meta.helm.sh/release-namespace: default
Selector:               app.kubernetes.io/instance=demo,app.kubernetes.io/name=demo-chart
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:           app.kubernetes.io/instance=demo
                    app.kubernetes.io/managed-by=Helm
                    app.kubernetes.io/name=demo-chart
                    app.kubernetes.io/version=1.16.0
                    helm.sh/chart=demo-chart-0.1.0
  Service Account:  demo-demo-chart
  Containers:
   demo-chart:
    Image:         nginx:1.16.0
    Port:          80/TCP (http)
    Host Port:     0/TCP (http)
    Liveness:      http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Readiness:     http-get http://:http/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   demo-demo-chart-6f75999d46 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  11s   deployment-controller  Scaled up replica set demo-demo-chart-6f75999d46 from 0 to 1

…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ kubectl describe service demo-demo-chart
Name:                     demo-demo-chart
Namespace:                default
Labels:                   app.kubernetes.io/instance=demo
                          app.kubernetes.io/managed-by=Helm
                          app.kubernetes.io/name=demo-chart
                          app.kubernetes.io/version=1.16.0
                          helm.sh/chart=demo-chart-0.1.0
Annotations:              meta.helm.sh/release-name: demo
                          meta.helm.sh/release-namespace: default
Selector:                 app.kubernetes.io/instance=demo,app.kubernetes.io/name=demo-chart
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.96.218.133
IPs:                      10.96.218.133
Port:                     http  80/TCP
TargetPort:               http/TCP
Endpoints:                10.244.1.15:80
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>

…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ kubectl describe node s-b-worker2 | sed -n '/^Conditions:/,/^Addresses:/p;/^Allocated resources:/,/^Events:/p'
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  MemoryPressure   False   Mon, 26 Oct 2026 15:09:51 +0530   Mon, 26 Oct 2026 14:33:25 +0530   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Mon, 26 Oct 2026 15:09:51 +0530   Mon, 26 Oct 2026 14:33:25 +0530   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Mon, 26 Oct 2026 15:09:51 +0530   Mon, 26 Oct 2026 14:33:25 +0530   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Mon, 26 Oct 2026 15:09:51 +0530   Mon, 26 Oct 2026 14:33:38 +0530   KubeletReady                 kubelet is posting ready status
Addresses:
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests   Limits
  --------           --------   ------
  cpu                100m (1%)  0 (0%)
  memory             50Mi (0%)  0 (0%)
  ephemeral-storage  0 (0%)     0 (0%)
  hugepages-1Gi      0 (0%)     0 (0%)
  hugepages-2Mi      0 (0%)     0 (0%)
Events:

…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ helm uninstall demo
release "demo" uninstalled

…/session-14-kubernetes-troubleshooting/02-kubectl-describe ❯ kubectl delete -f demo-pod.yaml
pod "describe-demo" deleted from default namespace
```

## 03 - kubectl logs

```bash
…/session-14-kubernetes-troubleshooting/03-kubectl-logs ❯ kubectl apply -f pod.yaml
pod/logs-demo created

…/session-14-kubernetes-troubleshooting/03-kubectl-logs ❯ kubectl get pod logs-demo
NAME        READY   STATUS    RESTARTS   AGE
logs-demo   1/1     Running   0          12s

…/session-14-kubernetes-troubleshooting/03-kubectl-logs ❯ kubectl logs logs-demo
Application started
Connecting to database...
Database connection successful
Application is running
Application is healthy
Application is healthy
Application is healthy

…/session-14-kubernetes-troubleshooting/03-kubectl-logs ❯ timeout 12 kubectl logs -f logs-demo
Application started
Connecting to database...
Database connection successful
Application is running
Application is healthy
Application is healthy
Application is healthy
Application is healthy
Application is healthy

…/session-14-kubernetes-troubleshooting/03-kubectl-logs ❯ kubectl logs logs-demo --previous
Error from server (BadRequest): previous terminated container "app" in pod "logs-demo" not found

…/session-14-kubernetes-troubleshooting/03-kubectl-logs ❯ kubectl logs logs-demo -c app --tail=2
Application is healthy
Application is healthy

…/session-14-kubernetes-troubleshooting/03-kubectl-logs ❯ kubectl logs logs-demo -c backend
error: container backend is not valid for pod logs-demo out of: app

…/session-14-kubernetes-troubleshooting/03-kubectl-logs ❯ kubectl delete pod logs-demo
pod "logs-demo" deleted from default namespace
```

`--previous` fails because this container has never restarted, and `-c backend` fails because the Pod only has one container, `app`. Both error messages tell you exactly why.

## 04 - kubectl exec

`kubectl exec -it ... -- bash` needs a TTY. I ran the same checks as one-off commands, and fed an interactive shell through stdin (`-i`) for the last one:

```bash
…/session-14-kubernetes-troubleshooting/04-kubectl-exec ❯ kubectl apply -f pod.yaml
pod/exec-demo created

…/session-14-kubernetes-troubleshooting/04-kubectl-exec ❯ kubectl get pod exec-demo
NAME        READY   STATUS    RESTARTS   AGE
exec-demo   1/1     Running   0          6s

…/session-14-kubernetes-troubleshooting/04-kubectl-exec ❯ kubectl exec exec-demo -- ls
bin
boot
dev
docker-entrypoint.d
docker-entrypoint.sh
etc
home
lib
lib64
media
mnt
opt
proc
product_name
product_uuid
root
run
sbin
srv
sys
tmp
usr
var

…/session-14-kubernetes-troubleshooting/04-kubectl-exec ❯ kubectl exec exec-demo -- ls /usr/share/nginx/html
50x.html
index.html

…/session-14-kubernetes-troubleshooting/04-kubectl-exec ❯ kubectl exec exec-demo -- curl -s localhost | head -4
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>

…/session-14-kubernetes-troubleshooting/04-kubectl-exec ❯ kubectl exec exec-demo -- nginx -T 2>&1 | head -20
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# configuration file /etc/nginx/nginx.conf:

user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '

…/session-14-kubernetes-troubleshooting/04-kubectl-exec ❯ kubectl exec exec-demo -- hostname
exec-demo

…/session-14-kubernetes-troubleshooting/04-kubectl-exec ❯ kubectl exec exec-demo -- cat /etc/hosts
# Kubernetes-managed hosts file.
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
fe00::0	ip6-mcastprefix
fe00::1	ip6-allnodes
fe00::2	ip6-allrouters
10.244.2.43	exec-demo

…/session-14-kubernetes-troubleshooting/04-kubectl-exec ❯ printf 'hostname\nls /usr/share/nginx/html\ncurl -sI localhost | head -1\nexit\n' | kubectl exec -i exec-demo -- bash
exec-demo
50x.html
index.html
HTTP/1.1 200 OK

…/session-14-kubernetes-troubleshooting/04-kubectl-exec ❯ kubectl delete pod exec-demo
pod "exec-demo" deleted from default namespace
```

## 05 - Events

```bash
…/session-14-kubernetes-troubleshooting/05-events ❯ kubectl apply -f pod.yaml
pod/events-demo created

…/session-14-kubernetes-troubleshooting/05-events ❯ kubectl get events --field-selector involvedObject.name=events-demo
LAST SEEN   TYPE     REASON      OBJECT            MESSAGE
6s          Normal   Scheduled   pod/events-demo   Successfully assigned default/events-demo to s-b-worker2
6s          Normal   Pulled      pod/events-demo   Container image "nginx:1.27" already present on machine and can be accessed by the pod
6s          Normal   Created     pod/events-demo   Container created
6s          Normal   Started     pod/events-demo   Container started

…/session-14-kubernetes-troubleshooting/05-events ❯ kubectl get events --sort-by=.lastTimestamp | tail -8
53s         Normal    Killing                        pod/logs-demo                               Stopping container app
21s         Normal    Created                        pod/exec-demo                               Container created
21s         Normal    Started                        pod/exec-demo                               Container started
21s         Normal    Pulled                         pod/exec-demo                               Container image "nginx:1.27" already present on machine and can be accessed by the pod
15s         Normal    Killing                        pod/exec-demo                               Stopping container nginx
6s          Normal    Pulled                         pod/events-demo                             Container image "nginx:1.27" already present on machine and can be accessed by the pod
6s          Normal    Created                        pod/events-demo                             Container created
6s          Normal    Started                        pod/events-demo                             Container started

…/session-14-kubernetes-troubleshooting/05-events ❯ kubectl describe pod events-demo | sed -n '/^Events:/,$p'
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  6s    default-scheduler  Successfully assigned default/events-demo to s-b-worker2
  Normal  Pulled     6s    kubelet            spec.containers{nginx}: Container image "nginx:1.27" already present on machine and can be accessed by the pod
  Normal  Created    6s    kubelet            spec.containers{nginx}: Container created
  Normal  Started    6s    kubelet            spec.containers{nginx}: Container started

…/session-14-kubernetes-troubleshooting/05-events ❯ kubectl events --for pod/events-demo
LAST SEEN   TYPE     REASON      OBJECT            MESSAGE
6s          Normal   Pulled      Pod/events-demo   Container image "nginx:1.27" already present on machine and can be accessed by the pod
6s          Normal   Created     Pod/events-demo   Container created
6s          Normal   Started     Pod/events-demo   Container started
6s          Normal   Scheduled   Pod/events-demo   Successfully assigned default/events-demo to s-b-worker2

…/session-14-kubernetes-troubleshooting/05-events ❯ timeout 12 kubectl events --watch --for pod/events-demo
LAST SEEN   TYPE     REASON      OBJECT            MESSAGE
6s          Normal   Scheduled   Pod/events-demo   Successfully assigned default/events-demo to s-b-worker2
6s          Normal   Pulled      Pod/events-demo   Container image "nginx:1.27" already present on machine and can be accessed by the pod
6s          Normal   Created     Pod/events-demo   Container created
6s          Normal   Started     Pod/events-demo   Container started
0s          Normal   Killing     Pod/events-demo   Stopping container nginx

…/session-14-kubernetes-troubleshooting/05-events ❯ kubectl get events -A --field-selector type=Warning | tail -5
kube-system          22m         Warning   Unhealthy                      pod/metrics-server-84c99cb944-ggt4s             Liveness probe failed: Get "https://10.244.1.3:10250/livez": context deadline exceeded
kube-system          18m         Warning   Unhealthy                      pod/metrics-server-84c99cb944-ggt4s             Readiness probe failed: Get "https://10.244.1.3:10250/readyz": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
kube-system          19m         Warning   Unhealthy                      pod/metrics-server-84c99cb944-ggt4s             Liveness probe failed: Get "https://10.244.1.3:10250/livez": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
kube-system          27m         Warning   Unhealthy                      pod/metrics-server-84c99cb944-ggt4s             Readiness probe failed: Get "https://10.244.1.3:10250/readyz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
local-path-storage   41m         Warning   FailedScheduling               pod/local-path-provisioner-75f7fc7dc5-mc5ss     0/1 nodes are available: 1 node(s) had untolerated taint(s). preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.
```

## 06 - CrashLoopBackOff

```bash
…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ kubectl apply -f broken-pod.yaml
pod/crash-demo created

…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ timeout 45 kubectl get pod crash-demo -w
NAME         READY   STATUS              RESTARTS   AGE
crash-demo   0/1     ContainerCreating   0          0s
crash-demo   0/1     ContainerCreating   0          0s
crash-demo   1/1     Running             0          0s
crash-demo   0/1     Error               0          0s
crash-demo   1/1     Running             1 (1s ago)   1s
crash-demo   0/1     Error               1 (1s ago)   1s
crash-demo   0/1     CrashLoopBackOff    1 (13s ago)   14s
crash-demo   1/1     Running             2 (13s ago)   14s
crash-demo   0/1     Error               2 (14s ago)   15s
crash-demo   0/1     CrashLoopBackOff    2 (30s ago)   44s
crash-demo   1/1     Running             3 (30s ago)   44s
crash-demo   0/1     Error               3 (31s ago)   45s

…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ kubectl get pod crash-demo
NAME         READY   STATUS   RESTARTS      AGE
crash-demo   0/1     Error    3 (31s ago)   45s

…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ kubectl describe pod crash-demo
Name:             crash-demo
Namespace:        default
Priority:         0
Service Account:  default
Node:             s-b-worker2/172.19.0.2
Start Time:       Mon, 26 Oct 2026 15:15:22 +0530
Labels:           <none>
Annotations:      <none>
Status:           Running
IP:               10.244.2.45
IPs:
  IP:  10.244.2.45
Containers:
  app:
    Container ID:  containerd://ef575e8d2088459ed53978a55653b6a19d3fcd31314e3e9daf1f514c1afbbb8f
    Image:         busybox:1.36
    Image ID:      docker.io/library/busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      echo "Application starting..."
      echo "Something went wrong!"
      exit 1
      
    State:          Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Mon, 26 Oct 2026 15:16:06 +0530
      Finished:     Mon, 26 Oct 2026 15:16:06 +0530
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Mon, 26 Oct 2026 15:15:36 +0530
      Finished:     Mon, 26 Oct 2026 15:15:36 +0530
    Ready:          False
    Restart Count:  3
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-59ql7 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  kube-api-access-59ql7:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  45s               default-scheduler  Successfully assigned default/crash-demo to s-b-worker2
  Normal   Pulled     1s (x4 over 45s)  kubelet            spec.containers{app}: Container image "busybox:1.36" already present on machine and can be accessed by the pod
  Normal   Created    1s (x4 over 45s)  kubelet            spec.containers{app}: Container created
  Normal   Started    1s (x4 over 45s)  kubelet            spec.containers{app}: Container started
  Warning  BackOff    0s (x3 over 44s)  kubelet            spec.containers{app}: Back-off restarting failed container app in pod crash-demo_default(19693793-20d6-454c-84e7-27cfabb03473)

…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ kubectl logs crash-demo
Application starting...
Something went wrong!

…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ kubectl logs crash-demo --previous
unable to retrieve container logs for containerd://db0a5461f7bfea92c305c217a40e2650d290d2f490b112d7c8f3966c01278a35

…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ kubectl get pod crash-demo -o jsonpath='{.status.containerStatuses[0].lastState.terminated}' ; echo
{"containerID":"containerd://db0a5461f7bfea92c305c217a40e2650d290d2f490b112d7c8f3966c01278a35","exitCode":1,"finishedAt":"2026-10-26T09:45:36Z","reason":"Error","startedAt":"2026-10-26T09:45:36Z"}
```

Root cause: the command ends with `exit 1` (Exit Code 1 in `Last State`). `--previous` couldn't fetch the old container's logs here because it had already been cleaned up. The current container's logs and `lastState.terminated` still show the reason.

**Fix:** `fixed-pod.yaml` replaces `exit 1` with `sleep 3600`.

```bash
…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ kubectl delete pod crash-demo
pod "crash-demo" deleted from default namespace

…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ kubectl apply -f fixed-pod.yaml
pod/crash-demo created

…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ kubectl get pod crash-demo
NAME         READY   STATUS    RESTARTS   AGE
crash-demo   1/1     Running   0          6s

…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ kubectl logs crash-demo
Application starting...
Application is healthy

…/session-14-kubernetes-troubleshooting/06-crashloopbackoff ❯ kubectl delete pod crash-demo
pod "crash-demo" deleted from default namespace
```

## 07 - ImagePullBackOff

```bash
…/session-14-kubernetes-troubleshooting/07-imagepullbackoff ❯ kubectl apply -f broken-pod.yaml
pod/image-demo created

…/session-14-kubernetes-troubleshooting/07-imagepullbackoff ❯ timeout 40 kubectl get pod image-demo -w
NAME         READY   STATUS              RESTARTS   AGE
image-demo   0/1     ContainerCreating   0          0s
image-demo   0/1     ContainerCreating   0          1s
image-demo   0/1     ErrImagePull        0          3s
image-demo   0/1     ImagePullBackOff    0          18s
image-demo   0/1     ErrImagePull        0          32s

…/session-14-kubernetes-troubleshooting/07-imagepullbackoff ❯ kubectl get pod image-demo
NAME         READY   STATUS         RESTARTS   AGE
image-demo   0/1     ErrImagePull   0          40s

…/session-14-kubernetes-troubleshooting/07-imagepullbackoff ❯ kubectl describe pod image-demo | sed -n '/^Containers:/,/Ready:/p;/^Events:/,$p'
Containers:
  app:
    Container ID:   
    Image:          nginx:this-image-does-not-exist
    Image ID:       
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ErrImagePull
    Ready:          False
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  40s                default-scheduler  Successfully assigned default/image-demo to s-b-worker2
  Normal   Pulling    22s (x2 over 39s)  kubelet            spec.containers{app}: Pulling image "nginx:this-image-does-not-exist"
  Warning  Failed     21s (x2 over 38s)  kubelet            spec.containers{app}: Failed to pull image "nginx:this-image-does-not-exist": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/library/nginx:this-image-does-not-exist": failed to resolve reference "docker.io/library/nginx:this-image-does-not-exist": docker.io/library/nginx:this-image-does-not-exist: not found
  Warning  Failed     21s (x2 over 38s)  kubelet            spec.containers{app}: Error: ErrImagePull
  Normal   BackOff    8s (x2 over 37s)   kubelet            spec.containers{app}: Back-off pulling image "nginx:this-image-does-not-exist"
  Warning  Failed     8s (x2 over 37s)   kubelet            spec.containers{app}: Error: ImagePullBackOff

…/session-14-kubernetes-troubleshooting/07-imagepullbackoff ❯ grep image: broken-pod.yaml fixed-pod.yaml
broken-pod.yaml:      image: nginx:this-image-does-not-exist
fixed-pod.yaml:      image: nginx:1.27

…/session-14-kubernetes-troubleshooting/07-imagepullbackoff ❯ kubectl delete pod image-demo
pod "image-demo" deleted from default namespace

…/session-14-kubernetes-troubleshooting/07-imagepullbackoff ❯ kubectl apply -f fixed-pod.yaml
pod/image-demo created

…/session-14-kubernetes-troubleshooting/07-imagepullbackoff ❯ kubectl get pod image-demo
NAME         READY   STATUS    RESTARTS   AGE
image-demo   1/1     Running   0          6s

…/session-14-kubernetes-troubleshooting/07-imagepullbackoff ❯ kubectl delete pod image-demo
pod "image-demo" deleted from default namespace
```

## 08 - Pending Pods

```bash
…/session-14-kubernetes-troubleshooting/08-pending-pods ❯ kubectl apply -f broken-pod.yaml
pod/pending-demo created

…/session-14-kubernetes-troubleshooting/08-pending-pods ❯ kubectl get pod pending-demo -o wide
NAME           READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
pending-demo   0/1     Pending   0          10s   <none>   <none>   <none>           <none>

…/session-14-kubernetes-troubleshooting/08-pending-pods ❯ kubectl describe pod pending-demo
Name:             pending-demo
Namespace:        default
Priority:         0
Service Account:  default
Node:             <none>
Labels:           <none>
Annotations:      <none>
Status:           Pending
IP:               
IPs:              <none>
Containers:
  nginx:
    Image:        nginx:1.27
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-6nn48 (ro)
Conditions:
  Type           Status
  PodScheduled   False 
Volumes:
  kube-api-access-6nn48:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              kubernetes.io/hostname=node-that-does-not-exist
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  10s   default-scheduler  0/3 nodes are available: 1 node(s) had untolerated taint(s), 2 node(s) didn't match Pod's node affinity/selector. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.

…/session-14-kubernetes-troubleshooting/08-pending-pods ❯ kubectl get nodes --show-labels
NAME                STATUS   ROLES           AGE   VERSION   LABELS
s-b-control-plane   Ready    control-plane   44m   v1.37.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ingress-ready=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=s-b-control-plane,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
s-b-worker          Ready    <none>          44m   v1.37.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=s-b-worker,kubernetes.io/os=linux
s-b-worker2         Ready    <none>          44m   v1.37.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=s-b-worker2,kubernetes.io/os=linux

…/session-14-kubernetes-troubleshooting/08-pending-pods ❯ kubectl delete pod pending-demo
pod "pending-demo" deleted from default namespace

…/session-14-kubernetes-troubleshooting/08-pending-pods ❯ kubectl apply -f fixed-pod.yaml
pod/pending-demo created

…/session-14-kubernetes-troubleshooting/08-pending-pods ❯ kubectl get pod pending-demo -o wide
NAME           READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
pending-demo   1/1     Running   0          6s    10.244.2.49   s-b-worker2   <none>           <none>

…/session-14-kubernetes-troubleshooting/08-pending-pods ❯ kubectl delete pod pending-demo
pod "pending-demo" deleted from default namespace
```

`FailedScheduling`: 2 workers didn't match `kubernetes.io/hostname=node-that-does-not-exist`, and the control-plane has a NoSchedule taint. `fixed-pod.yaml` drops the `nodeSelector`.

## 09 - Service & DNS

### Deploy and check the Service

```bash
…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl apply -f deployment.yaml
deployment.apps/web created

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
web-557577df75-4hldp   1/1     Running   0          0s
web-557577df75-k7ms7   1/1     Running   0          0s

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl apply -f service.yaml
service/web-service created

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get service
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP   44m
web-service   ClusterIP   10.96.243.151   <none>        80/TCP    0s

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl describe service web-service
Name:                     web-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=web-ahsgdf
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.96.243.151
IPs:                      10.96.243.151
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
Endpoints:                
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get endpoints web-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME          ENDPOINTS   AGE
web-service   <none>      0s
```

The **`service.yaml` in this folder is broken**: its selector is `app: web-ahsgdf`, but the Pods are labelled `app: web`, so there are no endpoints.

### DNS test pod - image doesn't exist

```bash
…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl apply -f dns-test-pod.yaml
pod/dns-test created

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get pod dns-test
NAME       READY   STATUS             RESTARTS   AGE
dns-test   0/1     ImagePullBackOff   0          3m

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl exec dns-test -- nslookup web-service
error: unable to upgrade connection: container not found ("dns-test")

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl exec dns-test -- wget -qO- -T 5 http://web-service
error: unable to upgrade connection: container not found ("dns-test")

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl describe pod dns-test | sed -n '/^Events:/,$p'
Events:
  Type     Reason     Age                  From               Message
  ----     ------     ----                 ----               -------
  Normal   Scheduled  3m5s                 default-scheduler  Successfully assigned default/dns-test to s-b-worker2
  Normal   BackOff    19s (x10 over 3m4s)  kubelet            spec.containers{dns-test}: Back-off pulling image "registry.k8s.io/e2e-test-images/dnsutils:1.3"
  Warning  Failed     19s (x10 over 3m4s)  kubelet            spec.containers{dns-test}: Error: ImagePullBackOff
  Normal   Pulling    6s (x5 over 3m5s)    kubelet            spec.containers{dns-test}: Pulling image "registry.k8s.io/e2e-test-images/dnsutils:1.3"
  Warning  Failed     6s (x5 over 3m5s)    kubelet            spec.containers{dns-test}: Failed to pull image "registry.k8s.io/e2e-test-images/dnsutils:1.3": rpc error: code = NotFound desc = failed to pull and unpack image "registry.k8s.io/e2e-test-images/dnsutils:1.3": failed to resolve reference "registry.k8s.io/e2e-test-images/dnsutils:1.3": registry.k8s.io/e2e-test-images/dnsutils:1.3: not found
  Warning  Failed     6s (x5 over 3m5s)    kubelet            spec.containers{dns-test}: Error: ErrImagePull
```

`registry.k8s.io/e2e-test-images/dnsutils:1.3` no longer exists (`not found`). **Fix:** switch to `registry.k8s.io/e2e-test-images/jessie-dnsutils:1.7`:

```bash
…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl delete pod dns-test
pod "dns-test" deleted from default namespace

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ grep image: dns-test-pod.yaml
      image: registry.k8s.io/e2e-test-images/jessie-dnsutils:1.7   # dnsutils:1.3 tag no longer exists

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl apply -f dns-test-pod.yaml
pod/dns-test created

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get pod dns-test
NAME       READY   STATUS    RESTARTS   AGE
dns-test   1/1     Running   0          27s

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl exec dns-test -- nslookup web-service
Server:		10.96.0.10
Address:	10.96.0.10#53

Name:	web-service.default.svc.cluster.local
Address: 10.96.243.151

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl exec dns-test -- nslookup web-service.default.svc.cluster.local
Server:		10.96.0.10
Address:	10.96.0.10#53

Name:	web-service.default.svc.cluster.local
Address: 10.96.243.151
```

DNS works: `web-service` resolves to its ClusterIP. The image has no `wget`, so I ran the HTTP test from a throwaway busybox Pod:

```bash
…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl exec dns-test -- wget -qO- -T 5 http://web-service
error: Internal error occurred: Internal error occurred: error executing command in container: failed to exec in container: failed to start exec "891fa6d5348064844ca3b523c534bba78b0749f51d6aa023f4620bfd16a08bb2": OCI runtime exec failed: exec failed: unable to start container process: exec: "wget": executable file not found in $PATH

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl exec dns-test -- sh -c 'which wget curl dig nslookup'
/usr/bin/dig
/usr/bin/nslookup
command terminated with exit code 1

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl run http-test --rm -i --image=busybox:1.36 --restart=Never -- wget -qO- -T 5 http://web-service
All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
If you don't see a command prompt, try pressing enter.
wget: can't connect to remote host (10.96.243.151): Connection refused
pod "http-test" deleted from default namespace
pod default/http-test terminated (Error)

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get pods --show-labels
NAME                   READY   STATUS    RESTARTS   AGE     LABELS
dns-test               1/1     Running   0          42s     <none>
web-557577df75-4hldp   1/1     Running   0          8m36s   app=web,pod-template-hash=557577df75
web-557577df75-k7ms7   1/1     Running   0          8m36s   app=web,pod-template-hash=557577df75

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl describe service web-service | grep -E 'Selector|Endpoints'
Selector:                 app=web-ahsgdf
Endpoints:                
```

**DNS works but HTTP fails** (README section 17): the name resolves, but the connection is refused because the Service has no endpoints. Comparing labels and the selector shows the mismatch: `app=web` vs `app=web-ahsgdf`.

### Fix the Service selector

```bash
…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ grep -A1 selector service.yaml
  selector:
    app: web

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl apply -f service.yaml
service/web-service configured

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get endpoints web-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME          ENDPOINTS                       AGE
web-service   10.244.1.16:80,10.244.2.50:80   8m46s

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl run http-test --rm -i --image=busybox:1.36 --restart=Never -- wget -qO- -T 5 http://web-service | head -4
All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
If you don't see a command prompt, try pressing enter.
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
warning: couldn't attach to pod/http-test, falling back to streaming logs: Internal error occurred: Internal error occurred: error attaching to container: container is in CONTAINER_EXITED state
```

### Intentionally broken Service

```bash
…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl apply -f broken-service.yaml
service/broken-service created

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get service broken-service
NAME             TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
broken-service   ClusterIP   10.96.80.9   <none>        80/TCP    0s

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get endpoints broken-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME             ENDPOINTS   AGE
broken-service   <none>      0s

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl delete service broken-service
service "broken-service" deleted from default namespace

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get service web-service
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
web-service   ClusterIP   10.96.243.151   <none>        80/TCP    8m47s

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get endpoints web-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME          ENDPOINTS                       AGE
web-service   10.244.1.16:80,10.244.2.50:80   8m47s
```

### CoreDNS checks

```bash
…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl get pods -n kube-system | grep -E 'NAME|coredns'
NAME                                        READY   STATUS    RESTARTS      AGE
coredns-559f6c778d-hvshg                    1/1     Running   0             53m
coredns-559f6c778d-s2wzj                    1/1     Running   0             53m

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl exec dns-test -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl logs -n kube-system -l k8s-app=kube-dns
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" took more than 1s: 2.192537876s
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" took more than 1s: 6.146960797s
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" took more than 1s: 7.320336972s
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" took more than 1s: 2.352188462s
[WARNING] plugin/health: Local health request to "http://:8080/health" took more than 1s: 2.150110705s
[WARNING] plugin/health: Local health request to "http://:8080/health" failed: Get "http://:8080/health": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[WARNING] plugin/health: Local health request to "http://:8080/health" took more than 1s: 7.988973613s

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl exec dns-test -- nslookup does-not-exist-service
Server:		10.96.0.10
Address:	10.96.0.10#53

** server can't find does-not-exist-service: NXDOMAIN

command terminated with exit code 1

…/session-14-kubernetes-troubleshooting/09-service-dns-troubleshooting ❯ kubectl delete -f deployment.yaml -f service.yaml -f dns-test-pod.yaml
deployment.apps "web" deleted from default namespace
service "web-service" deleted from default namespace
pod "dns-test" deleted from default namespace
```

The CoreDNS health-check warnings are from earlier in the session, when the host was overloaded (load average ~68) and probe requests timed out. DNS resolution itself kept working.

## Mini Project - Troubleshooting Challenge

### 1-4. Deploy and check the application

```bash
…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl apply -f deployment.yaml
deployment.apps/troubleshooting-app created

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl apply -f service.yaml
service/troubleshooting-service created

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl get pods
NAME                                   READY   STATUS      RESTARTS   AGE
http-test                              0/1     Completed   0          40s
troubleshooting-app-59d4957864-5fzfj   1/1     Running     0          0s
troubleshooting-app-59d4957864-7wjjf   1/1     Running     0          0s

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl get service
NAME                      TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
kubernetes                ClusterIP   10.96.0.1     <none>        443/TCP   54m
troubleshooting-service   ClusterIP   10.96.59.62   <none>        80/TCP    0s

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl get pods -o wide
NAME                                   READY   STATUS      RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
http-test                              0/1     Completed   0          41s   10.244.1.17   s-b-worker    <none>           <none>
troubleshooting-app-59d4957864-5fzfj   1/1     Running     0          1s    10.244.1.18   s-b-worker    <none>           <none>
troubleshooting-app-59d4957864-7wjjf   1/1     Running     0          1s    10.244.2.55   s-b-worker2   <none>           <none>

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl describe pod troubleshooting-app-59d4957864-5fzfj | sed -n '/^Containers:/,/Restart Count/p;/^Events:/,$p'
Containers:
  app:
    Container ID:   containerd://03f5b62d4e98dd2461d89350ce60b7488cd8ec1192bd27b3816b76d9776d5690
    Image:          nginx:1.27
    Image ID:       docker.io/library/nginx@sha256:6784fb0834aa7dbbe12e3d7471e69c290df3e6ba810dc38b34ae33d3c1c05f7d
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 26 Oct 2026 15:27:33 +0530
    Ready:          True
    Restart Count:  0
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  0s    default-scheduler  Successfully assigned default/troubleshooting-app-59d4957864-5fzfj to s-b-worker
  Normal  Pulled     1s    kubelet            spec.containers{app}: Container image "nginx:1.27" already present on machine and can be accessed by the pod
  Normal  Created    1s    kubelet            spec.containers{app}: Container created
  Normal  Started    1s    kubelet            spec.containers{app}: Container started

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl logs troubleshooting-app-59d4957864-5fzfj
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/10/26 09:57:33 [notice] 1#1: using the "epoll" event method
2026/10/26 09:57:33 [notice] 1#1: nginx/1.27.5
2026/10/26 09:57:33 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14) 
2026/10/26 09:57:33 [notice] 1#1: OS: Linux 7.2.5-3-omarchy
2026/10/26 09:57:33 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 2147483584:2147483584
2026/10/26 09:57:33 [notice] 1#1: start worker processes
2026/10/26 09:57:33 [notice] 1#1: start worker process 36
2026/10/26 09:57:33 [notice] 1#1: start worker process 37
2026/10/26 09:57:33 [notice] 1#1: start worker process 38
2026/10/26 09:57:33 [notice] 1#1: start worker process 39
2026/10/26 09:57:33 [notice] 1#1: start worker process 40
2026/10/26 09:57:33 [notice] 1#1: start worker process 41
2026/10/26 09:57:33 [notice] 1#1: start worker process 42
2026/10/26 09:57:33 [notice] 1#1: start worker process 43

…/session-14-kubernetes-troubleshooting/mini-project ❯ echo 'curl -s localhost | head -4' | kubectl exec -i troubleshooting-app-59d4957864-5fzfj -- bash
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl describe service troubleshooting-service
Name:                     troubleshooting-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=troubleshooting-app
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.96.59.62
IPs:                      10.96.59.62
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
Endpoints:                10.244.2.55:80,10.244.1.18:80
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl get endpoints troubleshooting-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                      ENDPOINTS                       AGE
troubleshooting-service   10.244.1.18:80,10.244.2.55:80   1s
```

### 5-6. Broken Pod

```bash
…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl apply -f broken-pod.yaml
pod/project-broken-pod created

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl get pod project-broken-pod
NAME                 READY   STATUS             RESTARTS   AGE
project-broken-pod   0/1     ImagePullBackOff   0          25s

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl describe pod project-broken-pod | sed -n '/^Containers:/,/Ready:/p;/^Events:/,$p'
Containers:
  app:
    Container ID:   
    Image:          nginx:this-tag-does-not-exist
    Image ID:       
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  25s                default-scheduler  Successfully assigned default/project-broken-pod to s-b-worker2
  Normal   BackOff    23s                kubelet            spec.containers{app}: Back-off pulling image "nginx:this-tag-does-not-exist"
  Warning  Failed     23s                kubelet            spec.containers{app}: Error: ImagePullBackOff
  Normal   Pulling    11s (x2 over 24s)  kubelet            spec.containers{app}: Pulling image "nginx:this-tag-does-not-exist"
  Warning  Failed     10s (x2 over 23s)  kubelet            spec.containers{app}: Failed to pull image "nginx:this-tag-does-not-exist": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/library/nginx:this-tag-does-not-exist": failed to resolve reference "docker.io/library/nginx:this-tag-does-not-exist": docker.io/library/nginx:this-tag-does-not-exist: not found
  Warning  Failed     10s (x2 over 23s)  kubelet            spec.containers{app}: Error: ErrImagePull
```

### 7. Answers

| Question | Answer |
| :--- | :--- |
| Pod status? | `ImagePullBackOff` (alternates with `ErrImagePull`) |
| Actual error? | `failed to resolve reference "docker.io/library/nginx:this-tag-does-not-exist": not found` |
| Command that found it? | `kubectl describe pod project-broken-pod` (Events section) |
| What's wrong with the image? | The tag `this-tag-does-not-exist` doesn't exist for `nginx` on Docker Hub |
| Fix? | Use a real tag (`nginx:1.27`), delete and re-apply the Pod |

```bash
…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl delete pod project-broken-pod
pod "project-broken-pod" deleted from default namespace

…/session-14-kubernetes-troubleshooting/mini-project ❯ grep image: broken-pod.yaml
      image: nginx:1.27

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl apply -f broken-pod.yaml
pod/project-broken-pod created

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl get pod project-broken-pod
NAME                 READY   STATUS    RESTARTS   AGE
project-broken-pod   1/1     Running   0          5s
```

### 8-9. Service selector challenge

```bash
…/session-14-kubernetes-troubleshooting/mini-project ❯ grep -A1 selector service.yaml
  selector:
    app: wrong-app

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl apply -f service.yaml
service/troubleshooting-service configured

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl get service
NAME                      TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
kubernetes                ClusterIP   10.96.0.1     <none>        443/TCP   55m
troubleshooting-service   ClusterIP   10.96.59.62   <none>        80/TCP    42s

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl get endpoints troubleshooting-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                      ENDPOINTS   AGE
troubleshooting-service   <none>      42s

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl get pods --show-labels
NAME                                   READY   STATUS    RESTARTS   AGE   LABELS
project-broken-pod                     1/1     Running   0          5s    <none>
troubleshooting-app-59d4957864-5fzfj   1/1     Running   0          42s   app=troubleshooting-app,pod-template-hash=59d4957864
troubleshooting-app-59d4957864-7wjjf   1/1     Running   0          42s   app=troubleshooting-app,pod-template-hash=59d4957864

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl describe service troubleshooting-service | grep -E 'Selector|Endpoints'
Selector:                 app=wrong-app
Endpoints:                

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl run http-test --rm -i --image=busybox:1.36 --restart=Never -- wget -qO- -T 5 http://troubleshooting-service 2>&1 | grep -v -e 'All commands' -e 'see a command prompt'
wget: can't connect to remote host (10.96.59.62): Connection refused
pod "http-test" deleted from default namespace
pod default/http-test terminated (Error)
```

Root cause: Service selector `app=wrong-app` but Pod label `app=troubleshooting-app`. Fix it back:

```bash
…/session-14-kubernetes-troubleshooting/mini-project ❯ grep -A1 selector service.yaml
  selector:
    app: troubleshooting-app

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl apply -f service.yaml
service/troubleshooting-service configured

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl get endpoints troubleshooting-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                      ENDPOINTS                       AGE
troubleshooting-service   10.244.1.18:80,10.244.2.55:80   48s

…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl run http-test --rm -i --image=busybox:1.36 --restart=Never -- wget -qO- -T 5 http://troubleshooting-service 2>&1 | grep -i title
<title>Welcome to nginx!</title>
```
```bash
…/session-14-kubernetes-troubleshooting/mini-project ❯ kubectl delete -f deployment.yaml -f service.yaml -f broken-pod.yaml
deployment.apps "troubleshooting-app" deleted from default namespace
service "troubleshooting-service" deleted from default namespace
pod "project-broken-pod" deleted from default namespace
```

### 11. Troubleshooting table

| Problem | What I Saw | Command I Used | Root Cause | Fix |
| :--- | :--- | :--- | :--- | :--- |
| **Broken Pod** | `0/1 ImagePullBackOff` | `kubectl get pod`, `kubectl describe pod` | Image tag can't be pulled | Corrected the image tag and recreated the Pod |
| **Service Problem** | `ENDPOINTS <none>`, `wget: Connection refused` | `kubectl get endpoints`, `kubectl get pods --show-labels`, `kubectl describe svc` | Selector `app=wrong-app` doesn't match label `app=troubleshooting-app` | Selector set back to `app: troubleshooting-app` |
| **Image Problem** | `Failed to pull image ... not found` in Events | `kubectl describe pod` | `nginx:this-tag-does-not-exist` doesn't exist | `image: nginx:1.27` |

### 12. README questions

1. **`kubectl get`** shows the current state or summary of resources: status, ready count, restarts, age.
2. **get vs describe:** `get` is a one-line summary. `describe` gives full detail: spec, container state and last state, conditions, and the Events list explaining *why*.
3. **`kubectl logs`** shows what the application itself printed to stdout/stderr. `--previous` shows the last crashed container's logs.
4. **`kubectl exec`** is for running commands inside a running container: checking files or config, `curl localhost`, DNS lookups.
5. **CrashLoopBackOff:** the container keeps starting and exiting, and kubelet waits longer and longer between restarts.
6. **ImagePullBackOff:** kubelet can't pull the image (wrong name or tag, private registry, no network) and is backing off between retries.
7. **Pending:** the scheduler can't place the Pod (not enough CPU/memory, nodeSelector or affinity mismatch, taints, unbound PVC), or the scheduler itself is down.
8. **No endpoints:** no *Ready* Pod matches the Service's selector. Usually a label/selector typo or failing readiness probes.
9. **Selector and labels:** the Service selects every Pod whose labels match all of its selector's key/value pairs. Those Pod IPs become the endpoints.
10. **Kubernetes DNS:** CoreDNS (the `kube-dns` Service, `10.96.0.10`) resolves `<svc>.<namespace>.svc.cluster.local` to the Service's ClusterIP. Pods get it through `/etc/resolv.conf`.

## Scenarios - Triage Gauntlet (`triage_all.sh`)

```bash
…/session-14-kubernetes-troubleshooting/scenarios ❯ bash triage_all.sh
==================================================
      KUBERNETES INCIDENT TRIAGE GAUNTLET         
==================================================
Deploying 5 intentionally broken production workloads...

pod/fail-1-crashloop-pod created
pod/fail-2-imagepull-pod created
pod/fail-3-pending-pod created
pod/fail-4-dns-failure-pod created
pod/fail-5-oomkilled-pod created

Workloads deployed! Sleeping 5s to allow states to settle...

=== CURRENT CLUSTER CARNAGE ===
NAME                     READY   STATUS              RESTARTS   AGE
fail-1-crashloop-pod     0/1     ContainerCreating   0          6s
fail-2-imagepull-pod     0/1     ErrImagePull        0          5s
fail-3-pending-pod       0/1     Pending             0          5s
fail-4-dns-failure-pod   0/1     ContainerCreating   0          5s
fail-5-oomkilled-pod     0/1     ContainerCreating   0          5s

==================================================
Your mission: Diagnose and fix each of the 5 pods!
Follow the diagnostic guide in README.md!
==================================================

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl get pods -l tier=triage-gauntlet -o wide
NAME                     READY   STATUS             RESTARTS      AGE   IP            NODE          NOMINATED NODE   READINESS GATES
fail-1-crashloop-pod     0/1     Error              3 (23s ago)   46s   10.244.2.59   s-b-worker2   <none>           <none>
fail-2-imagepull-pod     0/1     ImagePullBackOff   0             45s   10.244.1.20   s-b-worker    <none>           <none>
fail-3-pending-pod       0/1     Pending            0             45s   <none>        <none>        <none>           <none>
fail-4-dns-failure-pod   1/1     Running            0             45s   10.244.2.60   s-b-worker2   <none>           <none>
fail-5-oomkilled-pod     0/1     OOMKilled          2 (30s ago)   45s   10.244.2.61   s-b-worker2   <none>           <none>
```

### Diagnosis

```bash
…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl logs fail-1-crashloop-pod
[FATAL ERROR]: DATABASE_URL environment variable is MISSING!

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl describe pod fail-1-crashloop-pod | sed -n '/State:/,/Restart Count/p'
    State:          Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Mon, 26 Oct 2026 15:29:16 +0530
      Finished:     Mon, 26 Oct 2026 15:29:16 +0530
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Mon, 26 Oct 2026 15:28:54 +0530
      Finished:     Mon, 26 Oct 2026 15:28:54 +0530
    Ready:          False
    Restart Count:  3

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl describe pod fail-2-imagepull-pod | grep -E 'Failed|BackOff'
      Reason:       ImagePullBackOff
  Normal   BackOff    23s (x2 over 51s)  kubelet            spec.containers{web-app}: Back-off pulling image "yatri-api-service:v999-invalid-tag-does-not-exist"
  Warning  Failed     23s (x2 over 51s)  kubelet            spec.containers{web-app}: Error: ImagePullBackOff
  Warning  Failed     11s (x3 over 52s)  kubelet            spec.containers{web-app}: Failed to pull image "yatri-api-service:v999-invalid-tag-does-not-exist": failed to pull and unpack image "docker.io/library/yatri-api-service:v999-invalid-tag-does-not-exist": failed to resolve reference "docker.io/library/yatri-api-service:v999-invalid-tag-does-not-exist": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
  Warning  Failed     11s (x3 over 52s)  kubelet            spec.containers{web-app}: Error: ErrImagePull

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl describe pod fail-3-pending-pod | sed -n '/Requests:/,/memory/p;/^Events:/,$p'
    Requests:
      cpu:        500
      memory:     1000Gi
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  52s   default-scheduler  0/3 nodes are available: 1 node(s) had untolerated taint(s), 2 Insufficient cpu, 2 Insufficient memory. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl describe nodes | grep -A6 '^Allocatable'
Allocatable:
  cpu:                8
  ephemeral-storage:  111651323904
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             15928256Ki
  pods:               110
--
Allocatable:
  cpu:                8
  ephemeral-storage:  111651323904
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             15928256Ki
  pods:               110
--
Allocatable:
  cpu:                8
  ephemeral-storage:  111651323904
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             15928256Ki
  pods:               110

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl logs fail-4-dns-failure-pod
Attempting connection to internal database...
Process sleeping...

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl exec fail-4-dns-failure-pod -- nslookup postgres-db-wrong-name.production.svc.cluster.local
Server:		10.96.0.10
Address:	10.96.0.10:53

** server can't find postgres-db-wrong-name.production.svc.cluster.local: NXDOMAIN

** server can't find postgres-db-wrong-name.production.svc.cluster.local: NXDOMAIN

command terminated with exit code 1

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl get svc -A
NAMESPACE     NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                  AGE
default       kubernetes       ClusterIP   10.96.0.1      <none>        443/TCP                  56m
kube-system   kube-dns         ClusterIP   10.96.0.10     <none>        53/UDP,53/TCP,9153/TCP   56m
kube-system   metrics-server   ClusterIP   10.96.27.132   <none>        443/TCP                  55m

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl describe pod fail-5-oomkilled-pod | sed -n '/State:/,/Restart Count/p;/Limits:/,/memory/p'
    State:          Terminated
      Reason:       OOMKilled
      Exit Code:    137
      Started:      Mon, 26 Oct 2026 15:29:02 +0530
      Finished:     Mon, 26 Oct 2026 15:29:02 +0530
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
      Started:      Mon, 26 Oct 2026 15:28:47 +0530
      Finished:     Mon, 26 Oct 2026 15:28:47 +0530
    Ready:          False
    Restart Count:  2
    Limits:
      memory:  20Mi

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl logs fail-5-oomkilled-pod --previous
unable to retrieve container logs for containerd://2f1d660795d6eb64616f3fb809d775c77a3c58a9c3c9be3d7f4bf86001dc6aec
```

| # | Pod | Symptom | Root cause |
| :--- | :--- | :--- | :--- |
| 1 | fail-1-crashloop-pod | `Error` / CrashLoopBackOff, exit 1 | `DATABASE_URL` env var missing (from the logs) |
| 2 | fail-2-imagepull-pod | ImagePullBackOff | `yatri-api-service` repo doesn't exist on Docker Hub |
| 3 | fail-3-pending-pod | Pending | Requests 500 CPU / 1000Gi; nodes only have 8 CPU / ~15Gi |
| 4 | fail-4-dns-failure-pod | Running, but `curl` silently fails | `postgres-db-wrong-name` -> NXDOMAIN, and no such Service exists |
| 5 | fail-5-oomkilled-pod | OOMKilled, exit 137 | Allocates far more memory than the 20Mi limit |

### Fixes (1, 2, 3, 5)

```bash
…/session-14-kubernetes-troubleshooting/scenarios ❯ diff scenario-1-*/broken.yaml scenario-1-*/fixed.yaml
8a9
>   restartPolicy: OnFailure   # FIX: one-shot app, do not restart after a clean exit
11a13,15
>       env:
>         - name: DATABASE_URL   # FIX: provide the required env var
>           value: "postgres://app:secret@postgres-db.production.svc.cluster.local:5432/app"

…/session-14-kubernetes-troubleshooting/scenarios ❯ diff scenario-2-*/broken.yaml scenario-2-*/fixed.yaml
11,12c11,12
<       # BUG: Typo in image name and tag
<       image: yatri-api-service:v999-invalid-tag-does-not-exist
---
>       # FIX: use an image + tag that actually exists in the registry
>       image: nginx:1.27

…/session-14-kubernetes-troubleshooting/scenarios ❯ diff scenario-3-*/broken.yaml scenario-3-*/fixed.yaml
14,16c14,16
<           # BUG: Demanding 500 CPU cores ensures the pod can never be scheduled!
<           cpu: "500"
<           memory: "1000Gi"
---
>           # FIX: realistic requests that fit on a node (8 CPU / ~15Gi allocatable)
>           cpu: "100m"
>           memory: "128Mi"

…/session-14-kubernetes-troubleshooting/scenarios ❯ diff scenario-5-*/broken.yaml scenario-5-*/fixed.yaml
8a9
>   restartPolicy: OnFailure   # one-shot script
20a22
>           print("Allocated", len(chunks) * 10, "MB OK")
23c25
<           memory: "20Mi"
---
>           memory: "256Mi"   # FIX: limit above the ~100MB the app needs

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl delete pod fail-1-crashloop-pod fail-2-imagepull-pod fail-3-pending-pod fail-5-oomkilled-pod
pod "fail-1-crashloop-pod" deleted from default namespace
pod "fail-2-imagepull-pod" deleted from default namespace
pod "fail-3-pending-pod" deleted from default namespace
pod "fail-5-oomkilled-pod" deleted from default namespace

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl apply -f scenario-1-crashloop/fixed.yaml -f scenario-2-imagepull/fixed.yaml -f scenario-3-pending/fixed.yaml -f scenario-5-oomkilled/fixed.yaml
pod/fail-1-crashloop-pod created
pod/fail-2-imagepull-pod created
pod/fail-3-pending-pod created
pod/fail-5-oomkilled-pod created

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl get pods -l tier=triage-gauntlet
NAME                     READY   STATUS             RESTARTS     AGE
fail-1-crashloop-pod     0/1     Completed          0            20s
fail-2-imagepull-pod     1/1     Running            0            20s
fail-3-pending-pod       1/1     Running            0            20s
fail-4-dns-failure-pod   1/1     Running            0            101s
fail-5-oomkilled-pod     0/1     CrashLoopBackOff   1 (8s ago)   20s

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl logs fail-1-crashloop-pod
Application started successfully!

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl logs fail-5-oomkilled-pod
```

Scenario 5 is still OOMKilled with a 256Mi limit. Reading the code again: `range(100)` x 10MB is **1000MB**, not the 200MB the comment claims. I fixed the loop to 20 x 10MB = 200MB:

```bash
…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl describe pod fail-5-oomkilled-pod | sed -n '/State:/,/Restart Count/p'
    State:          Terminated
      Reason:       OOMKilled
      Exit Code:    137
      Started:      Mon, 26 Oct 2026 15:30:16 +0530
      Finished:     Mon, 26 Oct 2026 15:30:16 +0530
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
      Started:      Mon, 26 Oct 2026 15:30:05 +0530
      Finished:     Mon, 26 Oct 2026 15:30:05 +0530
    Ready:          False
    Restart Count:  2

…/session-14-kubernetes-troubleshooting/scenarios ❯ grep -n -B1 -A1 'range' scenario-5-oomkilled/fixed.yaml
19-          chunks = []
20:          for i in range(100):
21-              chunks.append(b"x" * (10 * 1024 * 1024))

…/session-14-kubernetes-troubleshooting/scenarios ❯ diff scenario-5-*/broken.yaml scenario-5-*/fixed.yaml
8a9
>   restartPolicy: OnFailure   # one-shot script
19c20
<           for i in range(100):
---
>           for i in range(20):   # FIX: 20 x 10MB = 200MB (was 100 x 10MB = 1000MB)
20a22
>           print("Allocated", len(chunks) * 10, "MB OK")
23c25
<           memory: "20Mi"
---
>           memory: "256Mi"   # FIX: limit above the ~100MB the app needs

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl replace --force -f scenario-5-oomkilled/fixed.yaml
pod "fail-5-oomkilled-pod" deleted from default namespace
pod/fail-5-oomkilled-pod replaced

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl get pod fail-5-oomkilled-pod
NAME                   READY   STATUS      RESTARTS   AGE
fail-5-oomkilled-pod   0/1     Completed   0          15s

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl logs fail-5-oomkilled-pod
Allocating memory rapidly...
Allocated 200 MB OK

…/session-14-kubernetes-troubleshooting/scenarios ❯ diff scenario-5-*/broken.yaml scenario-5-*/fixed.yaml
8a9
>   restartPolicy: OnFailure   # one-shot script
19c20
<           for i in range(100):
---
>           for i in range(20):   # FIX: 20 x 10MB = 200MB (was 100 x 10MB = 1000MB)
20a22
>           print("Allocated", len(chunks) * 10, "MB OK")
23c25
<           memory: "20Mi"
---
>           memory: "256Mi"   # FIX: limit above the 200MB the app needs
```

### Fix 4 - DNS

The client needs a real `postgres-db` Service in namespace `production`, plus the correct hostname:

```bash
…/session-14-kubernetes-troubleshooting/scenarios ❯ diff scenario-4-*/broken.yaml scenario-4-*/fixed.yaml
16,17c16,18
<           # BUG: Incorrect internal hostname
<           curl -s --connect-timeout 3 http://postgres-db-wrong-name.production.svc.cluster.local:5432 || true
---
>           # FIX: correct Service name (postgres-db in namespace production)
>           nslookup postgres-db.production.svc.cluster.local;
>           curl -s --connect-timeout 3 http://postgres-db.production.svc.cluster.local:5432 || true

…/session-14-kubernetes-troubleshooting/scenarios ❯ cat scenario-4-dns-failure/postgres-db.yaml
# The database the client expects: Service "postgres-db" in namespace "production"
apiVersion: v1
kind: Namespace
metadata:
  name: production
---
apiVersion: v1
kind: Pod
metadata:
  name: postgres-db
  namespace: production
  labels:
    app: postgres-db
spec:
  containers:
    - name: postgres
      image: postgres:16-alpine
      env:
        - name: POSTGRES_PASSWORD
          value: secret
      ports:
        - containerPort: 5432
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-db
  namespace: production
spec:
  selector:
    app: postgres-db
  ports:
    - port: 5432
      targetPort: 5432

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl apply -f scenario-4-dns-failure/postgres-db.yaml
namespace/production created
pod/postgres-db created
service/postgres-db created

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl get pods,svc -n production
NAME              READY   STATUS    RESTARTS   AGE
pod/postgres-db   1/1     Running   0          23s

NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/postgres-db   ClusterIP   10.96.49.174   <none>        5432/TCP   23s

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl replace --force -f scenario-4-dns-failure/fixed.yaml
pod "fail-4-dns-failure-pod" deleted from default namespace
pod/fail-4-dns-failure-pod replaced

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl logs fail-4-dns-failure-pod
Attempting connection to internal database...
Server:		10.96.0.10
Address:	10.96.0.10:53


Name:	postgres-db.production.svc.cluster.local
Address: 10.96.49.174

Process sleeping...

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl get pods -l tier=triage-gauntlet
NAME                     READY   STATUS      RESTARTS   AGE
fail-1-crashloop-pod     0/1     Completed   0          2m3s
fail-2-imagepull-pod     1/1     Running     0          2m3s
fail-3-pending-pod       1/1     Running     0          2m3s
fail-4-dns-failure-pod   1/1     Running     0          12s
fail-5-oomkilled-pod     0/1     Completed   0          92s

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl delete pods -l tier=triage-gauntlet
pod "fail-1-crashloop-pod" deleted from default namespace
pod "fail-2-imagepull-pod" deleted from default namespace
pod "fail-3-pending-pod" deleted from default namespace
pod "fail-4-dns-failure-pod" deleted from default namespace
pod "fail-5-oomkilled-pod" deleted from default namespace

…/session-14-kubernetes-troubleshooting/scenarios ❯ kubectl delete namespace production
namespace "production" deleted
```

All 5 fixed: 1 and 5 are one-shot scripts, so with `restartPolicy: OnFailure` they end `Completed`. 2, 3 and 4 are `Running`.
