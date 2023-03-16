# Know Thy Cluster
# A set of initial kubectl commands to explore and test the cluster.

# 
# Author's NOTE
# - This file although can run as one whole script, it's normally used to create one resource object at a time for the purpose of learning.
#

#
# References:
# - https://kubernetes.io/docs/concepts/containers/
# - https://kubernetes.io/docs/concepts/workloads/pods/
#

#
# EXAMPLE - Create Pod Manifest with Container Spec
# - Let's create the ubiquitous nginx pod from scratch
# 

# We need 'kubectl run' command to create our pod. Let's see how with --help option.
kubectl run --help

# Create the pod spec with nginx image
kubectl run nginx-pod --image=nginx --dry-run=client -o yaml | tee nginx-pod.yaml

# Create the pod
kubectl apply -f nginx-pod.yaml

# Check pod is running and it's status
kubectl get pods

# Or to be more specific, using the manifest file works as well.
kubectl get  -f nginx-pod.yaml
