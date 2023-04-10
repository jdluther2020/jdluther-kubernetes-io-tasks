# Mastering Kubernetes One Task at a Time - Persistent Storage Volumes with 'hostPath'

# 
# Author's NOTE
# 1. This file although can run as one whole script, some commands may error because of need for occassional manual edits. 
# 2. Make the right call after reviewing and following command specific instructions below.
# 3. Normally the commands are used to create one resource object at a time for the primary purpose of learning. 
#

#
# References:
# Volumes - https://kubernetes.io/docs/concepts/storage/volumes/
#

#
#  OBJECTIVE 1 - CREATE PERSISTENT VOLUMES USING LOCAL DISK OF WORKER NODES
# - Create a deployment with each pod reading and writing to its own host node's local disk
# - If pod is deleted, deployment will create new pods to match replica count and 
#   new pods will have access to prior content because data persists beyond the lifetime of a pod
#

# Create deployment manifest (to avoid shell variable interpretation, copy the manifest straight instead of cat command)
# Ideally match number of replicas with  number of cluster nodes. We have 2 nodes, so I am using 2 replicas.
cat <<EOF | tee reader-writer.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reader-writer
  labels:
    app: reader-writer
spec:
  replicas: 2
  selector:
    matchLabels:
      app: reader-writer-pod
  template:
    metadata:
      labels:
        app: reader-writer-pod
    spec:
      volumes:
      - name: host-vol
        hostPath:
          path: /var/local/hostpath-data
          type: DirectoryOrCreate
      containers:
      - name: busybox-container
        image: busybox:stable
        command: ['sh', '-c', 'file=/output/file.txt; if [ -f $file ]; then cat $file; fi; echo "`date` : Written by pod $POD_NAME running on $NODE_NAME" >> $file; sleep 3600']
        volumeMounts:
        - name: host-vol
          mountPath: /output
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
EOF

# Create the deployment with the manifest
kubectl apply -f reader-writer.yaml

# Verify that the Deployment was created successfully
kubectl get deployment reader-writer

# Get the deployment pod listing
kubectl get pods

# Delete any pod belonging to the deployment and new pod will spring up
kubectl delete pod reader-writer-7b6b7dffc4-5p7p2

# Get the deployment new pod listing
kubectl get pods

# Check log the newest pods created. Expect to see the message written by the previous pods.
kubectl logs reader-writer-7b6b7dffc4-24pxk 

# Clean up
# Delete deployment
kubectl delete -f reader-writer.yaml

# Get cluster nodes listing
kubectl get nodes

# Check the persistent data written by the deployment even afters its deletion
# NOTE: 'docker exec' is applicable to containers as nodes, 'ssh' if dealing with non-container servers
# Worker node 1
docker exec basic-multi-node-cluster-worker cat /var/local/hostpath-data/file.txt

# Worker node 2 (expect 2 lines since 2 pods ran on it, first by the initial deployment, the second by the new pod)
docker exec basic-multi-node-cluster-worker2 cat /var/local/hostpath-data/file.txt

# Delete the host files
docker exec basic-multi-node-cluster-worker rm -f /var/local/hostpath-data/file.txt
docker exec basic-multi-node-cluster-worker2 rm -f /var/local/hostpath-data/file.txt

#
#  OBJECTIVE 2 - USING MULTIPLE VOLUMES AND VOLUMEMOUNTS IN A POD
# - Create a pod with multiple volumes and multiple mountpoints
#

# Create pod manifest (to avoid shell variable interpretation, copy the manifest straight instead of cat command)
# Here we will mount 3 folders from the node filesystem and list the folder contents of each mounted volume
cat <<EOF | tee alpine-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine-pod
  labels:
    app: alpine
spec:
  containers:
  - name: alpine-pod-container
    image: alpine:latest
    command: ['sh', '-c', 'for dir in /var-local /usr-share /tmpdir; do echo "*** Listing $dir:*** "; ls -l $dir; done; sleep 3600']
    volumeMounts:
    - name: vol-var-local
      mountPath: /var-local
      readOnly: true
    - name: vol-usr-share
      mountPath: /usr-share
      readOnly: true
    - name: vol-tmpdir
      mountPath: /tmpdir
  volumes:
  - name: vol-var-local
    hostPath:
      path: /var/local
      type: Directory
  - name: vol-usr-share
    hostPath:
      path: /usr/share
      type: Directory
  - name: vol-tmpdir
    hostPath:
      path: /tmp
      type: Directory
EOF

# Create pod
kubectl apply -f alpine-pod.yaml

# Check pod created successfully
kubectl get pod alpine-pod

# Check log to see pod written output
kubectl logs alpine-pod


#
#  OBJECTIVE 3 -SHARING VOLUMES AMONG MULTIPLE CONTAINERS
# - Create a pod with two containers sharing the same volume, one for writing, one for reading
#

# Create the pod manifest with two containers, one writer and another reader
# (to avoid shell variable interpretation, copy the manifest straight instead of cat command)
cat <<EOF | shared-volume-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-volume-pod
spec:
  containers:
  - name: main-container
    image: busybox
    command: ['sh', '-c', 'while true; do echo "`date` : $CONTAINER_NAME : Test Message" >> /outdir/log.txt; sleep 5; done']
    env:
    - name: CONTAINER_NAME
      value: "main-container"
    volumeMounts:
    - name: vol-shared
      mountPath: /outdir
  - name: sidecar-container
    image: alpine
    command: ['sh', '-c', 'tail -f /indir/log.txt']
    volumeMounts:
    - name: vol-shared
      mountPath: /indir
  volumes:
  - name: vol-shared
    hostPath:
      path: /usr/share
EOF

# Create pod
kubectl apply -f shared-volume-pod.yaml

# Check pod created successfully and list the hosted node
kubectl get pod shared-volume-pod -o wide

# Check log to see sidecar container output
kubectl logs shared-volume-pod -c sidecar-container

# That's a wrap!
