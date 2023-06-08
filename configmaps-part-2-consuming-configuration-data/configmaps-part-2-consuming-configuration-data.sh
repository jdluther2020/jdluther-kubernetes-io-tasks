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
# OBJECTIVE-1: CONSUME CONFIGMAP DATA IN A POD VIA ENVIRONMENT VARIABLES
#

# Clone Repo. We'll practice the the OBJECTIVES inside the configmap creation code folder

CM_CDIR=configmaps-part-2-creating-configuration-data \
REPO=jdluther-kubernetes-io-tasks && \
    git clone https://github.com/jdluther2020/$REPO.git && \
    cd $REPO/$CM_CDIR
    pwd

# First create two different ConfigMaps objects

# ConfigMap 1 with name cm-01 from a file using --from-env-file option (multiple KEY=VALUE pairs)
kubectl create configmap cm-01 \
  --from-env-file=config-maps-data-dir/nginx-cm.params \
  --dry-run=client -o yaml | tee cm-01.yaml


# <END OF SCRIPT>
