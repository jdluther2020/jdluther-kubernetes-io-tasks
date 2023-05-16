# Exposing a Stateless Application via ClusterIP Service
# Purpose: Learning how to expose a statless application Deployment via a ClusterIP Service
# Script: https://github.com/jdluther2020/jdluther-kubernetes-io-tasks/tree/main/exposing-a-stateless-app-via-clusterip-service/exposing-a-stateless-app-via-clusterip-service.sh

# 
# Author's NOTE
# - This file although can run as one whole script, it's normally used to create one resource object at a time.
#

#
# References:
# - https://kubernetes.io/docs/concepts/services-networking/service/
# - https://kubernetes.io/docs/tutorials/services/connect-applications-service/
#

#
# OBJECTIVE 1 - SERVICE PRIMARY PURPOSE DEMONSTRATION
#

# Create a new namespace to host the stateless application
kubectl create namespace mkdemo

# Create the stateless application, a simple nginx web server app
kubectl apply -f stateless-app-nginx.yaml

# Create a busybox client application in the default namespace
kubectl apply -f client.yaml

# Let's check all the pods are up and running
kubectl get pods -o wide && kubectl get pods -n mkdemo -o wide

# Obtain the pod IPs of the deployment
pod_ips=$(kubectl get pods -o=jsonpath="{.items[*]['status.podIP']}" -n mkdemo)

# Ping each stateless app pods
for pod_ip in $pod_ips; do kubectl exec client-pod -- curl -s $pod_ip; done

# Create service
kubectl apply -f clusterip-service.yaml

# Get the listing of client pod, application pods and service
kubectl get pods -o wide && kubectl get pods,svc -n mkdemo -o wide

# Get service IP
service_ip=$(kubectl get service sa-service -o=jsonpath="{.spec.clusterIP}" -n mkdemo)

# Test service using service IP
kubectl exec client-pod -- curl -s $service_ip

# Test service using the qualified service name
kubectl exec client-pod -- curl -s sa-service.mkdemo

# Describe service to see endpoints, pointing to all the pods of the deployment
kubectl describe svc sa-service -n mkdemo

# List the service endpoints
for ep_ip in $(kubectl get endpoints sa-service -o=jsonpath="{.subsets[*].addresses[*].ip}" -n mkdemo); do echo "Endpoint: $ep_ip";done


#
# OBJECTIVE 2 - UNINTERRUPTED SERVICE WHILE DEPLOYMENT PODS CHANGE
#

# Let's try increasing the number of pods by doubling the replicas from 3 to 6
kubectl scale deploy sa-nginx --replicas=6 -n mkdemo

# Same service IP, a lot more endpoints
kubectl describe svc sa-service -n mkdemo
for ep_ip in $(kubectl get endpoints sa-service -o=jsonpath="{.subsets[*].addresses[*].ip}" -n mkdemo); do echo "Endpoint: $ep_ip";done

# No pods in the deployment, no endpoints
kubectl scale deploy sa-nginx --replicas=0 -n mkdemo && kubectl describe svc sa-service -n mkdemo
for ep_ip in $(kubectl get endpoints sa-service -o=jsonpath="{.subsets[*].addresses[*].ip}" -n mkdemo); do echo "Endpoint: $ep_ip";done

# New pods in the deployment, new endpoints. Wait a few moment for the scaling operation to complete before listing
kubectl scale deploy sa-nginx --replicas=3 -n mkdemo && kubectl describe svc sa-service -n mkdemo
for ep_ip in $(kubectl get endpoints sa-service -o=jsonpath="{.subsets[*].addresses[*].ip}" -n mkdemo); do echo "Endpoint: $ep_ip";done

# Test service using the qualified service name
kubectl exec client-pod -- curl -s sa-service.mkdemo

#
# OBJECTIVE 3 - UNINTERRUPTED CLIENT WHILE SERVICE IP CHANGES
#

# Delete service
kubectl delete -f clusterip-service.yaml

# Recreate service
kubectl create -f clusterip-service.yaml

# A new service IP to deal with for the same stateless application
kubectl describe svc sa-service -n mkdemo
service_ip=$(kubectl get service sa-service -o=jsonpath="{.spec.clusterIP}" -n mkdemo)
echo "New service IP: $service_ip"

# Test service using the qualified service name, IP changed but the same command to access the stateless app continues to work uninterrupted
kubectl exec client-pod -- curl -s sa-service.mkdemo

# <END OF SCRIPT>
