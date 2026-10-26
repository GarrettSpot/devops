# 13

Lab run on a local **kind** cluster (`s-b`: 1 control-plane + 2 workers, Kubernetes v1.37) instead of Minikube. kind ships a default `standard` StorageClass backed by `rancher.io/local-path`, and metrics-server was installed separately (no minikube addon).

## Cluster used

```bash
… ❯ kubectl get nodes
NAME                STATUS     ROLES           AGE   VERSION
s-b-control-plane   NotReady   control-plane   16s   v1.37.0
s-b-worker          NotReady   <none>          0s    v1.37.0
s-b-worker2         NotReady   <none>          0s    v1.37.0

… ❯ kubectl get nodes
NAME                STATUS   ROLES           AGE   VERSION
s-b-control-plane   Ready    control-plane   55s   v1.37.0
s-b-worker          Ready    <none>          39s   v1.37.0
s-b-worker2         Ready    <none>          39s   v1.37.0
```

## 01 - Volumes (emptyDir and hostPath)

`emptyDir` lives as long as the Pod. Write a file, delete the Pod, recreate it, and the file is gone.

```bash
…/session-13-storage-hpa-probes/01-volumes ❯ kubectl apply -f emptydir-pod.yaml
pod/emptydir-demo created

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl get pods
NAME            READY   STATUS    RESTARTS   AGE
emptydir-demo   1/1     Running   0          78s

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl exec emptydir-demo -- bash -c 'echo "Hello Kubernetes" > /data/message.txt'

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl exec emptydir-demo -- cat /data/message.txt
Hello Kubernetes

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl exec emptydir-demo -- df -h /data
Filesystem                Size  Used Avail Use% Mounted on
/dev/mapper/omarchy_root  104G   38G   66G  37% /data

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl delete pod emptydir-demo
pod "emptydir-demo" deleted from default namespace

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl apply -f emptydir-pod.yaml
pod/emptydir-demo created

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl exec emptydir-demo -- cat /data/message.txt
cat: /data/message.txt: No such file or directory
command terminated with exit code 1

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl describe pod emptydir-demo | sed -n '/Mounts:/,/Conditions:/p;/^Volumes:/,/QoS/p'
    Mounts:
      /data from app-storage (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-hn6tq (ro)
Conditions:
Volumes:
  app-storage:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  kube-api-access-hn6tq:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
```

`hostPath` mounts a directory from the node itself. The file is visible on the kind node container, and it survives Pod deletion as long as the new Pod lands on the **same node** (here both runs landed on `s-b-worker2`).

```bash
…/session-13-storage-hpa-probes/01-volumes ❯ kubectl apply -f hostpath-pod.yaml
pod/hostpath-demo created

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl get pods -o wide
NAME            READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
emptydir-demo   1/1     Running   0          1s    10.244.2.3   s-b-worker2   <none>           <none>
hostpath-demo   1/1     Running   0          0s    10.244.2.4   s-b-worker2   <none>           <none>

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl exec hostpath-demo -- sh -c 'echo "from hostPath pod" > /data/host.txt'

…/session-13-storage-hpa-probes/01-volumes ❯ docker exec s-b-worker2 cat /tmp/hostpath-data/host.txt
from hostPath pod

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl delete pod hostpath-demo
pod "hostpath-demo" deleted from default namespace

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl apply -f hostpath-pod.yaml
pod/hostpath-demo created

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl get pod hostpath-demo -o wide
NAME            READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
hostpath-demo   1/1     Running   0          1s    10.244.2.5   s-b-worker2   <none>           <none>

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl exec hostpath-demo -- cat /data/host.txt
from hostPath pod

…/session-13-storage-hpa-probes/01-volumes ❯ kubectl delete pod emptydir-demo hostpath-demo
pod "emptydir-demo" deleted from default namespace
pod "hostpath-demo" deleted from default namespace
```

## 02 - Persistent Storage (PV + PVC)

```bash
…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl apply -f pv.yaml
persistentvolume/student-pv created

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl get pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
student-pv   1Gi        RWO            Retain           Available                          <unset>                          0s

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl apply -f pvc.yaml
persistentvolumeclaim/student-pvc created

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl get pvc
NAME          STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
student-pvc   Pending                                      standard       <unset>                 8s

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl get pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
student-pv   1Gi        RWO            Retain           Available                          <unset>                          8s

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl describe pvc student-pvc | tail -8
Capacity:      
Access Modes:  
VolumeMode:    Filesystem
Used By:       <none>
Events:
  Type    Reason                Age              From                         Message
  ----    ------                ----             ----                         -------
  Normal  WaitForFirstConsumer  7s (x2 over 9s)  persistentvolume-controller  waiting for first consumer to be created before binding
```

**Problem:** the PVC stays `Pending` and never binds to `student-pv`. The diagnosis: the PVC has no `storageClassName`, so the cluster's default class (`standard`) gets filled in automatically. `student-pv` has *no* class, so the two don't match. The PVC would wait for a dynamically provisioned volume instead.

**Fix:** set `storageClassName: ""` on the PVC so it only binds to class-less static PVs.

```bash
…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl get storageclass
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  2m49s

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl get pvc student-pvc -o jsonpath='{.spec.storageClassName}{"\n"}'
standard

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl delete pvc student-pvc
persistentvolumeclaim "student-pvc" deleted from default namespace

…/session-13-storage-hpa-probes/02-persistent-storage ❯ cat pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: student-pvc
spec:
  storageClassName: ""   # bind to the static PV, not the default "standard" class
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl apply -f pvc.yaml
persistentvolumeclaim/student-pvc created

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl get pvc
NAME          STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
student-pvc   Bound    student-pv   1Gi        RWO                           <unset>                 4s

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl get pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
student-pv   1Gi        RWO            Retain           Bound    default/student-pvc                  <unset>                          20s
```

Now the Pod writes to the PVC, gets deleted and recreated, and the data is still there:

```bash
…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl apply -f pod.yaml
pod/storage-demo created

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl get pods -o wide
NAME           READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
storage-demo   1/1     Running   0          1s    10.244.2.6   s-b-worker2   <none>           <none>

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl exec storage-demo -- bash -c 'echo "Kubernetes Storage" > /data/message.txt'

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl exec storage-demo -- cat /data/message.txt
Kubernetes Storage

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl delete pod storage-demo
pod "storage-demo" deleted from default namespace

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl apply -f pod.yaml
pod/storage-demo created

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl get pods -o wide
NAME           READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
storage-demo   1/1     Running   0          1s    10.244.2.7   s-b-worker2   <none>           <none>

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl exec storage-demo -- cat /data/message.txt
Kubernetes Storage
```

> Note: `student-pv` is a `hostPath` PV with `Node Affinity: <none>`. On a multi-node cluster the data only "persists" if the Pod is rescheduled onto the same node. Real clusters use a provisioner (next section) that pins the volume to a node or uses network storage.

```bash
…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl describe pv student-pv
Name:            student-pv
Labels:          <none>
Annotations:     pv.kubernetes.io/bound-by-controller: yes
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    
Status:          Bound
Claim:           default/student-pvc
Reclaim Policy:  Retain
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        1Gi
Node Affinity:   <none>
Message:         
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /tmp/student-data
    HostPathType:  
Events:            <none>

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl describe pvc student-pvc
Name:          student-pvc
Namespace:     default
StorageClass:  
Status:        Bound
Volume:        student-pv
Labels:        <none>
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      1Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Used By:       storage-demo
Conditions:
  Type     Status  LastProbeTime                     LastTransitionTime                Reason        Message
  ----     ------  -----------------                 ------------------                ------        -------
  Unused   False   Mon, 01 Jan 0001 00:00:00 +0000   Mon, 26 Oct 2026 14:36:15 +0530   PodUsingPVC   A pod is currently referencing this PVC
Events:    <none>

…/session-13-storage-hpa-probes/02-persistent-storage ❯ kubectl delete -f pod.yaml -f pvc.yaml -f pv.yaml
pod "storage-demo" deleted from default namespace
persistentvolumeclaim "student-pvc" deleted from default namespace
persistentvolume "student-pv" deleted
```

## 03 - StorageClass (dynamic provisioning)

```bash
…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl get storageclass
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  3m10s

…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl describe storageclass standard
Name:            standard
IsDefaultClass:  Yes
Annotations:     kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"},"name":"standard"},"provisioner":"rancher.io/local-path","reclaimPolicy":"Delete","volumeBindingMode":"WaitForFirstConsumer"}
,storageclass.kubernetes.io/is-default-class=true
Provisioner:           rancher.io/local-path
Parameters:            <none>
AllowVolumeExpansion:  <unset>
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
Events:                <none>

…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl apply -f pvc.yaml
persistentvolumeclaim/dynamic-pvc created

…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl get pvc
NAME          STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
dynamic-pvc   Pending                                      standard       <unset>                 0s

…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl get pv
No resources found

…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl describe pvc dynamic-pvc
Name:          dynamic-pvc
Namespace:     default
StorageClass:  standard
Status:        Pending
Volume:        
Labels:        <none>
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      
Access Modes:  
VolumeMode:    Filesystem
Used By:       <none>
Events:
  Type    Reason                Age   From                         Message
  ----    ------                ----  ----                         -------
  Normal  WaitForFirstConsumer  0s    persistentvolume-controller  waiting for first consumer to be created before binding
```

The PVC stays `Pending` because kind's `standard` class uses `VolumeBindingMode: WaitForFirstConsumer`. The volume is only created once a Pod uses the claim, so I added a small consumer Pod:

```bash
…/session-13-storage-hpa-probes/03-storageclass ❯ cat consumer-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: dynamic-consumer
spec:
  containers:
    - name: app
      image: nginx:1.27
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: dynamic-pvc

…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl apply -f consumer-pod.yaml
pod/dynamic-consumer created

…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl get pvc
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
dynamic-pvc   Bound    pvc-e617cb1d-b3f4-4293-9fe2-f3c8e521a0a9   500Mi      RWO            standard       <unset>                 5s

…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-e617cb1d-b3f4-4293-9fe2-f3c8e521a0a9   500Mi      RWO            Delete           Bound    default/dynamic-pvc   standard       <unset>                          1s

…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl describe pvc dynamic-pvc | tail -8
  Unused   False   Mon, 01 Jan 0001 00:00:00 +0000   Mon, 26 Oct 2026 14:36:28 +0530   PodUsingPVC   A pod is currently referencing this PVC
Events:
  Type    Reason                 Age   From                                                                                                Message
  ----    ------                 ----  ----                                                                                                -------
  Normal  WaitForFirstConsumer   5s    persistentvolume-controller                                                                         waiting for first consumer to be created before binding
  Normal  ExternalProvisioning   4s    persistentvolume-controller                                                                         Waiting for a volume to be created either by the external provisioner 'rancher.io/local-path' or manually by the system administrator. If volume creation is delayed, please verify that the provisioner is running and correctly registered.
  Normal  Provisioning           4s    rancher.io/local-path_local-path-provisioner-75f7fc7dc5-mc5ss_d11e729a-fdb3-4f55-bce4-442d3cf3de9e  External provisioner is provisioning volume for claim "default/dynamic-pvc"
  Normal  ProvisioningSucceeded  1s    rancher.io/local-path_local-path-provisioner-75f7fc7dc5-mc5ss_d11e729a-fdb3-4f55-bce4-442d3cf3de9e  Successfully provisioned volume pvc-e617cb1d-b3f4-4293-9fe2-f3c8e521a0a9
```

Reclaim policy is `Delete`, so removing the PVC removes the dynamically created PV too:

```bash
…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl delete -f consumer-pod.yaml -f pvc.yaml
pod "dynamic-consumer" deleted from default namespace
persistentvolumeclaim "dynamic-pvc" deleted from default namespace

…/session-13-storage-hpa-probes/03-storageclass ❯ kubectl get pv
No resources found
```

## 04 - HPA (Horizontal Pod Autoscaler)

### Metrics Server

Before installing metrics-server:

```bash
… ❯ kubectl top nodes
error: Metrics API not available
```

On kind there is no `minikube addons enable metrics-server`, so I applied the upstream `components.yaml` and patched it with `--kubelet-insecure-tls`, because kind's kubelets use self-signed certs:

```bash
… ❯ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
(output trimmed)

… ❯ kubectl -n kube-system patch deployment metrics-server --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
deployment.apps/metrics-server patched
```

### Deployment + Service + HPA

```bash
…/session-13-storage-hpa-probes/04-hpa ❯ kubectl apply -f deployment.yaml
deployment.apps/hpa-demo created

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl get deployment
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
hpa-demo   1/1     1            1           1s

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
hpa-demo-5d6676989b-z9pr4   1/1     Running   0          1s

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl apply -f service.yaml
service/hpa-demo-service created

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl get svc
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
hpa-demo-service   ClusterIP   10.96.126.237   <none>        80/TCP    0s
kubernetes         ClusterIP   10.96.0.1       <none>        443/TCP   3m31s

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl top nodes
NAME                CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
s-b-control-plane   132m         1%       665Mi           4%          
s-b-worker          45m          0%       187Mi           1%          
s-b-worker2         88m          1%       171Mi           1%          

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl top pods
error: metrics not available yet

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl get pods -n kube-system | grep -E 'NAME|metrics-server'
NAME                                        READY   STATUS    RESTARTS   AGE
metrics-server-84c99cb944-ggt4s             1/1     Running   0          3m9s

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl top pods
NAME                        CPU(cores)   MEMORY(bytes)   
hpa-demo-5d6676989b-z9pr4   4m           7Mi             

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl -n kube-system get deploy metrics-server -o jsonpath='{.spec.template.spec.containers[0].args}' | tr ',' '\n'
["--cert-dir=/tmp"
"--secure-port=10250"
"--kubelet-preferred-address-types=InternalIP
ExternalIP
Hostname"
"--kubelet-use-node-status-port"
"--metric-resolution=15s"
"--kubelet-insecure-tls"]

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl apply -f hpa.yaml
horizontalpodautoscaler.autoscaling/hpa-demo created

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl get hpa
NAME       REFERENCE             TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo   Deployment/hpa-demo   cpu: 0%/50%   1         5         1          20s
```

### Generate load and watch it scale up

```bash
…/session-13-storage-hpa-probes/04-hpa ❯ kubectl run load-generator --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://hpa-demo-service; done"
pod/load-generator created

…/session-13-storage-hpa-probes/04-hpa ❯ timeout 150 kubectl get hpa -w
NAME       REFERENCE             TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo   Deployment/hpa-demo   cpu: 0%/50%   1         5         1          25s
hpa-demo   Deployment/hpa-demo   cpu: 40%/50%   1         5         1          45s
hpa-demo   Deployment/hpa-demo   cpu: 69%/50%   1         5         1          60s
hpa-demo   Deployment/hpa-demo   cpu: 47%/50%   1         5         2          75s
hpa-demo   Deployment/hpa-demo   cpu: 38%/50%   1         5         2          90s
hpa-demo   Deployment/hpa-demo   cpu: 38%/50%   1         5         2          105s
hpa-demo   Deployment/hpa-demo   cpu: 34%/50%   1         5         2          2m
hpa-demo   Deployment/hpa-demo   cpu: 36%/50%   1         5         2          2m15s
hpa-demo   Deployment/hpa-demo   cpu: 20%/50%   1         5         2          2m30s

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
hpa-demo-5d6676989b-b7j4b   1/1     Running   0          115s
hpa-demo-5d6676989b-z9pr4   1/1     Running   0          3m24s
load-generator              1/1     Running   0          2m35s

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl top pods
NAME                        CPU(cores)   MEMORY(bytes)   
hpa-demo-5d6676989b-b7j4b   35m          10Mi            
hpa-demo-5d6676989b-z9pr4   32m          8Mi             
load-generator              735m         8Mi             
```

A single busybox `wget` loop only pushed the HPA to 2 replicas. I added 3 more load generators to push it further:

```bash
…/session-13-storage-hpa-probes/04-hpa ❯ for i in 2 3 4; do kubectl run load-generator-$i --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://hpa-demo-service; done"; done
pod/load-generator-2 created
pod/load-generator-3 created
pod/load-generator-4 created

…/session-13-storage-hpa-probes/04-hpa ❯ timeout 120 kubectl get hpa -w
NAME       REFERENCE             TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo   Deployment/hpa-demo   cpu: 33%/50%   1         5         2          3m2s
hpa-demo   Deployment/hpa-demo   cpu: 46%/50%   1         5         2          3m30s
hpa-demo   Deployment/hpa-demo   cpu: 99%/50%   1         5         2          3m45s
hpa-demo   Deployment/hpa-demo   cpu: 96%/50%   1         5         4          4m
hpa-demo   Deployment/hpa-demo   cpu: 59%/50%   1         5         4          4m15s
hpa-demo   Deployment/hpa-demo   cpu: 44%/50%   1         5         4          4m31s
hpa-demo   Deployment/hpa-demo   cpu: 53%/50%   1         5         4          4m46s

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl get pods -o wide
NAME                        READY   STATUS    RESTARTS   AGE     IP            NODE          NOMINATED NODE   READINESS GATES
hpa-demo-5d6676989b-b7j4b   1/1     Running   0          4m2s    10.244.1.4    s-b-worker    <none>           <none>
hpa-demo-5d6676989b-r48bs   1/1     Running   0          77s     10.244.1.6    s-b-worker    <none>           <none>
hpa-demo-5d6676989b-rwrmd   1/1     Running   0          77s     10.244.2.15   s-b-worker2   <none>           <none>
hpa-demo-5d6676989b-z9pr4   1/1     Running   0          5m31s   10.244.2.11   s-b-worker2   <none>           <none>
load-generator              1/1     Running   0          4m42s   10.244.2.12   s-b-worker2   <none>           <none>
load-generator-2            1/1     Running   0          2m      10.244.2.13   s-b-worker2   <none>           <none>
load-generator-3            1/1     Running   0          2m      10.244.1.5    s-b-worker    <none>           <none>
load-generator-4            1/1     Running   0          2m      10.244.2.14   s-b-worker2   <none>           <none>

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl top pods
NAME                        CPU(cores)   MEMORY(bytes)   
hpa-demo-5d6676989b-b7j4b   52m          9Mi             
hpa-demo-5d6676989b-r48bs   55m          8Mi             
hpa-demo-5d6676989b-rwrmd   55m          9Mi             
hpa-demo-5d6676989b-z9pr4   51m          8Mi             
load-generator              692m         6Mi             
load-generator-2            625m         7Mi             
load-generator-3            623m         6Mi             
load-generator-4            606m         6Mi             

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl describe hpa hpa-demo
Name:                                                  hpa-demo
Namespace:                                             default
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Mon, 26 Oct 2026 14:37:10 +0530
Reference:                                             Deployment/hpa-demo
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  53% (53m) / 50%
Min replicas:                                          1
Max replicas:                                          5
Deployment pods:                                       4 current / 4 desired
Conditions:
  Type            Status  Reason              Message
  ----            ------  ------              -------
  AbleToScale     True    ReadyForNewScale    recommended size matches current size
  ScalingActive   True    ValidMetricFound    the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range
  ScaledToZero    False   NotScaledToZero     the HPA controller did not scale the workload to zero
Events:
  Type     Reason                        Age   From                       Message
  ----     ------                        ----  ----                       -------
  Warning  FailedGetResourceMetric       5m2s  horizontal-pod-autoscaler  failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
  Warning  FailedComputeMetricsReplicas  5m2s  horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
  Normal   SuccessfulRescale             4m2s  horizontal-pod-autoscaler  New size: 2; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             77s   horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
```

### Stop the load and watch it scale down

```bash
…/session-13-storage-hpa-probes/04-hpa ❯ kubectl delete pod load-generator load-generator-2 load-generator-3 load-generator-4
pod "load-generator" deleted from default namespace
pod "load-generator-2" deleted from default namespace
pod "load-generator-3" deleted from default namespace
pod "load-generator-4" deleted from default namespace
```

Scale-down has a 5-minute stabilization window (`behavior.scaleDown.stabilizationWindowSeconds: 300` by default), so replicas stay at 5 for a while after CPU drops to 0%. During this run the host was heavily loaded by other workloads. `kube-controller-manager` and `kube-scheduler` restarted a few times, which reset the window. The scale-down still happened in the end (`5 -> 4 -> 1`):

```bash
…/session-13-storage-hpa-probes/04-hpa ❯ kubectl get hpa hpa-demo
NAME       REFERENCE             TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo   Deployment/hpa-demo   cpu: 0%/50%   1         5         1          33m

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl get pods -l app=hpa-demo
NAME                        READY   STATUS    RESTARTS   AGE
hpa-demo-5d6676989b-b7j4b   1/1     Running   0          32m

…/session-13-storage-hpa-probes/04-hpa ❯ kubectl describe hpa hpa-demo | grep -E 'SuccessfulRescale'
  Normal   SuccessfulRescale             32m    horizontal-pod-autoscaler  New size: 2; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             29m    horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             27m    horizontal-pod-autoscaler  New size: 5; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             9m34s  horizontal-pod-autoscaler  New size: 4; reason: All metrics below target
  Normal   SuccessfulRescale             8m4s   horizontal-pod-autoscaler  New size: 1; reason: All metrics below target
```
```bash
…/session-13-storage-hpa-probes/04-hpa ❯ kubectl delete -f hpa.yaml -f service.yaml -f deployment.yaml
horizontalpodautoscaler.autoscaling "hpa-demo" deleted from default namespace
service "hpa-demo-service" deleted from default namespace
deployment.apps "hpa-demo" deleted from default namespace
```

### demo-chart (helm create skeleton) - HPA template

The `04-hpa/demo-chart` folder is the stock `helm create` chart. Its HPA is off by default. Enabling it renders an `autoscaling/v2` HPA:

```bash
…/session-13-storage-hpa-probes/04-hpa ❯ helm lint demo-chart
==> Linting demo-chart
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed

…/session-13-storage-hpa-probes/04-hpa ❯ helm template demo demo-chart --set autoscaling.enabled=true --set resources.requests.cpu=100m -s templates/hpa.yaml
---
# Source: demo-chart/templates/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: demo-demo-chart
  labels:
    helm.sh/chart: demo-chart-0.1.0
    app.kubernetes.io/name: demo-chart
    app.kubernetes.io/instance: demo
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: demo-demo-chart
  minReplicas: 1
  maxReplicas: 100
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80
```

## hpa/ - yatri-backend HPA + load_generator.sh

The folder has only a Service and an HPA. The `yatri-backend` Deployment they point at is **not** included, so applying them as-is gives a broken HPA:

```bash
…/session-13-storage-hpa-probes/hpa ❯ ls
backend-service.yaml
hpa-backend.yaml
load_generator.sh

…/session-13-storage-hpa-probes/hpa ❯ kubectl apply -f backend-service.yaml -f hpa-backend.yaml
service/yatri-backend-service created
horizontalpodautoscaler.autoscaling/yatri-backend-hpa created

…/session-13-storage-hpa-probes/hpa ❯ kubectl get hpa yatri-backend-hpa
NAME                REFERENCE                  TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
yatri-backend-hpa   Deployment/yatri-backend   cpu: <unknown>/50%   2         10        0          30s

…/session-13-storage-hpa-probes/hpa ❯ kubectl describe hpa yatri-backend-hpa | sed -n '/^Conditions:/,$p'
Conditions:
  Type         Status  Reason          Message
  ----         ------  ------          -------
  AbleToScale  False   FailedGetScale  the HPA controller was unable to get the target's current scale: deployments.apps "yatri-backend" not found
Events:
  Type     Reason          Age               From                       Message
  ----     ------          ----              ----                       -------
  Warning  FailedGetScale  0s (x3 over 30s)  horizontal-pod-autoscaler  deployments.apps "yatri-backend" not found

…/session-13-storage-hpa-probes/hpa ❯ kubectl get endpoints yatri-backend-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                    ENDPOINTS   AGE
yatri-backend-service   <none>      30s

…/session-13-storage-hpa-probes/hpa ❯ kubectl get deploy yatri-backend
Error from server (NotFound): deployments.apps "yatri-backend" not found
```

**Fix:** I created a stand-in `yatri-backend` Deployment listening on port 5000. It uses `hashicorp/http-echo` with a small `20m` CPU request so the load generator can actually push it over 50%:

```bash
…/session-13-storage-hpa-probes/hpa ❯ cat backend-deployment.yaml
# Stand-in for the missing yatri-backend Deployment (not included in the lab folder)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: yatri-backend
  labels:
    app: yatri-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: yatri-backend
  template:
    metadata:
      labels:
        app: yatri-backend
    spec:
      containers:
        - name: backend
          image: hashicorp/http-echo:1.0
          args: ["-listen=:5000", "-text=ok"]
          ports:
            - containerPort: 5000
          resources:
            requests:
              cpu: 20m
            limits:
              cpu: 100m

…/session-13-storage-hpa-probes/hpa ❯ kubectl apply -f backend-deployment.yaml
deployment.apps/yatri-backend created

…/session-13-storage-hpa-probes/hpa ❯ kubectl get pods -l app=yatri-backend
NAME                            READY   STATUS    RESTARTS   AGE
yatri-backend-bb4585d5f-2ntl6   1/1     Running   0          7s
yatri-backend-bb4585d5f-jrgcg   1/1     Running   0          7s

…/session-13-storage-hpa-probes/hpa ❯ kubectl get endpoints yatri-backend-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                    ENDPOINTS                          AGE
yatri-backend-service   10.244.1.9:5000,10.244.2.22:5000   49s

…/session-13-storage-hpa-probes/hpa ❯ kubectl get hpa yatri-backend-hpa
NAME                REFERENCE                  TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
yatri-backend-hpa   Deployment/yatri-backend   cpu: 7%/50%   2         10        2          90s
```

`load_generator.sh` hard-codes a port-forward on `5000`. I port-forwarded the service to `18250` myself (`kubectl port-forward svc/yatri-backend-service 18250:80 &`) and passed the URL as the script's argument. The script's `curl -f` check then succeeds and it skips its own port-forward:

```bash
…/session-13-storage-hpa-probes/hpa ❯ curl -s http://localhost:18250/healthz
ok

…/session-13-storage-hpa-probes/hpa ❯ timeout 150 bash load_generator.sh http://localhost:18250/healthz & sleep 2; timeout 145 kubectl get hpa yatri-backend-hpa -w; wait
==================================================
      KUBERNETES HPA TRAFFIC LOAD GENERATOR       
==================================================
Pounding target endpoint: http://localhost:18250/healthz
Simulating traffic spike. Press Ctrl+C to stop.

Traffic load active! In another terminal, run: kubectl get hpa -w
NAME                REFERENCE                  TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
yatri-backend-hpa   Deployment/yatri-backend   cpu: 7%/50%   2         10        2          113s
yatri-backend-hpa   Deployment/yatri-backend   cpu: 65%/50%   2         10        2          3m27s
yatri-backend-hpa   Deployment/yatri-backend   cpu: 62%/50%   2         10        3          3m42s
yatri-backend-hpa   Deployment/yatri-backend   cpu: 240%/50%   2         10        3          3m57s
yatri-backend-hpa   Deployment/yatri-backend   cpu: 242%/50%   2         10        6          4m12s

…/session-13-storage-hpa-probes/hpa ❯ kubectl get pods -l app=yatri-backend
NAME                            READY   STATUS    RESTARTS   AGE
yatri-backend-bb4585d5f-2ntl6   1/1     Running   0          3m39s
yatri-backend-bb4585d5f-4bxgn   0/1     Pending   0          9s
yatri-backend-bb4585d5f-4wnq4   0/1     Pending   0          54s
yatri-backend-bb4585d5f-ft79z   0/1     Pending   0          9s
yatri-backend-bb4585d5f-jrgcg   1/1     Running   0          3m39s
yatri-backend-bb4585d5f-jzmnl   0/1     Pending   0          24s
yatri-backend-bb4585d5f-kdxbd   0/1     Pending   0          9s
yatri-backend-bb4585d5f-mgk4x   0/1     Pending   0          9s
yatri-backend-bb4585d5f-wvn56   0/1     Pending   0          24s
yatri-backend-bb4585d5f-zst7k   0/1     Pending   0          24s

…/session-13-storage-hpa-probes/hpa ❯ kubectl top pods -l app=yatri-backend
NAME                            CPU(cores)   MEMORY(bytes)   
yatri-backend-bb4585d5f-2ntl6   96m          32Mi            
yatri-backend-bb4585d5f-jrgcg   1m           10Mi            

…/session-13-storage-hpa-probes/hpa ❯ kubectl get pods -l app=yatri-backend
NAME                            READY   STATUS    RESTARTS   AGE
yatri-backend-bb4585d5f-2ntl6   1/1     Running   0          4m2s
yatri-backend-bb4585d5f-4bxgn   0/1     Pending   0          32s
yatri-backend-bb4585d5f-4wnq4   0/1     Pending   0          77s
yatri-backend-bb4585d5f-ft79z   0/1     Pending   0          32s
yatri-backend-bb4585d5f-jrgcg   1/1     Running   0          4m2s
yatri-backend-bb4585d5f-jzmnl   0/1     Pending   0          47s
yatri-backend-bb4585d5f-kdxbd   0/1     Pending   0          32s
yatri-backend-bb4585d5f-mgk4x   0/1     Pending   0          32s
yatri-backend-bb4585d5f-wvn56   0/1     Pending   0          47s
yatri-backend-bb4585d5f-zst7k   0/1     Pending   0          47s

…/session-13-storage-hpa-probes/hpa ❯ kubectl describe pod/yatri-backend-bb4585d5f-4bxgn | sed -n '/^Events:/,$p'
Events:                      <none>

…/session-13-storage-hpa-probes/hpa ❯ kubectl get hpa
NAME                REFERENCE                  TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo            Deployment/hpa-demo        cpu: <unknown>/50%   1         5         5          19m
yatri-backend-hpa   Deployment/yatri-backend   cpu: <unknown>/50%   2         10        10         4m44s
```

Two things to notice:

* `kubectl port-forward svc/...` actually tunnels to **one** Pod, so all the load landed on `yatri-backend-...-2ntl6` (96m) while the other Pod sat at 1m. The HPA averages across Pods, so it still scaled.
* The new Pods sat in `Pending` with **no events at all**. A Pending Pod with no `FailedScheduling` event means the scheduler isn't running. The host load average had spiked to ~68, and `kube-scheduler` was in `CrashLoopBackOff` after losing its leader election lease:

```bash
…/session-13-storage-hpa-probes/hpa ❯ kubectl get pods -n kube-system | grep -E 'NAME|scheduler|controller-manager'
NAME                                        READY   STATUS             RESTARTS        AGE
kube-controller-manager-s-b-control-plane   1/1     Running            5 (3m29s ago)   23m
kube-scheduler-s-b-control-plane            0/1     CrashLoopBackOff   5 (93s ago)     23m

…/session-13-storage-hpa-probes/hpa ❯ kubectl -n kube-system logs kube-scheduler-s-b-control-plane --previous --tail=3 | cut -c1-200
I1026 09:25:34.431559       1 server.go:281] "[graceful-termination] secure server has stopped listening"
I1026 09:25:34.431579       1 server.go:283] "[graceful-termination] secure server is exiting"
E1026 09:25:34.431664       1 server.go:337] "Leaderelection lost"
```

Once the load generator stopped and the host calmed down, the scheduler came back and all 10 Pods were scheduled. 5 minutes later the HPA scaled back to `minReplicas: 2`:

```bash
…/session-13-storage-hpa-probes/hpa ❯ kubectl get pods -n kube-system | grep -E 'NAME|scheduler|controller-manager'
NAME                                        READY   STATUS    RESTARTS        AGE
kube-controller-manager-s-b-control-plane   1/1     Running   5 (6m39s ago)   27m
kube-scheduler-s-b-control-plane            1/1     Running   6 (4m43s ago)   27m

…/session-13-storage-hpa-probes/hpa ❯ kubectl get pods -l app=yatri-backend -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP            NODE          NOMINATED NODE   READINESS GATES
yatri-backend-bb4585d5f-2ntl6   1/1     Running   0          7m26s   10.244.2.22   s-b-worker2   <none>           <none>
yatri-backend-bb4585d5f-4bxgn   1/1     Running   0          3m56s   10.244.1.12   s-b-worker    <none>           <none>
yatri-backend-bb4585d5f-4wnq4   1/1     Running   0          4m41s   10.244.2.23   s-b-worker2   <none>           <none>
yatri-backend-bb4585d5f-ft79z   1/1     Running   0          3m56s   10.244.2.25   s-b-worker2   <none>           <none>
yatri-backend-bb4585d5f-jrgcg   1/1     Running   0          7m26s   10.244.1.9    s-b-worker    <none>           <none>
yatri-backend-bb4585d5f-jzmnl   1/1     Running   0          4m11s   10.244.1.11   s-b-worker    <none>           <none>
yatri-backend-bb4585d5f-kdxbd   1/1     Running   0          3m56s   10.244.1.13   s-b-worker    <none>           <none>
yatri-backend-bb4585d5f-mgk4x   1/1     Running   0          3m56s   10.244.1.10   s-b-worker    <none>           <none>
yatri-backend-bb4585d5f-wvn56   1/1     Running   0          4m11s   10.244.2.24   s-b-worker2   <none>           <none>
yatri-backend-bb4585d5f-zst7k   1/1     Running   0          4m11s   10.244.2.26   s-b-worker2   <none>           <none>

…/session-13-storage-hpa-probes/hpa ❯ kubectl get hpa yatri-backend-hpa
NAME                REFERENCE                  TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
yatri-backend-hpa   Deployment/yatri-backend   cpu: 2%/50%   2         10        10         8m8s

…/session-13-storage-hpa-probes/hpa ❯ kubectl describe hpa yatri-backend-hpa | sed -n '/^Events:/,$p'
Events:
  Type     Reason                        Age                   From                       Message
  ----     ------                        ----                  ----                       -------
  Warning  FailedGetScale                7m38s (x3 over 8m8s)  horizontal-pod-autoscaler  deployments.apps "yatri-backend" not found
  Warning  FailedGetResourceMetric       7m8s (x2 over 7m23s)  horizontal-pod-autoscaler  failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedComputeMetricsReplicas  7m8s (x2 over 7m23s)  horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Normal   SuccessfulRescale             4m41s                 horizontal-pod-autoscaler  New size: 3; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             4m11s                 horizontal-pod-autoscaler  New size: 6; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             3m56s                 horizontal-pod-autoscaler  New size: 10; reason: cpu resource utilization (percentage of request) above target
  Warning  FailedGetResourceMetric       3m32s                 horizontal-pod-autoscaler  failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedComputeMetricsReplicas  3m32s                 horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedGetResourceMetric       3m18s                 horizontal-pod-autoscaler  failed to get cpu utilization: unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API: the server is currently unable to handle the request (get pods.metrics.k8s.io)
  Warning  FailedComputeMetricsReplicas  3m18s                 horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API: the server is currently unable to handle the request (get pods.metrics.k8s.io)

…/session-13-storage-hpa-probes/hpa ❯ kubectl get hpa yatri-backend-hpa
NAME                REFERENCE                  TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
yatri-backend-hpa   Deployment/yatri-backend   cpu: 0%/50%   2         10        2          18m

…/session-13-storage-hpa-probes/hpa ❯ kubectl describe hpa yatri-backend-hpa | grep SuccessfulRescale
  Normal   SuccessfulRescale             14m                horizontal-pod-autoscaler  New size: 3; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             14m                horizontal-pod-autoscaler  New size: 6; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             14m                horizontal-pod-autoscaler  New size: 10; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             6m24s              horizontal-pod-autoscaler  New size: 2; reason: All metrics below target

…/session-13-storage-hpa-probes/hpa ❯ kubectl delete -f backend-deployment.yaml -f backend-service.yaml -f hpa-backend.yaml
deployment.apps "yatri-backend" deleted from default namespace
service "yatri-backend-service" deleted from default namespace
horizontalpodautoscaler.autoscaling "yatri-backend-hpa" deleted from default namespace
```

## 05 - Probes

### Liveness, Readiness, Startup (healthy)

```bash
…/session-13-storage-hpa-probes/05-probes ❯ kubectl apply -f liveness.yaml
pod/liveness-demo created

…/session-13-storage-hpa-probes/05-probes ❯ kubectl get pod liveness-demo
NAME            READY   STATUS    RESTARTS   AGE
liveness-demo   1/1     Running   0          12s

…/session-13-storage-hpa-probes/05-probes ❯ kubectl describe pod liveness-demo | grep -E 'Liveness|Readiness|Startup|State|Ready|Restart Count'
    State:          Running
    Ready:          True
    Restart Count:  0
    Liveness:       http-get http://:80/ delay=5s timeout=2s period=5s #success=1 #failure=3
  PodReadyToStartContainers   True 
  Ready                       True 
  ContainersReady             True 

…/session-13-storage-hpa-probes/05-probes ❯ kubectl apply -f readiness.yaml
pod/readiness-demo created

…/session-13-storage-hpa-probes/05-probes ❯ kubectl get pod readiness-demo
NAME             READY   STATUS              RESTARTS   AGE
readiness-demo   0/1     ContainerCreating   0          0s

…/session-13-storage-hpa-probes/05-probes ❯ kubectl get pod readiness-demo
NAME             READY   STATUS    RESTARTS   AGE
readiness-demo   1/1     Running   0          10s

…/session-13-storage-hpa-probes/05-probes ❯ kubectl expose pod readiness-demo --name=readiness-service --port=80
service/readiness-service exposed

…/session-13-storage-hpa-probes/05-probes ❯ kubectl get endpoints readiness-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                ENDPOINTS        AGE
readiness-service   10.244.2.17:80   2s

…/session-13-storage-hpa-probes/05-probes ❯ kubectl apply -f startup.yaml
pod/startup-demo created

…/session-13-storage-hpa-probes/05-probes ❯ kubectl get pod startup-demo
NAME           READY   STATUS    RESTARTS   AGE
startup-demo   1/1     Running   0          10s

…/session-13-storage-hpa-probes/05-probes ❯ kubectl describe pod startup-demo
Name:             startup-demo
Namespace:        default
Priority:         0
Service Account:  default
Node:             s-b-worker2/172.19.0.2
Start Time:       Mon, 26 Oct 2026 14:43:24 +0530
Labels:           <none>
Annotations:      <none>
Status:           Running
IP:               10.244.2.18
IPs:
  IP:  10.244.2.18
Containers:
  nginx:
    Container ID:   containerd://14ff4e1456a1ee2d20da64cc25671fe129f90a8898e8e0c5e95c68b27b0e534f
    Image:          nginx:1.27
    Image ID:       docker.io/library/nginx@sha256:6784fb0834aa7dbbe12e3d7471e69c290df3e6ba810dc38b34ae33d3c1c05f7d
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 26 Oct 2026 14:43:25 +0530
    Ready:          True
    Restart Count:  0
    Liveness:       http-get http://:80/ delay=0s timeout=1s period=5s #success=1 #failure=3
    Readiness:      http-get http://:80/ delay=0s timeout=1s period=5s #success=1 #failure=3
    Startup:        http-get http://:80/ delay=0s timeout=1s period=2s #success=1 #failure=30
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-pqrhc (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  kube-api-access-pqrhc:
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
  Normal  Scheduled  10s   default-scheduler  Successfully assigned default/startup-demo to s-b-worker2
  Normal  Pulled     9s    kubelet            spec.containers{nginx}: Container image "nginx:1.27" already present on machine and can be accessed by the pod
  Normal  Created    9s    kubelet            spec.containers{nginx}: Container created
  Normal  Started    9s    kubelet            spec.containers{nginx}: Container started
```

### Breaking readiness (`path: /wrong-path`)

Probe fields on a running Pod are immutable, so `kubectl apply` is rejected and the Pod has to be recreated (`kubectl replace --force`):

```bash
…/session-13-storage-hpa-probes/05-probes ❯ grep -n 'path' readiness.yaml
15:          path: /wrong-path

…/session-13-storage-hpa-probes/05-probes ❯ kubectl apply -f readiness.yaml 2>&1 | cut -c1-400
The Pod "readiness-demo" is invalid: spec: Forbidden: pod updates may not change fields other than `spec.containers[*].image`,`spec.initContainers[*].image`,`spec.activeDeadlineSeconds`,`spec.tolerations` (only additions to existing tolerations),`spec.terminationGracePeriodSeconds` (allow it to be set to 1 if it was previously negative)
@@ -136,7 +136,7 @@
    "ReadinessProbe": {
     "Exec": null,
     "HTTPGet": {
-     "Path": "/",
+     "Path": "/wrong-path",
      "Port": 80,
      "Host": "",
      "Scheme": "HTTP",

…/session-13-storage-hpa-probes/05-probes ❯ kubectl replace --force -f readiness.yaml
pod "readiness-demo" deleted from default namespace
pod/readiness-demo replaced

…/session-13-storage-hpa-probes/05-probes ❯ kubectl get pod readiness-demo
NAME             READY   STATUS    RESTARTS   AGE
readiness-demo   0/1     Running   0          25s

…/session-13-storage-hpa-probes/05-probes ❯ kubectl get endpoints readiness-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                ENDPOINTS   AGE
readiness-service               47s

…/session-13-storage-hpa-probes/05-probes ❯ kubectl describe pod readiness-demo | sed -n '/^Events:/,$p'
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  25s               default-scheduler  Successfully assigned default/readiness-demo to s-b-worker2
  Normal   Pulled     25s               kubelet            spec.containers{nginx}: Container image "nginx:1.27" already present on machine and can be accessed by the pod
  Normal   Created    25s               kubelet            spec.containers{nginx}: Container created
  Normal   Started    25s               kubelet            spec.containers{nginx}: Container started
  Warning  Unhealthy  4s (x4 over 19s)  kubelet            spec.containers{nginx}: Readiness probe failed: HTTP probe failed with statuscode: 404

…/session-13-storage-hpa-probes/05-probes ❯ kubectl logs readiness-demo | tail -3
10.244.2.1 - - [26/Oct/2026:09:14:00 +0000] "GET /wrong-path HTTP/1.1" 404 153 "-" "kube-probe/1.37" "-"
2026/10/26 09:14:05 [error] 39#39: *4 open() "/usr/share/nginx/html/wrong-path" failed (2: No such file or directory), client: 10.244.2.1, server: localhost, request: "GET /wrong-path HTTP/1.1", host: "10.244.2.19:80"
10.244.2.1 - - [26/Oct/2026:09:14:05 +0000] "GET /wrong-path HTTP/1.1" 404 153 "-" "kube-probe/1.37" "-"

…/session-13-storage-hpa-probes/05-probes ❯ kubectl exec readiness-demo -- curl -s -o /dev/null -w '%{http_code}\n' http://localhost:80/wrong-path
404

…/session-13-storage-hpa-probes/05-probes ❯ kubectl exec readiness-demo -- curl -s -o /dev/null -w '%{http_code}\n' http://localhost:80/
200
```

The Pod is `Running` but `READY 0/1`. The Service has **no endpoints**, and the container has **0 restarts**, because a readiness failure doesn't restart the container. `curl` from inside shows the app itself is fine: `/` returns 200, and only the probe path returns 404.

### Breaking liveness (`path: /wrong-path`)

```bash
…/session-13-storage-hpa-probes/05-probes ❯ grep -n 'path' liveness.yaml
13:          path: /wrong-path

…/session-13-storage-hpa-probes/05-probes ❯ kubectl replace --force -f liveness.yaml
pod "liveness-demo" deleted from default namespace
pod/liveness-demo replaced

…/session-13-storage-hpa-probes/05-probes ❯ timeout 75 kubectl get pod liveness-demo -w
NAME            READY   STATUS              RESTARTS   AGE
liveness-demo   0/1     ContainerCreating   0          0s
liveness-demo   0/1     ContainerCreating   0          0s
liveness-demo   1/1     Running             0          0s
liveness-demo   1/1     Running             1 (1s ago)   16s
liveness-demo   1/1     Running             2 (0s ago)   53s
liveness-demo   1/1     Running             3 (0s ago)   70s

…/session-13-storage-hpa-probes/05-probes ❯ kubectl describe pod liveness-demo | sed -n '/State:/,/Restart Count/p;/^Events:/,$p'
    State:          Running
      Started:      Mon, 26 Oct 2026 14:45:28 +0530
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Mon, 26 Oct 2026 14:45:11 +0530
      Finished:     Mon, 26 Oct 2026 14:45:28 +0530
    Ready:          True
    Restart Count:  3
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  75s               default-scheduler  Successfully assigned default/liveness-demo to s-b-worker2
  Warning  Unhealthy  22s               kubelet            spec.containers{nginx}: Liveness probe failed: Get "http://10.244.2.20:80/wrong-path": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
  Normal   Pulled     5s (x4 over 75s)  kubelet            spec.containers{nginx}: Container image "nginx:1.27" already present on machine and can be accessed by the pod
  Normal   Created    5s (x4 over 75s)  kubelet            spec.containers{nginx}: Container created
  Normal   Started    5s (x4 over 75s)  kubelet            spec.containers{nginx}: Container started
  Warning  Unhealthy  5s (x8 over 70s)  kubelet            spec.containers{nginx}: Liveness probe failed: HTTP probe failed with statuscode: 404
  Normal   Killing    5s (x3 over 60s)  kubelet            spec.containers{nginx}: Container nginx failed liveness probe, will be restarted

…/session-13-storage-hpa-probes/05-probes ❯ kubectl get events --sort-by=.lastTimestamp --field-selector involvedObject.name=liveness-demo
LAST SEEN   TYPE      REASON      OBJECT              MESSAGE
2m34s       Normal    Scheduled   pod/liveness-demo   Successfully assigned default/liveness-demo to s-b-worker2
2m33s       Normal    Pulled      pod/liveness-demo   Container image "nginx:1.27" already present on machine and can be accessed by the pod
2m33s       Normal    Created     pod/liveness-demo   Container created
2m33s       Normal    Started     pod/liveness-demo   Container started
77s         Normal    Killing     pod/liveness-demo   Stopping container nginx
75s         Normal    Scheduled   pod/liveness-demo   Successfully assigned default/liveness-demo to s-b-worker2
22s         Warning   Unhealthy   pod/liveness-demo   Liveness probe failed: Get "http://10.244.2.20:80/wrong-path": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
5s          Normal    Pulled      pod/liveness-demo   Container image "nginx:1.27" already present on machine and can be accessed by the pod
5s          Normal    Created     pod/liveness-demo   Container created
5s          Normal    Started     pod/liveness-demo   Container started
5s          Warning   Unhealthy   pod/liveness-demo   Liveness probe failed: HTTP probe failed with statuscode: 404
5s          Normal    Killing     pod/liveness-demo   Container nginx failed liveness probe, will be restarted
```

After 3 failures (`failureThreshold: 3`, `periodSeconds: 5`) the kubelet kills the container and restarts it, so the `RESTARTS` count climbs.

### Fix: restore `path: /`

```bash
…/session-13-storage-hpa-probes/05-probes ❯ grep -n 'path' liveness.yaml readiness.yaml
readiness.yaml:15:          path: /
liveness.yaml:13:          path: /

…/session-13-storage-hpa-probes/05-probes ❯ kubectl replace --force -f liveness.yaml -f readiness.yaml
pod "liveness-demo" deleted from default namespace
pod "readiness-demo" deleted from default namespace
pod/liveness-demo replaced
pod/readiness-demo replaced

…/session-13-storage-hpa-probes/05-probes ❯ kubectl get pod liveness-demo readiness-demo startup-demo
NAME             READY   STATUS    RESTARTS   AGE
liveness-demo    1/1     Running   0          31s
readiness-demo   1/1     Running   0          31s
startup-demo     1/1     Running   0          2m47s

…/session-13-storage-hpa-probes/05-probes ❯ kubectl get endpoints readiness-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                ENDPOINTS       AGE
readiness-service   10.244.1.8:80   2m49s

…/session-13-storage-hpa-probes/05-probes ❯ kubectl delete svc readiness-service
service "readiness-service" deleted from default namespace

…/session-13-storage-hpa-probes/05-probes ❯ kubectl delete -f liveness.yaml -f readiness.yaml -f startup.yaml
pod "liveness-demo" deleted from default namespace
pod "readiness-demo" deleted from default namespace
pod "startup-demo" deleted from default namespace
```

## Mini Project - Production-Ready Web App (PVC + HPA + Probes)

### Deploy

```bash
…/session-13-storage-hpa-probes/mini-project ❯ kubectl apply -f namespace.yaml
namespace/production-webapp created

…/session-13-storage-hpa-probes/mini-project ❯ kubectl apply -f pvc.yaml
persistentvolumeclaim/web-data created

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get pvc -n production-webapp
NAME       STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
web-data   Pending                                      standard       <unset>                 0s

…/session-13-storage-hpa-probes/mini-project ❯ kubectl apply -f deployment.yaml
deployment.apps/web-app created

…/session-13-storage-hpa-probes/mini-project ❯ kubectl apply -f service.yaml
service/web-service created

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get pods -n production-webapp -o wide
NAME                      READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
web-app-d45775485-27kbx   1/1     Running   0          13s   10.244.2.28   s-b-worker2   <none>           <none>
web-app-d45775485-ztsxz   1/1     Running   0          13s   10.244.2.29   s-b-worker2   <none>           <none>

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get pvc -n production-webapp
NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
web-data   Bound    pvc-b4617d0a-860e-4d37-82d7-e1507be0bd30   500Mi      RWO            standard       <unset>                 13s

…/session-13-storage-hpa-probes/mini-project ❯ kubectl apply -f hpa.yaml
horizontalpodautoscaler.autoscaling/web-app-hpa created

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get hpa -n production-webapp
NAME          REFERENCE            TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
web-app-hpa   Deployment/web-app   cpu: 1%/50%   2         5         2          40s
```

### Task 1 - Storage persistence

```bash
…/session-13-storage-hpa-probes/mini-project ❯ POD_NAME=$(kubectl get pods -n production-webapp -l app=web-app -o jsonpath='{.items[0].metadata.name}'); echo $POD_NAME; kubectl exec -n production-webapp "$POD_NAME" -- sh -c 'echo "Student: Adam" > /data/student.txt'; kubectl exec -n production-webapp "$POD_NAME" -- cat /data/student.txt; kubectl delete pod -n production-webapp "$POD_NAME"
web-app-d45775485-27kbx
Student: Adam
pod "web-app-d45775485-27kbx" deleted from production-webapp namespace

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get pods -n production-webapp
NAME                      READY   STATUS    RESTARTS   AGE
web-app-d45775485-fwmx4   1/1     Running   0          8s
web-app-d45775485-ztsxz   1/1     Running   0          71s

…/session-13-storage-hpa-probes/mini-project ❯ NEW_POD=$(kubectl get pods -n production-webapp -l app=web-app -o jsonpath='{.items[0].metadata.name}'); echo $NEW_POD; kubectl exec -n production-webapp "$NEW_POD" -- cat /data/student.txt
web-app-d45775485-fwmx4
Student: Adam
```

### Task 2 - Service verification

```bash
…/session-13-storage-hpa-probes/mini-project ❯ kubectl port-forward -n production-webapp svc/web-service 18251:80 &

…/session-13-storage-hpa-probes/mini-project ❯ curl -s http://localhost:18251 | head -5
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
```

![nginx welcome page served by web-service via port-forward](web-service.png)

### Task 3 - HPA scaling

```bash
…/session-13-storage-hpa-probes/mini-project ❯ kubectl run load-generator -n production-webapp --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://web-service; done"
pod/load-generator created

…/session-13-storage-hpa-probes/mini-project ❯ timeout 180 kubectl get hpa -n production-webapp -w
NAME          REFERENCE            TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
web-app-hpa   Deployment/web-app   cpu: 1%/50%   2         5         2          77s
web-app-hpa   Deployment/web-app   cpu: 27%/50%   2         5         2          105s
web-app-hpa   Deployment/web-app   cpu: 32%/50%   2         5         2          2m
web-app-hpa   Deployment/web-app   cpu: 20%/50%   2         5         2          2m15s
web-app-hpa   Deployment/web-app   cpu: 29%/50%   2         5         2          2m45s
web-app-hpa   Deployment/web-app   cpu: 36%/50%   2         5         2          3m
web-app-hpa   Deployment/web-app   cpu: 20%/50%   2         5         2          3m15s
web-app-hpa   Deployment/web-app   cpu: 25%/50%   2         5         2          3m45s
web-app-hpa   Deployment/web-app   cpu: 35%/50%   2         5         2          4m
web-app-hpa   Deployment/web-app   cpu: 23%/50%   2         5         2          4m15s

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get pods -n production-webapp -o wide
NAME                      READY   STATUS    RESTARTS   AGE     IP            NODE          NOMINATED NODE   READINESS GATES
load-generator            1/1     Running   0          3m      10.244.1.14   s-b-worker    <none>           <none>
web-app-d45775485-fwmx4   1/1     Running   0          3m27s   10.244.2.30   s-b-worker2   <none>           <none>
web-app-d45775485-ztsxz   1/1     Running   0          4m30s   10.244.2.29   s-b-worker2   <none>           <none>

…/session-13-storage-hpa-probes/mini-project ❯ kubectl top pods -n production-webapp
NAME                      CPU(cores)   MEMORY(bytes)   
load-generator            853m         11Mi            
web-app-d45775485-fwmx4   21m          9Mi             
web-app-d45775485-ztsxz   25m          9Mi             
```

One load generator kept the 2 Pods at about 20-36% CPU, below the 50% target, so no scale-out happened.

### Bonus 1 - Lower the target to 30%

```bash
…/session-13-storage-hpa-probes/mini-project ❯ grep averageUtilization hpa.yaml
          averageUtilization: 30

…/session-13-storage-hpa-probes/mini-project ❯ kubectl apply -f hpa.yaml
horizontalpodautoscaler.autoscaling/web-app-hpa configured

…/session-13-storage-hpa-probes/mini-project ❯ timeout 120 kubectl get hpa -n production-webapp -w
NAME          REFERENCE            TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
web-app-hpa   Deployment/web-app   cpu: 23%/30%   2         5         2          4m23s
web-app-hpa   Deployment/web-app   cpu: 20%/30%   2         5         2          4m30s
web-app-hpa   Deployment/web-app   cpu: 24%/30%   2         5         2          4m45s
web-app-hpa   Deployment/web-app   cpu: 34%/30%   2         5         2          5m
web-app-hpa   Deployment/web-app   cpu: 23%/30%   2         5         3          5m15s
web-app-hpa   Deployment/web-app   cpu: 15%/30%   2         5         3          5m30s
web-app-hpa   Deployment/web-app   cpu: 16%/30%   2         5         3          5m45s
web-app-hpa   Deployment/web-app   cpu: 21%/30%   2         5         3          6m

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get pods -n production-webapp -o wide
NAME                      READY   STATUS    RESTARTS   AGE     IP            NODE          NOMINATED NODE   READINESS GATES
load-generator            1/1     Running   0          5m6s    10.244.1.14   s-b-worker    <none>           <none>
web-app-d45775485-5hk2f   1/1     Running   0          83s     10.244.2.31   s-b-worker2   <none>           <none>
web-app-d45775485-fwmx4   1/1     Running   0          5m33s   10.244.2.30   s-b-worker2   <none>           <none>
web-app-d45775485-ztsxz   1/1     Running   0          6m36s   10.244.2.29   s-b-worker2   <none>           <none>

…/session-13-storage-hpa-probes/mini-project ❯ kubectl describe hpa web-app-hpa -n production-webapp | sed -n '/^Events:/,$p'
Events:
  Type     Reason                        Age    From                       Message
  ----     ------                        ----   ----                       -------
  Warning  FailedGetResourceMetric       6m23s  horizontal-pod-autoscaler  failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedComputeMetricsReplicas  6m23s  horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedGetResourceMetric       6m8s   horizontal-pod-autoscaler  failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
  Warning  FailedComputeMetricsReplicas  6m8s   horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
  Normal   SuccessfulRescale             83s    horizontal-pod-autoscaler  New size: 3; reason: cpu resource utilization (percentage of request) above target
```

### Bonus 2 - Readiness gating (`/does-not-exist`)

```bash
…/session-13-storage-hpa-probes/mini-project ❯ kubectl delete pod load-generator -n production-webapp
pod "load-generator" deleted from production-webapp namespace

…/session-13-storage-hpa-probes/mini-project ❯ grep -n -A2 'readinessProbe' deployment.yaml
41:          readinessProbe:
42-            httpGet:
43-              path: /does-not-exist

…/session-13-storage-hpa-probes/mini-project ❯ kubectl apply -f deployment.yaml
deployment.apps/web-app configured

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get pods -n production-webapp
NAME                       READY   STATUS    RESTARTS   AGE
web-app-5945bfc776-b5c7c   0/1     Running   0          40s
web-app-5945bfc776-zg82f   0/1     Running   0          40s

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get endpoints -n production-webapp web-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME          ENDPOINTS   AGE
web-service               7m55s

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get events -n production-webapp --field-selector reason=Unhealthy | tail -3
LAST SEEN   TYPE      REASON      OBJECT                         MESSAGE
1s          Warning   Unhealthy   pod/web-app-5945bfc776-b5c7c   Readiness probe failed: HTTP probe failed with statuscode: 404
1s          Warning   Unhealthy   pod/web-app-5945bfc776-zg82f   Readiness probe failed: HTTP probe failed with statuscode: 404
```

Pods are `Running` but `0/1`, and the Service endpoint list is empty.

### Bonus 3 - Liveness restart loop (`/crash`)

```bash
…/session-13-storage-hpa-probes/mini-project ❯ grep -n -A2 -E 'readinessProbe|livenessProbe' deployment.yaml
41:          readinessProbe:
42-            httpGet:
43-              path: /
--
49:          livenessProbe:
50-            httpGet:
51-              path: /crash

…/session-13-storage-hpa-probes/mini-project ❯ kubectl apply -f deployment.yaml
deployment.apps/web-app configured

…/session-13-storage-hpa-probes/mini-project ❯ timeout 90 kubectl get pods -n production-webapp -w
NAME                       READY   STATUS        RESTARTS   AGE
web-app-5945bfc776-b5c7c   0/1     Terminating   0          49s
web-app-5945bfc776-zg82f   0/1     Terminating   0          49s
web-app-5945bfc776-b5c7c   0/1     Completed     0          49s
web-app-5945bfc776-zg82f   0/1     Completed     0          49s
web-app-85d86b65d-6b8gk    0/1     Pending       0          0s
web-app-85d86b65d-6b8gk    0/1     Pending       0          0s
web-app-85d86b65d-lrjlj    0/1     Pending       0          0s
web-app-85d86b65d-lrjlj    0/1     Pending       0          0s
web-app-85d86b65d-6b8gk    0/1     ContainerCreating   0          0s
web-app-85d86b65d-lrjlj    0/1     ContainerCreating   0          0s
web-app-5945bfc776-b5c7c   0/1     Completed           0          50s
web-app-5945bfc776-zg82f   0/1     Completed           0          50s
web-app-5945bfc776-zg82f   0/1     Completed           0          50s
web-app-5945bfc776-zg82f   0/1     Completed           0          50s
web-app-5945bfc776-b5c7c   0/1     Completed           0          50s
web-app-5945bfc776-b5c7c   0/1     Completed           0          50s
web-app-85d86b65d-6b8gk    0/1     ContainerCreating   0          1s
web-app-85d86b65d-lrjlj    0/1     ContainerCreating   0          1s
web-app-85d86b65d-6b8gk    0/1     Running             0          1s
web-app-85d86b65d-lrjlj    0/1     Running             0          1s
web-app-85d86b65d-6b8gk    0/1     Running             0          3s
web-app-85d86b65d-6b8gk    0/1     Running             0          3s
web-app-85d86b65d-lrjlj    0/1     Running             0          3s
web-app-85d86b65d-lrjlj    1/1     Running             0          10s
web-app-85d86b65d-6b8gk    1/1     Running             0          10s
web-app-85d86b65d-6b8gk    0/1     Running             1 (0s ago)   16s
web-app-85d86b65d-lrjlj    0/1     Running             1 (0s ago)   16s
web-app-85d86b65d-6b8gk    0/1     Running             1 (1s ago)   17s
web-app-85d86b65d-lrjlj    0/1     Running             1 (1s ago)   17s
web-app-85d86b65d-6b8gk    0/1     Running             1 (3s ago)   19s
web-app-85d86b65d-lrjlj    0/1     Running             1 (3s ago)   19s
web-app-85d86b65d-lrjlj    1/1     Running             1 (8s ago)   24s
web-app-85d86b65d-6b8gk    1/1     Running             1 (8s ago)   24s
web-app-85d86b65d-6b8gk    0/1     Running             2 (0s ago)   31s
web-app-85d86b65d-lrjlj    0/1     Running             2 (0s ago)   31s
web-app-85d86b65d-6b8gk    0/1     Running             2 (2s ago)   33s
web-app-85d86b65d-lrjlj    0/1     Running             2 (2s ago)   33s
web-app-85d86b65d-6b8gk    0/1     Running             2 (4s ago)   35s
web-app-85d86b65d-lrjlj    0/1     Running             2 (4s ago)   35s
web-app-85d86b65d-6b8gk    1/1     Running             2 (9s ago)   40s
web-app-85d86b65d-lrjlj    1/1     Running             2 (9s ago)   40s
web-app-85d86b65d-lrjlj    0/1     Running             3 (0s ago)   46s
web-app-85d86b65d-6b8gk    0/1     Running             3 (0s ago)   46s
web-app-85d86b65d-6b8gk    0/1     Running             3 (1s ago)   47s
web-app-85d86b65d-lrjlj    0/1     Running             3 (1s ago)   47s
web-app-85d86b65d-6b8gk    0/1     Running             3 (3s ago)   49s
web-app-85d86b65d-lrjlj    0/1     Running             3 (3s ago)   49s
web-app-85d86b65d-lrjlj    1/1     Running             3 (8s ago)   54s
web-app-85d86b65d-6b8gk    1/1     Running             3 (8s ago)   54s
web-app-85d86b65d-6b8gk    0/1     CrashLoopBackOff    3 (0s ago)   61s
web-app-85d86b65d-lrjlj    0/1     CrashLoopBackOff    3 (0s ago)   61s
web-app-85d86b65d-lrjlj    0/1     Running             4 (22s ago)   83s
web-app-85d86b65d-lrjlj    0/1     Running             4 (22s ago)   83s
web-app-85d86b65d-6b8gk    0/1     Running             4 (25s ago)   86s
web-app-85d86b65d-6b8gk    0/1     Running             4 (26s ago)   87s
web-app-85d86b65d-lrjlj    1/1     Running             4 (28s ago)   89s

…/session-13-storage-hpa-probes/mini-project ❯ kubectl describe pod -n production-webapp $(kubectl get pods -n production-webapp -o name | head -1 | cut -d/ -f2) | sed -n '/^Events:/,$p'
Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  89s                 default-scheduler  Successfully assigned production-webapp/web-app-85d86b65d-6b8gk to s-b-worker2
  Warning  Unhealthy  29s (x12 over 84s)  kubelet            spec.containers{nginx}: Liveness probe failed: HTTP probe failed with statuscode: 404
  Normal   Killing    29s (x4 over 74s)   kubelet            spec.containers{nginx}: Container nginx failed liveness probe, will be restarted
  Warning  BackOff    26s (x3 over 29s)   kubelet            spec.containers{nginx}: Back-off restarting failed container nginx in pod web-app-85d86b65d-6b8gk_production-webapp(df6afb2a-dc3b-479f-8c65-6d07f1eaf68f)
  Normal   Pulled     4s (x5 over 89s)    kubelet            spec.containers{nginx}: Container image "nginx:1.27" already present on machine and can be accessed by the pod
  Normal   Created    4s (x5 over 89s)    kubelet            spec.containers{nginx}: Container created
  Normal   Started    4s (x5 over 89s)    kubelet            spec.containers{nginx}: Container started
```

The kubelet keeps killing the containers ("failed liveness probe, will be restarted") until they go into `CrashLoopBackOff`.

### Fix - restore probe paths

The data written in Task 1 is still on the PVC after all these rollouts:

```bash
…/session-13-storage-hpa-probes/mini-project ❯ grep -n -A2 -E 'readinessProbe|livenessProbe' deployment.yaml
41:          readinessProbe:
42-            httpGet:
43-              path: /
--
49:          livenessProbe:
50-            httpGet:
51-              path: /

…/session-13-storage-hpa-probes/mini-project ❯ kubectl apply -f deployment.yaml
deployment.apps/web-app configured

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get pods -n production-webapp
NAME                      READY   STATUS    RESTARTS   AGE
web-app-d45775485-k79ld   1/1     Running   0          14s
web-app-d45775485-z7v4q   1/1     Running   0          14s

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get endpoints -n production-webapp web-service
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME          ENDPOINTS                       AGE
web-service   10.244.2.36:80,10.244.2.37:80   9m49s

…/session-13-storage-hpa-probes/mini-project ❯ kubectl exec -n production-webapp deploy/web-app -- cat /data/student.txt
Student: Adam

…/session-13-storage-hpa-probes/mini-project ❯ kubectl get hpa -n production-webapp
NAME          REFERENCE            TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
web-app-hpa   Deployment/web-app   cpu: 1%/30%   2         5         2          10m

…/session-13-storage-hpa-probes/mini-project ❯ kubectl delete namespace production-webapp
namespace "production-webapp" deleted
```

## Key learnings

* `emptyDir` lives as long as the Pod. `hostPath` is tied to one node. PV/PVC storage outlives Pods.
* A PVC with no `storageClassName` gets the **default** class filled in. To bind to a static class-less PV, set `storageClassName: ""`.
* `WaitForFirstConsumer` StorageClasses keep a PVC `Pending` until a Pod uses it. That is normal, not an error.
* The HPA needs metrics-server **and** `resources.requests.cpu`. Scale-up is quick (about 15s per check). Scale-down waits through a 5-minute stabilization window.
* Readiness failure: Pod stays `Running` at `0/1`, is removed from the Service endpoints, and does **not** restart. Liveness failure: the container restarts, then goes into `CrashLoopBackOff`.
* Probe fields are immutable on a bare Pod, so recreate it (`kubectl replace --force`). In a Deployment you just `apply` and it rolls out.
