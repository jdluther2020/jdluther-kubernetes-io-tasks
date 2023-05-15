# DaemonSets Demonstration
# Purpose: Learning to write and deploy DaemonSet workloads in a Kubernetes cluster.
# Script: https://github.com/jdluther2020/jdluther-kubernetes-io-tasks/tree/main/daemonsets-demonstration/daemonsets-demonstration.sh

# 
# Author's NOTE
# - This file although can run as one whole script, it's normally used to create one resource object at a time.
#

#
# References:
# - https://kubernetes.io/docs/concepts/workloads/
# - https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
# - https://kubernetes.io/docs/tasks/manage-daemon/rollback-daemon-set/
# - https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/
# - https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/daemon-set-v1/
#

#
# OBJECTIVE 1 - CREATE A FILE CLEANUP UTILITY DAEMONSET RUNNING ON ALL NODES
#

# Create a deployment to run an example web application
# This application writes a number of files under hostPath /var/web/data
kubectl create -f web-app-all-nodes.yaml

# Make sure the web app pods are running
kubectl get pods

# Check the data files written by the deployed app (use appropriate pod name from kubectl get pods command output)
kubectl exec -it web-app-68c7466bb5-5nsct -- ls -l /data

# Write a daemon script using Daemonset resource to clean up all the data files except the latest 5 files
kubectl create -f file-cleaner-all-nodes.yaml

# Make sure the daemonset pods are running, one in each node
kubectl get pods -o wide

# Verify daemon script is doing its job by looking at the log
# The daemon script cleans up the files once a minute, created by the web every 10 seconds, and lists the remaining files which end up in the pod's log
kubectl logs file-cleaner-djnmn

#
#  OBJECTIVE 2 - PERFORM A ROLLING UPDATE ON A DAEMONSET
#

# Confirm the current Daemonset update strategy
kubectl get ds/file-cleaner -o go-template='{{.spec.updateStrategy.type}}{{"\n"}}'

# Any updates to the .spec.template will trigger a rolling update (e.g. container image, resources etc.)
# Updates can take place by editing the Daemonset object live with edit command or by changing/re-applying the manifest or with imperative modification

# Let's change the image and see the rolling update process
kubectl set image ds/file-cleaner file-cleaner-container=busybox:latest

# Watch the rolling update rollout status of the latest DaemonSet
kubectl rollout status ds/file-cleaner


#
#  OBJECTIVE 3 - PERFORM A ROLLBACK ON A DAEMONSET
#

# Start by listing all revisions of a DaemonSet update
kubectl rollout history ds/file-cleaner

# Check the details of a specific revision
kubectl rollout history  ds/file-cleaner --revision=1

# Roll back to a specific revision
kubectl rollout undo ds/file-cleaner --to-revision=1

# <END OF SCRIPT>
