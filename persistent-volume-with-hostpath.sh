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

# Create deployment manifest
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
kubectl apply -f deploy.yaml

# Verify that the Deployment was created successfully
kubectl get deployment reader-writer

# Get the deployment pod listing
kubectl get pods

# Delete any pod belonging to the deployment and new pod will spring up
# (Alternately delete the deployment and recreate it)
kubectl delete pod _POD_NAME_

# Get the deployment new pod listing
kubectl get pods

# Check log the newest pods created. Expect to see the message written by previous pods.
kubectl logs _POD_NAME_

# Clean up 
# Delete deployment
kubectl delete -f deploy.yaml

# Delete the host files (commands applicable to containers as nodes, ssh if dealing with non-container servers)
docker exec basic-multi-node-cluster-worker rm -f /var/local/hostpath-data/file.txt
docker exec basic-multi-node-cluster-worker2 rm -f /var/local/hostpath-data/file.txt

#
#  OBJECTIVE 2 - USING MULTIPLE VOLUMES AND VOLUMEMOUNTS IN A POD
# - Create a pod with multiple volumes and multiple mountpoints
#
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
