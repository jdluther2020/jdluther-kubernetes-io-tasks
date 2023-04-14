# Know Thy Nodes
# Script: https://github.com/jdluther2020/jdluther-kubernetes-io-tasks/blob/main/know-thy-nodes.sh

# 
# Author's NOTE
# 1. This file although can run as one whole script, some commands may error because of need for occassional manual edits. 
# 2. Make the right call after reviewing and following command specific instructions below.
# 3. Normally the commands are used to create one resource object at a time for the primary purpose of learning. 
#

#
# References:
# Kubernetes and Node Components (Architecture Overview)- https://kubernetes.io/docs/concepts/overview/components/
# Node Components and Details - https://kubernetes.io/docs/concepts/architecture/nodes/
# Node Object Manifest and Description Lookup for Troubleshooting Clusters - https://kubernetes.io/docs/tasks/debug/debug-cluster/
#

#
#  OBJECTIVE 1 - CHECK CLUSTER NODES
# - Get node listing and relevant informaiton about cluster nodes
#

# Check the presently registered nodes in a cluster, their status and each node's role (control plane vs. worker)
kubectl get nodes

# Get cluster nodes listing with additional information (e.g. node IPs)
kubectl get nodes -o wide

# List cluster nodes along with their labels
kubectl get nodes --show-labels

#
# OBJECTIVE 2 - EXAMINE A NODE MANIFEST
# - Obtain the manifest of a node object
#

# Get YAML manifest used by kubelet to create the node objects

# Get manifest of all nodes
kubectl get node -o yaml

# Get manifest of a single node
kubectl get node _NODENAME_  -o yaml

# Refer to https://kubernetes.io/docs/concepts/architecture/nodes/ for understanding of node manifest
# Another way to understand the node spec is by using 'kubectl explain'

# Understanding the node manifest components
kubectl explain node

# Understanding the different components of NodeStatus. Try out others like the example below:
kubectl explain node.status

#
# OBJECTIVE 3 - DESCRIBE A NODE'S STATUS DETAILS 
# - Describe node status to obtain information along with running pods and event history (more commonly used way than 'get node -o yaml')
#

# Get the live status of a node inclduing event history

# Of all cluster nodes
kubectl describe nodes

# Of a particular node
kubectl describe nodes _NODENAME_

#
# OBJECTIVE 4 - RUN COMMANDS AND CHECK COMPONENTS INSIDE A NODE
# - Login to a node and perform operational activities like a few examples below.
#

# Login into a node via 'docker exec' since in KIND, a container is the node. For dedicated virtual or physical servers use 'ssh'.
docker exec -it basic-multi-node-cluster-control-plane sh

# Inside the node, check on the commin Kubernetes components
which kubelet && kubelet --version

which crictl && crictl --version

# Check on running containers inside a node
crictl ps

#
# OBJECTIVE 5 - SCHEDULE PODS ON A SPECIFIC NODE
# - Assign a Pod to a particular node in the cluster
#

# 1. Select node for scheduling selected by labels attached to a node

# add a label to a node
kubectl label nodes _NODENAME_ disktype=ssd

# Filter node based on label
kubectl get node -l disktype=ssd

# Create a pod to schedule it on node with label 'disktype=ssd'
cat <<EOF | tee nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx-container
    image: nginx
  nodeSelector:
    disktype: ssd
EOF

# Create pod
kubectl apply -f nginx.yaml

# Confirm pod is scheduled on the node with label 'disktype=ssd'. Use earlier command 'kubectl get nodes --show-labels' to see labels anytime.
kubectl get pod -o wide

# 2. Select node for scheduling selected by the name of the node

# Create a pod to schedule it on node with by its name (provide the right node name from 'kubectl get nodes' output)
cat <<EOF | tee nginx2.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx2
spec:
  nodeName: basic-multi-node-cluster-worker2
  containers:
  - name: nginx-container
    image: nginx
EOF

# Create pod
kubectl apply -f nginx2.yaml

# Confirm pod is scheduled on the node
kubectl get pod -o wide

#
# OBJECTIVE 6 - SCHEDULE PODS ON ALL NODES (WORKER + CONTROL PLANE)
# - Create a deployment whose pods run on all nodes of the cluster
#

# Fist, check for the taints to see if any node including control plane that normally prevents pod scheduling
# We'll use the taint key to set the toleration next
kubectl describe nodes | grep -i -A 5 taints

# Create a deployment manifest with 3 replica pods to schedule one on each node (2 workers and 1 control plane)
cat <<EOF | tee deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx-deployment
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      containers:
      - image: nginx:latest
        name: nginx
        resources: {}
status: {}
EOF

# Create deployment
kubectl apply -f deploy.yaml

# Confirm each cluster node has one of the deployment pods
kubectl get pod -o wide

# Scale up the number of pods of the deployment from existing 3 to 9, and see how the scheduler distributes them among the 3 available nodes
kubectl scale deployment/nginx-deployment --replicas=6; kubectl rollout status deploy nginx-deployment

# END OF SCRIPT - know-thy-nodes.sh
