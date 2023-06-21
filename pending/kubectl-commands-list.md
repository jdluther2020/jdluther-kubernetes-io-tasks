# List of Commands to Review and Master
* JDL Compiled
```

#
# 1. shows kubelet process on any cluster node
#

ps aux | grep kubelet
{
cloud_u+    3891  0.0  0.0   8168  2448 pts/0    S+   04:04   0:00 grep --color=auto kubelet
}

#
# 2. See which components are controlled via systemd looking at /etc/systemd/system directory (on Control Plane node)
#

find /etc/systemd/system/ | grep kube
{
/etc/systemd/system/kubelet.service.d
/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
/etc/systemd/system/multi-user.target.wants/kubelet.service
}

#
# 3. etcd is not controlled
#

find /etc/systemd/system/ | grep etcd
{
}


#
# 4. Static pods are found in the /etc/kubernetes/manifests/ dir. Match them up with pods running under namespace kube-system
#

find /etc/kubernetes/manifests/
{
/etc/kubernetes/manifests/
/etc/kubernetes/manifests/kube-apiserver.yaml
/etc/kubernetes/manifests/etcd.yaml
/etc/kubernetes/manifests/kube-scheduler.yaml
/etc/kubernetes/manifests/kube-controller-manager.yaml
}



#
# 5. Find all pods running in kube-system namespace
#

kubectl -n kube-system get pods


#
# 6. See any of the pods are managed by DaemonSets
#

kubectl -n kube-system get ds


#
# 7. See any of the pods are managed by deployment replicasets
#

kubectl -n kube-system get deployments


#
# 8. See any of the pods are managed by sts (shouldn't be any)
#

kubectl -n kube-system get sts


#
# 9. What is the Service CIDR?
#

ssh _CONTROL_PLANE_NODE_

cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep range
{
    - --service-cluster-ip-range=10.96.0.0/12
}


#
# 10. Which Networking (or CNI Plugin) is configured and where is its config file?
#

ssh _CLUSTER_PLANE_NODE_
find /etc/cni/net.d/
{
/etc/cni/net.d/
/etc/cni/net.d/10-weave.conflist
}

cat /etc/cni/net.d/10-weave.conflist
{
    "cniVersion": "0.3.0",
    "name": "weave",
}


#
# 11. Find the node of a  running pod 
#

k -n project-tiger get pod tigers-reunite -o jsonpath="{.spec.nodeName}"
# Or
k get pods -A -o wide
# Or
k describe pod PODNAME -n NAMESPACE 



#
# 12. Find the ID and other runtime info of the container of a pod
#

# First ssh into the node the pod is running on
ssh _NODE_OF_POD_
# See all containers, grep on pod name
crictl ps | grep _POD_NAME_
crictl inspect _CONTAINER_ID_
# Find container logs
crictl logs
crictl logs _CONTAINER_ID_



#
# 13. Find out api resources (all, namespaced)
#

k api-resources
k api-resources --namespaced




#
# 14. Look for kubelet log 
#

ssh _NODE_
journalctl -u kubelet




#
# 15. kubelet status, start, stop
#

service kubelet status
service kubelet start
service kubelet stop



#
# 16. Create kubeadm join command for nodes
#

kubeadm token create --print-join-command



#
# 17. Find out how long certificates are valid
#

ssh _CONTROL_PLANE_NODE_

# Find out certificates
ls -l /etc/kubernetes/pki
ls -l /var/lib/kubelet/pki

# Command to get cert or key info
openssl x509  -noout -text -in _CRT_FILE_(e.g. /etc/kubernetes/pki/apiserver.crt)_
openssl x509  -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem



#
# 18. Calling API server directly
#

kubectl exec -it POD_NAME -n NAMESPACE_NAME -- sh

curl https://kubernetes.default

# -k to ignore insecure as allowed in ticket description
curl -k https://kubernetes.default 

# This will show Forbidden 403
curl -k https://kubernetes.default/api/v1/secrets 

# Obtain bearer token
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

# Without encryption
curl -k https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer ${TOKEN}"

# With encryption
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
curl --cacert ${CACERT} https://kubernetes.default/api/v1/secrets -H "Authorization: Bearer ${TOKEN}"



#
# 19. Sort pods by age, by uid
#

# HINT: describe a pod to pick sort by field
kubectl get pods -A --sort-by=.metadata.creationTimestamp
kubectl get pods -A --sort-by=.metadata.uid


#
# 20. Node and Pod Resource Usage
#

# show Nodes resource usage
# show Pods and their containers resource usage
# Hint: k top --help
k top nodes
k top pods --containers=true -A


#
# 21.  Get latest events in the whole cluster, ordered by time
#

# Get event object info
k describe event  | vi -

# Get events sorted by age
k get events -A --sort-by=.metadata.creationTimestamp





#
# 22. kubelet cert info
#


# Find cert info in /etc/kubernetes/kubelet.conf
client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem
client-key: /var/lib/kubelet/pki/kubelet-client-current.pem

# Get cert info with 'openssl' command
openssl x509  -noout -text -in  _CERT_FILE_
sudo openssl x509  -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem
sudo openssl x509  -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem




#
# 23. Get all cluster resources
#
kubectl get all


#
# 24. Transient busybox pod for testing a service 
#

kubectl run bbox --image=busybox --restart-Never -it --rm -- /bin/sh -c "wget -q0- http://SVC-IP"

#
# Making use of jsonpath
#

POD_NAME=`kubectl get pods -o jsonpath='{.items[0].metadata.name}'`
echo $POD_NAME
kubectl describe pod $POD_NAME

FRONTEND_SERVICE_IP=`kubectl get service/frontend -o jsonpath='{.spec.clusterIP}'`
echo $FRONTEND_SERVICE_IP
curl -i http://$FRONTEND_SERVICE_IP

FRONTEND_POD_NAME=`kubectl get pods --no-headers -o custom-columns=":metadata.name"`
echo $FRONTEND_POD_NAME
kubectl exec -it $FRONTEND_POD_NAME -c nginx -- ls -la /var/log/nginx/






```
