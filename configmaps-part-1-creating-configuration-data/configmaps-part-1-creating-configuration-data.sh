# ConfigMaps-Part 1: Creating Configuration Data
# Purpose: Learning how to use ConfigMap resource to create configuration data in multiple ways
# Script: https://github.com/jdluther2020/jdluther-kubernetes-io-tasks/tree/main/managing-configuration-data-with-configmaps.sh

# 
# Author's NOTE
# - This file although can run as one whole script, it's normally used to create one resource object at a time.
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
# OBJECTIVE-1: CREATE CONFIGMAPS DECLARATIVE MANIFESTS WITH IMPERATIVE COMMANDS
#

# ConfigMaps can be created from directories, files, or literal values. 
# 'kubectl --help' is the best and the most reliable way to find out.
# Look at the examples on the top covering all options
# Once you have the manifest, modify it if and as needed

kubectl create cm --help

#
# OBJECTIVE-2: CREATE CONFIGMAPS FROM LITERAL KEY=VALUE PAIRS
#

# Create a ConfigMap manifest with three data KEY=VAL pairs
kubectl create configmap nginx-cm  \
  --from-literal=rootdir=/usr/share/nginx/html \
  --from-literal=confdir=/etc/nginx/conf \
  --from-literal=indexfile=index.html \
  --dry-run=client -o yaml | tee nginx-cm.yaml

# Create the ConfigMap by applying the manifest file
kubectl create -f nginx-cm.yaml

# Verify ConfigMap nginx-cm was created
kubectl get -f nginx-cm.yaml

# Validate the key=value pair of nginx-cm CM
kubectl describe configmaps nginx-cm

#
# OBJECTIVE-3: CREATE CONFIGMAPS FROM FILES
#

# Reproduce the ConfigMap as created from literal key=value pairs
kubectl create configmap app-cm-01 --from-file=config-maps-data-dir/nginx-cm.params

