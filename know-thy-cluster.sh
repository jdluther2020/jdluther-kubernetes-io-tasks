# Know Thy Cluster
# A set of initial kubectl commands to explore and test the cluster.

# 
# Author's NOTE
# - This file although can run as one whole script, it's normally used to create one resource object at a time.
#

#
# References:
# - https://kubernetes.io/docs/reference/kubectl/
# - https://kubernetes.io/docs/reference/using-api/
#

#
# Context: 
#   Let's say you got access to an environment with a ready and working Kuberneter cluster. 
#   How would you situate yourself right away, take control of the cluster and prepare yourself to begin working on it?
#

# Always start with kubectl help, your best friend
kubectl help

# Find out Kubernetes version
kubectl version --output=yaml

# Find out Kubernetes version (short version)
kubectl version --short

# Check the cluster nodes
kubectl get nodes

# Get a little bit more information, go wide!
kubectl get nodes -o wide

# Check all the existing namespaces
kubectl get namespaces

# Check pods across all namespaces
kubectl get pods -A

# Find out what cluster you're operating on
kubectl config get-contexts

# Find out what's the current cluster context
kubectl config current-context

# View all the contexts, their full config
kubectl config view

# View the current context, its full config
kubectl config view --minify

# Know the location of the default config file 
ls -al $HOME/.kube/config

# Make sure there is no KUBECONFIG environment variable set, because that overrides the default ${HOME}/.kube/config location
# 'kubectl config --help' provides more details
env | grep KUBECONFIG

# Check to make sure this config file is same as the current context
TMPFILE=$(mktemp) && kubectl config view --raw > $TMPFILE && diff $TMPFILE ~/.kube/config && rm $TMPFILE

# Let's create a quick pod to test out the cluster
# Do a dry run to generate the pod manifest
kubectl run a-pod --image=nginx --dry-run=client -o yaml

# Looks good, let's create the pod in the default namespace
kubectl run a-pod --image=nginx

# Verify pod's status
kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP           NODE                              NOMINATED NODE   READINESS GATES
a-pod   1/1     Running   0          41s   10.244.1.3   basic-multi-node-cluster-worker   <none>           <none>

# That's a wrap!
