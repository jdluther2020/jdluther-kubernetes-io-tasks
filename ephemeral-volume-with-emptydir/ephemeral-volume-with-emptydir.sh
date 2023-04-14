# Mastering Kubernetes One Task at a Time - Ephemeral Storage Volumes with 'emptyDir'

# 
# Author's NOTE
# 1. This file although can run as one whole script, some commands may error because of need for occassional manual edits. 
# 2. Make the right call after reviewing and following command specific instructions below.
# 3. Normally the commands are used to create one resource object at a time for the primary purpose of learning. 
#

#
# References:
# Volumes  - https://kubernetes.io/docs/concepts/storage/volumes/
# Ephemeral Volumes - https://kubernetes.io/docs/concepts/storage/ephemeral-volumes
# EmptyDir - https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
# API Spec - https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/volume/#local-temporary-directory
#

#
# OBJECTIVE 1 - CREATE AN EMPTYDIR SHARED VOLUME FOR INTER-CONTAINER COMMUNICATION IN A POD
# - Create a pod with three containers, two sharing an emptyDir volumes type to communicate with each other
# - Ref: https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/
#

cat <<EOF | tee emptydir-shared-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-shared-pod
spec:
  volumes:
  - name: ehpemeral-volume
    emptyDir: {}
  containers:
  - name: nginx-container
    image: nginx
    volumeMounts:
    - name: ehpemeral-volume
      mountPath: /usr/share/nginx/html
  - name: debian-container
    image: debian
    volumeMounts:
    - name: ehpemeral-volume
      mountPath: /debian-data
    command: ['sh', '-c', 'echo "$HOSTNAME: Welcome to Nginx! Message written by Debian at `date`!!" > /debian-data/index.html']
  - name: busyboxplus-container
    image: radial/busyboxplus
    command: ['sh', '-c', 'sleep 3600']
  restartPolicy: Never
EOF

# Create pod
kubectl apply -f emptydir-shared-pod.yaml

# Get pod status details and obtain POD_IP for next command
kubectl get -f emptydir-shared-pod.yaml -o wide

# Access nginx web server via busyboxplus container. See message from running nginx rcontainer written by terminated debian continaer.
kubectl exec emptydir-shared-pod -c busyboxplus-container -- curl -s _POD_IP_


#
# OBJECTIVE 2 - MOUNT A TMPFS (RAM-BACKED FILESYSTEM) TO EMPTYDIR MEDIUM SPECIFICATION
# - Create a pod with an emptyDir volumes type using memory medium
# - Ref - https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
# - Ref: SizeMemoryBackedVolumes feature gate - https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/
# 

cat <<EOF | tee emptydir-memory.yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-memory
spec:
  containers:
  - name: nginx-container
    image: nginx
    volumeMounts:
    - mountPath: /usr/share/nginx/html
      name: memory-volume
  - name: fedora-container
    image: fedora
    command: ['sh', '-c', 'while true; do echo "$HOSTNAME: `date` : Welcome to Nginx! Hosted on emptyDir Memory Volume!!" >> /html/index.html; sleep 10; done']
    volumeMounts:
    - name: memory-volume
      mountPath: /html
  volumes:
  - name: memory-volume
    emptyDir:
      medium: Memory
EOF

# Create pod
kubectl apply -f emptydir-memory.yaml

# Get pod status details and obtain POD_IP for next command
kubectl get -f emptydir-memory.yaml -o wide

# Access nginx web server via fedora container to make sure it's up and serving
kubectl exec emptydir-memory -c fedora-container -- curl -s _POD_IP_

# Check the filesystem tmpfs mounted on /html. 
# tmpfs memory backed volumes are sized to 50% of the memory on a Linux host unless sizeLimit specified.
# In the 'df' output, used and availale space should change as index.html grows every second.
kubectl exec emptydir-memory -c fedora-container -- df -H /html


#
# OBJECTIVE 3 - SPECIFYING EPHEMERAL STORAGE SIZE LIMIT OF AN EMPTYDIR VOLUME
# - Create a pod with requests and limits for local ephemeral storage and emptyDir size limit
# - Ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#setting-requests-and-limits-for-local-ephemeral-storage
#

cat <<EOF | tee emptydir-sizelimit.yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-sizelimit
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        ephemeral-storage: "1Gi"
      limits:
        ephemeral-storage: "2Gi"
    volumeMounts:
    - name: ephemeral
      mountPath: /usr/share/nginx/html
  - name: alpine
    image: alpine
    command: ['sh', '-c', 'apk --update add curl; while true; do echo "$HOSTNAME: `date` : Welcome to Nginx! Hosted on emptyDir, testing resource requests and limits!!" >> /html/index.html; sleep 10; done']
    resources:
      requests:
        ephemeral-storage: "1Gi"
      limits:
        ephemeral-storage: "2Gi"
    volumeMounts:
    - name: ephemeral
      mountPath: "/html"
  volumes:
    - name: ephemeral
      emptyDir:
        sizeLimit: 500Mi
EOF

# Create pod
kubectl apply -f emptydir-sizelimit.yaml

# Get pod status details, obtain POD_IP for next command, obtain node hosting the pod for later command
kubectl get -f emptydir-sizelimit.yaml -o wide

# Test to make sure nginx webserver is responsive
kubectl exec emptydir-sizelimit -c alpine -- curl _POD_IP_

# Check disk space status of emptyDir volume
kubectl exec emptydir-sizelimit -c alpine -- df  /html

# Force exceed the size limit of emptyDir volume
kubectl exec emptydir-sizelimit -c alpine -- sh -c "fallocate -l 500M /html/big-file.txt && ls -l /html"

# Check node status. Expect warning for exceeding size limit
kubectl describe node _NODE_NAME_
{
Events:
  Type     Reason                Age    From     Message
  ----     ------                ----   ----     -------
  Warning  EvictionThresholdMet  3m39s  kubelet  Attempting to reclaim ephemeral-storage
  Normal   NodeHasDiskPressure   3m35s  kubelet  Node k8s-worker1 status is now: NodeHasDiskPressure
}

# Check pod status. Expect pod termination
kubectl get -f emptydir-sizelimit.yaml -o wide
{
NAME                 READY   STATUS   RESTARTS   AGE   IP               NODE          NOMINATED NODE   READINESS GATES
emptydir-sizelimit   0/2     Error    1          13m   192.168.194.66   k8s-worker1   <none>           <none>
}

# Describe pod get mode information. Expect to see eviction warning followed by termination
kubectl describe pod emptydir-sizelimit
{
Status:       Failed
Reason:       Evicted
Message:      Usage of EmptyDir volume "ephemeral" exceeds the limit "500Mi".
...
Events:
  Type     Reason               Age    From               Message
...
  Warning  Evicted              4m31s  kubelet            Usage of EmptyDir volume "ephemeral" exceeds the limit "500Mi".
  Normal   Killing              4m31s  kubelet            Stopping container nginx
  Normal   Killing              4m31s  kubelet            Stopping container alpine
  Warning  ExceededGracePeriod  4m21s  kubelet            Container runtime did not kill the pod within specified grace period.
}

# Clean up the terminated pod
kubectl delete -f emptydir-sizelimit.yaml

# That's a wrap!
