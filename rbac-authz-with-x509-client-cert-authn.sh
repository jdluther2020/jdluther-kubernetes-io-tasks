# RBAC Authorization with X509 Client Cert Authentication

# 
# Author's NOTE
# - This file although can run as one whole script, it's normally used to create one resource object at a time.
#

## References
# - https://kubernetes.io/docs/reference/access-authn-authz/rbac/
# - https://kubernetes.io/docs/reference/access-authn-authz/authentication/
# - https://kubernetes.io/docs/tasks/administer-cluster/certificates/

# Create a new namespace
kubectl create namespace rbac-test

# Create a single test pod
cat <<EOF | tee test-pod-not-through-deployment.yaml
apiVersion: v1
kind: Pod
metadata:
  namespace: rbac-test
  name: test-pod-not-through-deployment
spec:
  restartPolicy: OnFailure
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
EOF
kubectl apply -f test-pod-not-through-deployment.yaml

# Create a role with read-only access to the pod in a specified namespace
cat <<EOF | tee role-pod-access-read-only.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: rbac-test
  name: role-pod-access-read-only
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "watch", "list"]
EOF
kubectl apply -f role-pod-access-read-only.yaml

# Bind the role to a Kubernetes "normal user" to be created later.
cat <<EOF | tee role-binding-pod-access-read-only.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: rbac-test
  name: role-binding-pod-access-read-only
subjects:
  - kind: User
    name: rbac-testuser
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: role-pod-access-read-only
  apiGroup: rbac.authorization.k8s.io
EOF
kubectl apply -f role-binding-pod-access-read-only.yaml

# Create a Kubernetes "normal user" with X509 Client Certs authentication process.
openssl genrsa -out /tmp/rbac-testuser.key 2048
openssl req -new -key /tmp/rbac-testuser.key -out /tmp/rbac-testuser.csr -subj "/CN=rbac-testuser"

# Obtain necessary cert files of the KIND cluster

CP_CID=$(docker ps | grep control-plane | cut -d' ' -f1) && echo $CP_CID
docker exec -it $CP_CID cat /etc/kubernetes/pki/ca.crt > /tmp/ca.crt
docker exec -it $CP_CID cat /etc/kubernetes/pki/ca.key > /tmp/ca.key

# According to the ca.key generate a ca.crt
openssl x509 -req -in /tmp/rbac-testuser.csr -CA /tmp/ca.crt -CAkey /tmp/ca.key -CAcreateserial -out /tmp/rbac-testuser.crt

# Set the cluster config file with the new user context
kubectl config set-credentials rbac-testuser --client-certificate=/tmp/rbac-testuser.crt  --client-key=/tmp/rbac-testuser.key
kubectl config set-context rbac-testuser-context --cluster=kind-basic-multi-node-cluster --user=rbac-testuser

# Change context to the test user
kubectl config get-contexts
kubectl config use-context rbac-testuser-context

# Confirm context is set
kubectl config get-contexts

# Test pod access

# This will be forbidden (no access to default namespace)
kubectl get pods

# This will succeed due to RBAC setting
kubectl get pods -n rbac-test

# Change context back cluster admin
kubectl config use-context kind-basic-multi-node-cluster

# Cleanup 
kubectl delete -f test-pod-not-through-deployment.yaml
kubectl delete -f role-pod-access-read-only.yaml
kubectl delete -f role-binding-pod-access-read-only.yaml

# End of script
