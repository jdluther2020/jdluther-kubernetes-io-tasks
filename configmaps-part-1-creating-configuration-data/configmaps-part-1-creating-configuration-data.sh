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
kubectl create configmap app-cm-01  \
  --from-literal=rootdir=/usr/share/nginx/html \
  --from-literal=confdir=/etc/nginx/conf \
  --from-literal=indexfile=index.html \
  --dry-run=client -o yaml | tee app-cm-01.yaml

# Create the ConfigMap by applying the manifest file
kubectl create -f app-cm-01.yaml

# Verify ConfigMap app-cm was created
kubectl get -f app-cm-01.yaml

# Validate the key=value pairs of nginx-cm CM object
kubectl describe configmaps app-cm-01

# Create another ConfigMap manifest with six data KEY=VAL pairs
kubectl create configmap app-cm-02  \
  --from-literal=rootdir=/usr/share/nginx/html \
  --from-literal=confdir=/etc/nginx/conf \
  --from-literal=indexfile=index.html \
  --from-literal=container_port=80 \
  --from-literal=service_port=8080 \
  --from-literal=node_port=30080 \
  --dry-run=client -o yaml | tee app-cm-02.yaml

# Create ConfigMap app-cm-02
kubectl create -f app-cm-02.yaml

# Verify app-cm-02 data
kubectl describe configmaps app-cm-02

#
# OBJECTIVE-3: CREATE CONFIGMAPS FROM FILES 
#

# Reproduce the ConfigMap app-cm-01 as created from literal key=value pairs with --from-env-file option
kubectl create configmap app-cm-03 \
  --from-env-file=config-maps-data-dir/nginx-cm.params \
  --dry-run=client -o yaml | tee app-cm-03.yaml

# Check that CM manifests app-cm-01.yaml and app-cm-03.yaml are identical except the names
diff app-cm-03.yaml app-cm-01.yaml

# Create and verify the same after creating the CM object app-cm-03
kubectl create -f app-cm-03.yaml
kubectl describe configmaps app-cm-03

# Reproduce app-cm-02 as created from literal key=value pairs with multiple --from-env-file option
kubectl create configmap app-cm-04 \
  --from-env-file=config-maps-data-dir/nginx-cm.params \
  --from-env-file=config-maps-data-dir/ports.params \
  --dry-run=client -o yaml | tee app-cm-04.yaml

# Check that CM manifests app-cm-02.yaml and app-cm-04.yaml are identical except the names
diff app-cm-04.yaml app-cm-02.yaml

# Create and verify the same after creating the CM object app-cm-04
kubectl create -f app-cm-04.yaml
kubectl describe configmaps app-cm-04

#
# OBJECTIVE-4: CREATE CONFIGMAPS FROM FILES
#

# Create ConfigMap from a file with --from-file option
# Unlike the literal KEY=VALUE pairs, this options creates one multi-line data KEY with the filename
# And bundles the application configuration KEY=VALUE pairs under the multi-line filename data KEY
kubectl create configmap app-cm-05 \
  --from-file=config-maps-data-dir/nginx-cm.params \
  --dry-run=client -o yaml | tee app-cm-05.yaml

# Create and verify the same after creating the CM object app-cm-05
kubectl create -f app-cm-05.yaml
kubectl describe configmaps app-cm-05

# Create ConfigMap from multiple files with multiple --from-file params
kubectl create configmap app-cm-06 \
  --from-env-file=config-maps-data-dir/nginx-cm.params \
  --from-env-file=config-maps-data-dir/ports.params \
  --dry-run=client -o yaml | tee app-cm-06.yaml

# Create and verify the same after creating the CM object app-cm-04
kubectl create -f app-cm-06.yaml
kubectl describe configmaps app-cm-06
