# Pods, Deployments, and ReplicaSets
# Script: pods-and-deployment.sh

# 
# Author's NOTE
# - This file although can run as one whole script, some commands will error because sometimes manual edits are required to complete auto-generated pod manifests. Please see command specific instructions below.
# - Normally the commands are used to create one resource object at a time for the purpose of learning. 
#

#
# References:
# - https://kubernetes.io/docs/concepts/workloads/pods/
# - https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
# - https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
#

#
# DEPLOYMENT USE CASE 1 - CREATE A DEPLOYMENT
# - Create a brand new Deployment
#

# Create a deployment 'nginx-deployment' with 3 pod replicas with nginx:1.14.2 containers
# We want to practice creating deployments imperatively by reading a requirement like above.

# Create deployment manifest
kubectl create deployment nginx-deployment --image=nginx:1.14.2 --replicas=3 --dry-run=client -o yaml | tee deploy.yaml

# Create deployment
kubectl apply -f deploy.yaml

# Verify the Deployment was created
kubectl get deployment/nginx-deployment

# Check the deployment rollout status. Keep this command ready, we're going to use it again soon
kubectl rollout status deploy nginx-deployment

# Since a deployment manages ReplicaSets, let's verify that took place 
kubectl get rs -l app=nginx-deployment

# Handy command to see the labels of the pods the deployment auto-generated to manage the pods
kubectl get pods --show-labels=true

# Finally, look at the pods of the deployments. All good if they are up and running.
kubectl get pods -l app=nginx-deployment

#
# DEPLOYMENT USE CASE 2 - UPDATING A DEPLOYMENT WITH ROLLING UPDATE STRATEGY
# - Update a Deployment to trigger a rollout by changing the container image
# - Note that a Deployment's rollout is triggered if and only if the Deployment's Pod template is changed (e.g. label or container image). Other updates like scaling the Deployment, do not trigger a rollout.
# 

# Update the pod's container image to nginx=nginx:1.23.4
# Issue the rollout status check command immediately to see status
kubectl set image deploy nginx-deployment nginx=nginx:1.23.4 ; kubectl rollout status deploy nginx-deployment

# View the Deployment post-update
kubectl get deployments nginx-deployment

# Verify old ReplicaSets were scaled down while new ReplicaSets scaled up
kubectl get rs -l app=nginx-deployment

# Make sure the new pods are up and running
kubectl get pods -l app=nginx-deployment

# Finally get more details about the updated deployment
# Inspect the events to see the rolling update strategy
kubectl describe deployments nginx-deployment

#
# DEPLOYMENT USE CASE 3 - ROLLING BACK A DEPLOYMENT
# - Checking rollout history of a deployment and rolling back to a previous revision
# 

# Let's intentionally break the updating of the Deployment by putting a non-existent image name (e.g. nginx:bigfoot)
kubectl set image deployment/nginx-deployment nginx=nginx:bigfoot

# Check rollout status which is expected to hang
kubectl rollout status deploy nginx-deployment

# Control-C to kill and then check the ReplicaSets (the new one will never go to ready state)
kubectl get rs -l app=nginx-deployment

# Examine the pod to see its status and get a hint of the problem it's encountering
kubectl get pods -l app=nginx-deployment

# Describe the deployment to examine the Replicas status
kubectl describe deployment nginx-deployment

# Time to rollback since the issue is irreversible
# Start by checking the revisions of this Deployment

kubectl rollout history deployment/nginx-deployment

# Get details of the bad revision
kubectl rollout history deployment/nginx-deployment --revision=3

# Option 1: Undo the rollout to go back to the previous version
kubectl rollout undo deployment/nginx-deployment

# Option 2: Roll back to a previous version of choice
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# Check and confirm the rollback was successful and the Deployment is running as expected
kubectl get deployment nginx-deployment

# Describe the deployment to examine the Replicas status (desired, total, available should all match)
kubectl describe deployment nginx-deployment


#
# DEPLOYMENT USE CASE 4 - SCALING A DEPLOYMENT
# - Scale up and down the ReplicaSets of a deployment
#

# Scale up the number of pods of the deployment from existing 3 to 6
kubectl scale deployment/nginx-deployment --replicas=6; kubectl rollout status deploy nginx-deployment

# Confirm all the replicas are up by issuing any of the commands below
kubectl get rs -l app=nginx-deployment
kubectl get deployment nginx-deployment
kubectl get pods -l app=nginx-deployment

# Scale down the number of pods of the deployment from existing 6 to only 1
kubectl scale deployment/nginx-deployment --replicas=1; kubectl rollout status deploy nginx-deployment

# Confirm only 1 pod is running
kubectl get pods -l app=nginx-deployment

#
# BONUS - DEPLOYMENT EDIT COMMAND SUMMARY
# - 3 ways to edit a deployment
#

# 1. Edit a Deployment with imperative command
# Change container image (spec.template.spec.containers.image)
kubectl set image deploy nginx-deployment nginx=nginx:1.16.1 ; kubectl rollout status deploy nginx-deployment

# Change replica counts (.spec.replicas)
kubectl scale deployment/nginx-deployment --replicas=2; kubectl rollout status deploy nginx-deployment

# 2. Edit a deployment by changing its live configuration spec (spec.template.spec.containers.image and .spec.replicas)
kubectl edit deployment nginx-deployment

# 3. Edit a deployment by changing the original manifest and reapplying it
kubectl apply -f deploy.yaml

# END OF SCRIPT - pods-and-deployment.sh
