# ConfigMaps-Part 2: Consuming Configuration Data
# Purpose: Learning how to use data stored in ConfigMaps resources inside a pod and container
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
# OBJECTIVE-1: CONSUME CONFIGMAP DATA IN A POD WITH ENV
#

# Clone Repo. We'll practice the the OBJECTIVES inside the configmap creation code folder

CM_CDIR=configmaps-part-2-consuming-configuration-data \
REPO=jdluther-kubernetes-io-tasks && \
    git clone https://github.com/jdluther2020/$REPO.git && \
    cd $REPO/$CM_CDIR && \
    pwd

# First create two different ConfigMaps objects

# ConfigMap 1 manifest with name cm-01 from a file using --from-env-file option (multiple KEY=VALUE pairs)
kubectl create configmap cm-01 \
  --from-env-file=config-maps-data-dir/nginx-cm.params \
  --dry-run=client -o yaml | tee cm-01.yaml


# ConfigMap 2 manifest with name cm-02 from a file using --from-env-file option (multiple KEY=VALUE pairs)
kubectl create configmap cm-02 \
  --from-env-file=config-maps-data-dir/ports.params \
  --dry-run=client -o yaml | tee cm-02.yaml

# Create both CMs
kubectl create -f  cm-01.yaml && kubectl create -f  cm-02.yaml

# Describe CMs and confirm the data
kubectl describe cm cm-01 && kubectl describe cm cm-02

# Create a pod and read specific keys from different CM objects to ENV vars
kubectl create -f cm-consumer-pod-01.yaml

# Verify the ENV vars were set and written to pod logs
kubectl logs cm-consumer-pod-01 | grep CMENV_

#
# OBJECTIVE-2: CONSUME CONFIGMAP DATA IN A POD WITH ENVFROM
#

# Create a pod and read all the keys from specified config files and capture them as env vars
kubectl create -f cm-consumer-pod-02.yaml

# Verify the ENV vars were set and written to pod logs
kubectl logs cm-consumer-pod-02 | egrep '^[[:lower:]]+'


# <END OF SCRIPT>
