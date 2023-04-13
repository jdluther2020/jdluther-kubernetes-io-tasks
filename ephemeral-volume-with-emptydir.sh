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
  name: frontend
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        ephemeral-storage: "1Gi"
      limits:
        ephemeral-storage: "2Gi"
    volumeMounts:
    - name: ephemeral
      mountPath: "/tmp"
  - name: log-aggregator
    image: radial/busyboxplus
    command: ['sh', '-c', 'while true; do echo "$HOSTNAME: `date` : Welcome to Nginx! Hosted on emptyDir, testing resource requests and limits!!" >> /html/index.html; sleep 10; done']
    resources:
      requests:
        ephemeral-storage: "1Gi"
      limits:
        ephemeral-storage: "2Gi"
    volumeMounts:
    - name: ephemeral
      mountPath: "/tmp"
  volumes:
    - name: ephemeral
      emptyDir:
        sizeLimit: 500Mi
EOF
