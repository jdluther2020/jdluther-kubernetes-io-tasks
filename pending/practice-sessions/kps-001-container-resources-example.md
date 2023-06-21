# kps-001-container-resources-example.sh

## Ref
* https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

## Practice Objective

### ACG
Create a Pod in the dev Namespace called apple. Use the nginx:stable image. Configure this Pod's container with resource requests for 256Mi memory and 250m CPU.

## JDL Solution
```
# First get help on how to create a pod in command line
k run --help

# Use the help instruction to create the pod manifest
k run -n dev apple --image=nginx:stable --dry-run=client -o yaml | tee apple.yaml
{
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: apple
  name: apple
  namespace: dev
spec:
  containers:
  - image: nginx:stable
    name: apple
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
}

# Now we need to add resources. For that let's use explain command
# Looking at the manifest, we need more info on pod.spec.containers.resources
k explain pod.spec.containers.resources

# The info above doesn't help enough to complete the resources block but it provides a doc page to refer to
# Looking at the page it is easy to copy/paste the block and complete the practice objective
cat apple.yaml
{
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: apple
  name: apple
  namespace: dev
spec:
  containers:
  - image: nginx:stable
    name: apple
    resources:
      requests:
        memory: 256Mi
        cpu: 250m
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
}

# Create the pod
ka apple.yaml

```
