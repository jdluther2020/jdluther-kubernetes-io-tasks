# Containers and Pods
# Getting comfortable writing containers and pods, the fundamental application building blocks running in a Kubernetes cluster.

# 
# Author's NOTE
# - This file although can run as one whole script, it's normally used to create one resource object at a time for the purpose of learning.
#

#
# References:
# - https://kubernetes.io/docs/concepts/containers/
# - https://kubernetes.io/docs/concepts/workloads/pods/
# - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#-strong-workloads-apis-strong-
#

#
# EXAMPLE 1 - Create Pod Manifest with Container Spec
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

#
# EXAMPLE 2 - Executing Command Inside a Pod Container
# - Another ubiquitous BusyBox pod for command demonstration
# 

# Create the pod spec with busybox image
kubectl run busybox-pod --image=busybox --dry-run=client -o yaml | tee busybox-pod.yaml

# Modify the pod to include a command to run inside the conainer
# vi busybox-pod.yaml
# Add the following line below 'name: busybox-pod' line
# command: ['sh', '-c', 'echo "Hello, Kubernetes from busybox pod!" && sleep 3600']

# Create the pod
kubectl apply -f busybox-pod.yaml

# Check pod is running successfully
kubectl get  -f busybox-pod.yaml

# Confirm command inside the busybox container ran successfully
kubectl logs busybox-pod
{
Hello, Kubernetes from busybox pod!
}

#
# EXAMPLE 3 - Going Inside a Pod Container
# - The great Alpine Linux image, a more powerful alternative to BusyBox
# 

# Create the pod spec with alpine image
kubectl run alpine-pod --image=alpine --dry-run=client -o yaml | tee alpine-pod.yaml

# Modify the pod to include a sleep 1 day command to run inside the container
# vi alpine-pod.yaml
# Add the following line below 'name: alpine-pod' line
# command: ['sh', '-c', 'sleep 1d']

# Create the pod
kubectl apply -f alpine-pod.yaml

# Check pod is running successfully
kubectl get  -f alpine-pod.yaml

# Let's go inside the container by getting a shell to the running container
# The '/ #' prompt confirms we're inside the container and in business. 
# We can run commands in the container shell until typing 'exit' to quit it.
kubectl exec -it alpine-pod -- /bin/sh

# It looks like we don't have curl pre-installed in this image
# NOTE: Until we exit the container, the following commands are received by the container shell
# which curl

# Let's install curl
# apk --update add curl

# Look up curl again
# which curl

# Let's curl our previously created nginx pod
# First we have to get the IP of the nginx pod
# And in order to run kubectl, we have to exit the container

# Exit container
# exit

# Back in the EC2 terminal shell, issue kubectl command to get the list of running pods and their IPs
kubectl get pods -o wide

# Let's go inside the container again
kubectl exec -it alpine-pod -- /bin/sh

# Issue curl command to nginx-pod IP
# curl 10.244.1.3

# Exit container
# exit

# Bonus
# We can also issue the curl command, having installed it, from outside the container
kubectl exec alpine-pod -- curl -s 10.244.1.3

#
# EXAMPLE 4 - Describe a running pod
# - Peek inside the nginx pod
#

# First let's get a list of running pods in wide format
kubectl get pods -o wide

# Get detailed information about the pod by describing it
kubectl describe pod nginx-pod

# Bonus
# Get even more system information about the pod using 'get pod' with '-o yaml' option
kubectl get pod nginx-pod -o yaml
