<div align="center">

#  Jenkins-to-Kubernetes Integration via ServiceAccount, ClusterRole, ClusterRoleBinding & Kubeconfig

</div>

This guide explains how to **securely configure Jenkins (running outside the Kubernetes cluster)** to authenticate and deploy workloads into your Kubernetes cluster using **manifest files**, a dedicated **ServiceAccount**, **ClusterRoleBinding**, and a generated `kubeconfig`.

This is a production-grade approach compatible with Kubernetes `v1.24+` (including v1.33), where ServiceAccount tokens are **not automatically created as Secrets** and must be manually managed.

---

##  Overview

1. Create a dedicated namespace and ServiceAccount
2. Assign ClusterRole & ClusterRoleBinding
3. Manually generate a ServiceAccount token Secret
4. Extract Bearer Token, CA Cert, and API Server URL
5. Construct a `kubeconfig` file
6. Store it in Jenkins securely
7. Use it in Jenkins pipelines for deploying to Kubernetes

---

## 🛠 Step 1: Create Namespace, ServiceAccount, Roles, and Token Secret

```bash
kubectl create namespace jenkins
````

```yaml
# jenkins-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-sa
  namespace: jenkins
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins-role
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-deployer-binding
subjects:
  - kind: ServiceAccount
    name: jenkins-sa
    namespace: jenkins
roleRef:
  kind: ClusterRole
  name: jenkins-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-sa-token
  namespace: jenkins
  annotations:
    kubernetes.io/service-account.name: jenkins-sa
type: kubernetes.io/service-account-token
```

Apply the configuration:

```bash
kubectl apply -f jenkins-rbac.yaml
```

> ⏳ Wait \~10 seconds for Kubernetes to populate the token in the Secret.

---

##  Step 2: Extract Authentication Details

### Get Bearer Token:

```bash
kubectl get secret jenkins-sa-token -n jenkins -o jsonpath='{.data.token}' | base64 -d
```

### Get CA Certificate:

```bash
kubectl get secret jenkins-sa-token -n jenkins -o jsonpath='{.data.ca\.crt}' 
```

### Get Kubernetes API Server URL:

```bash
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
```

You now have:

* ✅ **Bearer Token**
* ✅ **CA Certificate**
* ✅ **Kubernetes API Server URL**

---

## ⚙️ Step 3: Create `kubeconfig` File for Jenkins

```yaml
# jenkins-kubeconfig.yaml
apiVersion: v1
kind: Config
clusters:
- name: kubernetes
  cluster:
    certificate-authority-data: <CA_CRT_BASE64>
    server: https://<K8S_API_SERVER>
users:
- name: jenkins
  user:
    token: <BEARER_TOKEN>
contexts:
- name: jenkins-context
  context:
    cluster: kubernetes
    user: jenkins
current-context: jenkins-context
```

###  Replace placeholders:

* `<CA_CRT_BASE64>` → base64-encoded contents of `ca.crt`
* `<BEARER_TOKEN>` → your decoded token from above
* `<K8S_API_SERVER>` → your API server URL (e.g., `https://<IP>:6443`)

---

##  Step 4: Add kubeconfig to Jenkins as a Secret File

1. Go to **Manage Jenkins → Credentials**
2. Select the correct **domain** (e.g., global)
3. Click **Add Credentials**
4. Choose **"Secret file"**
5. Upload `jenkins-kubeconfig.yaml`
6. Give it an ID, e.g., `KUBECONFIG`

---

##  Step 5: Use the kubeconfig in Jenkins Pipeline

###  Declarative Pipeline Example

```groovy
pipeline {
  agent any
  environment {
    KUBECONFIG = credentials('KUBECONFIG') // Jenkins secret file ID
  }
  stages {
    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          kubectl apply -f k8s/deployment.yaml
          kubectl rollout status deployment/myapp
        '''
      }
    }
  }
}
```

 Jenkins will inject the kubeconfig path as `$KUBECONFIG`, and `kubectl` will use it automatically.

---

##  Notes (Kubernetes v1.24+ Behavior)

* In modern Kubernetes versions (v1.24+), `ServiceAccount` Secrets are **not auto-generated**.
* You **must create** the `kubernetes.io/service-account-token` Secret manually (as shown above).
* Kubernetes will then populate it with a **short-lived token**, **CA cert**, and **namespace** info.

---

## ✅ You’re Done!

Jenkins can now securely deploy to your Kubernetes cluster using the `kubectl apply -f` approach with a real `kubeconfig` file. This method is scalable, secure, and production-ready.

---

## 👏 Contributions Welcome

Feel free to fork and enhance this guide for your CI/CD workflow. PRs are welcome!

```

