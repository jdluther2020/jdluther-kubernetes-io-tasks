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

# 1. Always start with kubectl help, your best friend
kubectl help

# 2. Find out Kubernetes version
kubectl version --output=yaml

# 3. Find out Kubernetes version (short version)
kubectl version --short

# 4. Check the cluster nodes
kubectl get nodes

# 5. Get a little bit more information, go wide!
kubectl get nodes -o wide

# 6. Check all the existing namespaces
kubectl get namespaces

# 7. Check pods across all namespaces
kubectl get pods -A

# 8. Find out what cluster you're operating on
kubectl config get-contexts

# 9. Find out what's the current cluster context
kubectl config current-context

# 10. View all the contexts, their full config
kubectl config view

# 11. View the current context, its full config
kubectl config view --minify

# 12. Know the location of the default config file
ls -al $HOME/.kube/config

# 13. Make sure there is no KUBECONFIG environment variable set, because that overrides the default ${HOME}/.kube/config location
# 'kubectl config --help' provides more details
env | grep KUBECONFIG

# 14. Check to make sure this config file is same as the current context
TMPFILE=$(mktemp) && kubectl config view --raw > $TMPFILE && diff $TMPFILE ~/.kube/config && rm $TMPFILE

# 15. Let's create a quick pod to test out the cluster
# Do a dry run to generate the pod manifest
kubectl run a-pod --image=nginx --dry-run=client -o yaml

# 16. Looks good, let's create the pod in the default namespace
kubectl run a-pod --image=nginx

# 17. Verify pod's status
kubectl get pods -o wide

# 18. Delete the pod if re-running the script
#kubectl delete pod a-pod

# That's a wrap!
