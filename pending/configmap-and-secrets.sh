* Files
/Users/jdl/repos-jdl/jdl-kubernetes-training/CKA/ACG-CKA/
  - lab-ch5-1-of-3-passing-config-data-to-a-container.md

/Users/jdl/repos-jdl/jdl-kubernetes-training/CKAD/CKAD-Practice-Ground
  - ca-15-configmaps-and-secrets.md
  - ca-21-configmaps-and-helm.md
  - ca-30-Configuration.md
  - lab-ch5-2-of-2-Configuring-Applications-in-Kubernetes.md
  - lr-5-8-Configuring-Applications-with-ConfigMaps-and-Secrets.md
  - practice-3-of-12-create-and-use-configmap.md



 
* A secret volume is used to pass sensitive information, such as passwords, to Pods. You can store secrets in the Kubernetes API and mount them as files for use by pods without coupling to Kubernetes directly. secret volumes are backed by tmpfs (a RAM-backed filesystem) so they are never written to non-volatile storage. - https://kubernetes.io/docs/concepts/storage/volumes/#secret
