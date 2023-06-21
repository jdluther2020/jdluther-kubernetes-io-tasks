TODO: clean up, name and formatting

Ref: 
https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-container-environment-variables-using-secret-data

https://kubernetes.io/docs/concepts/configuration/secret/

kpd-002-secret-mounting-as-env-var.md#

practice-6-of-12-resource-request-and-consuming-a-secret.md

kubectl create secret generic secret-code --from-literal=code=trustno1 $do | tee secret.yaml

k run secret-keeper --image=busybox:stable $do | tee secret-keeper.yaml

./verify.sh
