# ConfigMaps-Part 2: Consuming Configuration Data
# Purpose: Learning how to use or consume data stored in ConfigMaps resources inside a pod and container
# Script: https://github.com/jdluther2020/jdluther-kubernetes-io-tasks/tree/main/configmaps-part-2-consuming-configuration-data.sh

# 
# Author's NOTE
# - This file although can run as one whole script, it's normally used to create one resource object at a time to meet each objective as specified.
#

#
# Helpful References, All in One Place:
#
# - https://kubernetes.io/search/?q=configmap
# - https://kubernetes.io/docs/concepts/configuration/configmap/
# - https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
# - https://kubernetes.io/docs/tutorials/configuration/configure-redis-using-configmap/
#

#
# CLONE REPO
#

CM_CDIR=configmaps-part-2-consuming-configuration-data && \
REPO=jdluther-kubernetes-io-tasks && \
    git clone https://github.com/jdluther2020/$REPO.git && \
    cd $REPO/$CM_CDIR && \
    ls -1

#
# OBJECTIVE 01: Using ConfigMap Data as Container Environment Variables
# 
# This illustrates the following two ways of using a CM resource
# 1. Inside a container command and args
# 2. Environment variables for a container
#

# First create two different ConfigMaps objects

# ConfigMap 1 manifest with name cm-01 from a file 
# using --from-env-file option (multiple KEY=VALUE pairs)
kubectl create configmap cm-01 \
  --from-env-file=config-maps-data-dir/nginx-cm.params \
  --dry-run=client -o yaml | tee cm-01.yaml

# ConfigMap 2 manifest with name cm-02 from a file 
# using --from-env-file option (multiple KEY=VALUE pairs)
kubectl create configmap cm-02 \
  --from-env-file=config-maps-data-dir/ports.params \
  --dry-run=client -o yaml | tee cm-02.yaml

# Create both CMs
kubectl create -f  cm-01.yaml
kubectl create -f  cm-02.yaml

# Describe CMs and confirm the data fields
kubectl describe cm cm-01
kubectl describe cm cm-02

# Review the pod file
cat cm-consumer-pod-01.yaml

# Create a pod and read specific keys from different CM objects to ENV vars
kubectl create -f cm-consumer-pod-01.yaml

# Make sure pod is running
kubectl get pods

# Verify the ENV vars were set and written to pod logs
# I used CMENV_ prefix in the pod to help filtering and looking up
kubectl logs cm-consumer-pod-01 | grep CMENV_

# Another way to look up env vars is by exec'ing to a running pod
kubectl exec cm-consumer-pod-01  -- env | grep CMENV_

# Successfully captured the CM data as Env Vars
# And also used them as container command args

#
# OBJECTIVE 02: ConfigMap Data as Container Env Variables with 'envFrom'
# Capture all the CM data items with one directive 
# Instead of selecting one by one like in the previous example with 'env'
# 

# Review the pod file
cat cm-consumer-pod-02.yaml

# Create a pod and read all the keys from specified config files 
# and capture them as env vars with envFrom directive
kubectl create -f cm-consumer-pod-02.yaml

# Make sure pod creation was successful
kubectl get pods

# Verify the ENV vars were set and written to pod logs
# A quick way to filter our lowecase CM KEY=VALUE pairs
kubectl logs cm-consumer-pod-02 | egrep '^[[:lower:]]+'

# Another way to look up env vars is by exec'ing to a running pod
kubectl exec cm-consumer-pod-02  -- env | egrep '^[[:lower:]]+'

# Successfully captured the CM data items as Env Vars with 'envFrom'

#
# OBJECTIVE 03: ConfigMap Data as Pod Volume
#

# Review the pod file
cat cm-consumer-pod-03.yaml

# Create a pod and mount each CM object as as a volume
kubectl create -f cm-consumer-pod-03.yaml

# Make sure pod creation was successful
kubectl get pods

# Verify the directory listings of ConfigMaps volumes
# The container command executed the list commands
kubectl logs cm-consumer-pod-03

# Let's pick any file and examine its content
kubectl exec  cm-consumer-pod-03 -- cat /etc/config/cm01/confdir && echo

# We could also establish an interactive exec session with the pod
# And have the freedom to do more inside the pod shell
kubectl exec -it cm-consumer-pod-03 -- sh       

# Successfully configured a ConfigMap as a Volume in the pod

#
# OBJECTIVE 04: ConfigMap Data a Specific Path in the Volume
#

# Review the pod file
cat cm-consumer-pod-04.yaml

# Create a pod and mount each CM object as as a volume 
# Provide a specific path name to the selected key
kubectl create -f cm-consumer-pod-04.yaml

# Verify the directory listing and content by using chosen path
# Refer to the pod file to see the container command and its arguments
kubectl logs cm-consumer-pod-04

# Successfully added ConfigMap data to a specific path in the Volume
