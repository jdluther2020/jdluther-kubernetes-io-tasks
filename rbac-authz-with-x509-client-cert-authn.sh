# RBAC Authorization with X509 Client Cert Authentication
* https://kubernetes.io/docs/reference/access-authn-authz/rbac/
* https://kubernetes.io/docs/reference/access-authn-authz/authentication/
```

# Create namespace
kubectl create namespace rbac-test

# Create a pod
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

# Create the role
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

# Bind the role to user
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

# Create user
# https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/
# https://kubernetes.io/docs/reference/access-authn-authz/authentication/#x509-client-certs
openssl genrsa -out /tmp/rbac-testuser.key 2048
openssl req -new -key /tmp/rbac-testuser.key -out /tmp/rbac-testuser.csr -subj "/CN=rbac-testuser"

docker exec -it 943bb9ebb90a cat /etc/kubernetes/pki/ca.crt > /tmp/ca.crt
docker exec -it 943bb9ebb90a cat /etc/kubernetes/pki/ca.key > /tmp/ca.key
openssl x509 -req -in /tmp/rbac-testuser.csr -CA /tmp/ca.crt -CAkey /tmp/ca.key -CAcreateserial -out /tmp/rbac-testuser.crt -days 500
kubectl config set-credentials rbac-testuser --client-certificate=/tmp/rbac-testuser.crt  --client-key=/tmp/rbac-testuser.key
kubectl config set-context rbac-testuser-context --cluster=kind-basic-multi-node-cluster --user=rbac-testuser

kubectl config get-contexts
kubectl config use-context rbac-testuser-context
kubectl config get-contexts
```
