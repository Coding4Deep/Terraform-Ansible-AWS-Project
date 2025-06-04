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


##  Workflow: How Jenkins Uses a Kubernetes ServiceAccount to Deploy

This workflow explains how an external Jenkins server (not running in the cluster or in a container) can access and deploy to a Kubernetes cluster using a ServiceAccount and a token-based kubeconfig.

---

### 🧱 Components Involved

- **ServiceAccount (`jenkins-sa`)** – Identity for Jenkins in the Kubernetes cluster
- **Secret** – Manually created to store the Bearer Token and CA certificate
- **ClusterRole & ClusterRoleBinding** – Grants access permissions (e.g., to apply deployments)
- **kubeconfig** – Config file used by Jenkins to authenticate to Kubernetes
- **Kubernetes API Server** – Receives and handles Jenkins’ `kubectl` requests
- **Jenkins** – External CI/CD tool triggering Kubernetes deployments

---

### 🛰️ Workflow Overview

1. Jenkins executes `kubectl apply -f deployment.yaml` as part of a pipeline.
2. The `KUBECONFIG` environment variable points to a kubeconfig file stored securely in Jenkins credentials.
3. This kubeconfig includes:
   - Kubernetes API server URL
   - The manually generated **Bearer Token** for `jenkins-sa`
   - Cluster’s **CA Certificate**
4. Jenkins (via `kubectl`) sends an HTTPS request to the Kubernetes API server with: Authorization: Bearer <token>
5. Kubernetes API server:
- Validates the token (JWT)
- Verifies it belongs to the `jenkins-sa`
- Checks RBAC permissions via `ClusterRoleBinding`
6. If permitted, the resource (e.g., Deployment) is created or updated. If not, Jenkins receives a `403 Forbidden` error.

---

###  Under the Hood

- The ServiceAccount token is a JWT containing claims like:
- `sub`: `system:serviceaccount:<namespace>:jenkins-sa`
- `exp`: Token expiry
- The API server uses the `ca.crt` (provided in the kubeconfig) to authenticate itself to Jenkins and ensure encrypted communication.
- All RBAC rules are resolved in real-time based on the token’s ServiceAccount identity.

---

### 📡 Visual Flow

```

Jenkins (external)
|
|  uses kubeconfig (with SA token + CA cert)
v
Kubernetes API Server
|
|-- Validates Token (JWT)
|-- Resolves ServiceAccount Identity
|-- Applies RBAC Authorization (ClusterRoleBinding)
v
+------------------------------+
|   Resource Applied OR Error  |
|   (✔ Success or ✖ 403)       |
+------------------------------+

```



