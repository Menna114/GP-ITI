# 🚀 Part 1: Infrastructure Overview and Module Breakdown

## 🛠️ Overview

This setup provisions the core cloud infrastructure on **AWS** using modular **Terraform** components. It features a secure network architecture, a production-grade **EKS** cluster, and a remote backend for managing Terraform state. Each element is designed to be reusable, scalable, and version-controlled to support long-term maintainability.

This infrastructure acts as the backbone for integrating CI/CD tools such as **Jenkins**, **ArgoCD**, and the **External Secrets Operator**, enabling secure and automated application deployments.

---

## 🧩 Modules

### 🌐 `network` Module

This module provisions the networking components of the infrastructure:

VPC: A Virtual Private Cloud to isolate and secure the environment.
Subnets:

    3 public subnets across 3 AZs for external resources.

    3 private subnets for internal resources like EKS node groups.
    NAT Gateway: Provides internet access to resources in private subnets.
    Internet Gateway: Allows public subnets to access the internet.
    Route Tables: Configures routes between the subnets and the internet.


---

### 🛠️ `eks` Module

This module provisions the Amazon Elastic Kubernetes Service (EKS) cluster and related resources:

EKS Control Plane: The API server and management layer for Kubernetes.
EKS Node Groups: EC2 instances running in private subnets to manage containerized workloads.
IAM Roles and Policies: Grants necessary permissions to EKS and EC2 nodes for interaction with AWS services.


---

### 💾 `ebs` Module

The EBS (Elastic Block Store) module provisions an Amazon EBS volume to provide persistent storage for applications running within the Amazon EKS cluster. This ensures that the state of the application or database is stored securely and can survive pod restarts.

The module creates an EBS volume with specified storage size and type. The volume can be attached to EKS worker nodes or specific pods within the Kubernetes cluster for persistent data storage.

---

### 📦 `ecr` Module

The ECR (Elastic Container Registry) module provisions an Amazon ECR repository for storing Docker images. The repository allows you to securely store and manage Docker images that can be used within the EKS cluster.

Once an image is pushed to the ECR repository, it can be pulled by Kubernetes pods for deployment, supporting the CI/CD pipeline by storing containerized application images.

---

### 🔑 `roles` Module

This module provisions IAM roles and policies required for controlling access to AWS resources, particularly for integration with the External Secrets Operator:

External Secrets Role: An IAM role with a trust policy that allows the External Secrets Operator service account to assume the role with web identity via the OIDC provider.
External Secrets Policy: An IAM policy granting the necessary permissions for the External Secrets Operator to interact with AWS Secrets Manager and retrieve secrets.
Policy Attachment: This attaches the policy to the IAM role to allow the role to perform the required actions on AWS Secrets Manager.


---

### 🔒 `secret_manager` Module

This module integrates AWS Secrets Manager to securely manage and store sensitive information:

Secrets: The module stores database credentials, Redis credentials, or any other secrets required by the Node.js app.
IAM Permissions: Roles and policies are defined to allow the Kubernetes pods to access these secrets securely.


---

## ⚙️ Setup Instructions

### 🔑 Prerequisites

Before running Terraform, ensure you have the following:

AWS Account: Access to provision AWS resources in your AWS account.
Terraform: Installed locally or in a CI/CD pipeline. You can download Terraform from here.
AWS CLI: Installed and configured with the correct credentials. Run aws configure to set up your AWS CLI if you haven’t already.
IAM Permissions: Ensure your IAM user has permissions to create VPCs, subnets, EKS clusters, and related resources.
Git: Installed for cloning the repository.


---

### 📝 Step-by-Step Setup

#### 1. Clone the Repository 🔄

Clone this repository to your local machine:

```bash
git clone https://github.com/yousra000/GP-ITI
cd GP-ITI/terraform

2. Initialize Terraform 🔧

    terraform init

3. Apply the Terraform Configuration 🚀

    terraform apply

4. Update kubeconfig to connect to your EKS cluster

    aws eks --region us-east-1 update-kubeconfig --name my_eks
    kubectl config get-contexts

5. Check the cluster nodes

    kubectl get nodes

This verifies that your local kubectl is correctly connected to your EKS cluster and can communicate with the worker nodes. It's a great way to confirm the cluster is active and ready before deploying anything like Jenkins with Helm.
```

### 🌍 Key Resources Provisioned
```bash
This Terraform configuration provisions the following AWS resources:

**VPC**: A private network for your infrastructure.

**Subnets**: 3 public and 3 private subnets across 3 Availability Zones for high availability.

**EKS Cluster**: A managed Kubernetes cluster with private node groups.

**NAT Gateway**: Enables internet access for resources in private subnets.

**Internet Gateway**: Allows public subnets to access the internet.

**Route Tables**: Manages routing between subnets and the internet.

**IAM Roles**: Roles for EKS and EC2 node groups to interact with other AWS services.

**Secrets Manager**: Stores sensitive data like database credentials and Redis configurations.
```


# 🚀 Part 2: Deploy Jenkins on EKS with Helm (via Terraform)
## Overview 🛠️

This section automates the deployment of Jenkins, a widely used open-source automation server, onto the EKS cluster provisioned earlier. Using Terraform's Helm provider, the official Jenkins Helm chart is configured and installed with custom values to expose Jenkins externally, configure volumes, and pre-install essential plugins.
## 🔧 What Each File Does

    helm_release.tf: Declares the Jenkins Helm release, referencing values.yaml for custom settings.
    kubernetes.tf: Configures the Kubernetes provider using EKS cluster data.
    values.yaml: Contains Jenkins settings like admin credentials, plugins, service type, and resource limits.
    versions.tf: Sets required Terraform and provider versions to ensure compatibility.

## 🛠️ Prerequisites

    EKS cluster already provisioned (from Part 1).
    AWS CLI configured (aws configure).
    kubectl installed and configured.
    terraform installed.
    helm installed.

## 🚀 Deployment Steps
1.Navigate to the helm/ directory

cd helm
2-Add jenkins repo 

    helm repo add jenkins https://charts.jenkins.io
    helm repo update
    
3.Install Jenkins with Helm

    helm install jenkins jenkins/jenkins -f values.yaml --namespace jenkins --create-namespace

4.Verify Jenkins pods are running

    kubectl get pods -n jenkins

5.Port-forward Jenkins to access the UI

    kubectl --namespace jenkins port-forward svc/jenkins 8080:8080

6.Retrieve Jenkins admin password

    kubectl get secret -n jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode

Log into Jenkins UI

    Visit http://localhost:8080 and log in with:

    **Username**: user (from values.yaml)
    **Password**: value from step 6
---

Instead of running all pipeline jobs on the Jenkins master (which is not recommended for performance and security reasons), we configure Jenkins to dynamically provision Kubernetes agent pods that execute jobs.

This setup allows Jenkins to scale on demand, isolating each build in a fresh Kubernetes pod (slave), which improves:

    Security: the Jenkins master is never used to run untrusted build code.

    Scalability: jobs are run in parallel on separate pods.

    Resource efficiency: no idle agents consuming cluster resources when no builds are running.

### 🧩 How Jenkins Connects to Dynamic Agent Pods

    Kubernetes Plugin: We configure the Kubernetes plugin in Jenkins, pointing it to the EKS cluster.

    Jenkins Service Account: A Kubernetes service account with the required RBAC permissions allows Jenkins to create and destroy pods in the namespace it's installed in.

    Pod Templates: We define dynamic pod templates with the required containers/tools (e.g., Docker, Terraform, Node.js).

    Job Execution: When a pipeline starts, Jenkins spins up a new pod based on the pod template, runs the pipeline steps inside the pod, and deletes the pod afterward.

This dynamic agent approach avoids the overhead and maintenance of managing static slave nodes and ensures clean, isolated environments for every pipeline execution.






# 🚀 part 3: CD Tool – ArgoCD + Argo Image Updater

To implement GitOps for continuous delivery, we use ArgoCD along with Argo Image Updater. Both tools are installed into a dedicated namespace in our EKS cluster using Helm.
📦 ArgoCD Installation and Setup

We deploy ArgoCD using Helm with the following steps:
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create ns argocd
kubectl apply -f service-account.yml
kubectl apply -f secrets.yml
kubectl apply -f git-cre.yml
helm install argocd argo/argo-cd -n argocd -f argo-values.yaml
```

ArgoCD is configured to:

    Continuously sync Kubernetes manifests from our GitHub repo.

    Enable automated GitOps deployments whenever changes are detected in the Git repo.

To access the ArgoCD UI:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
argocd login localhost:8888 --insecure --username admin --password <password>
argocd cluster add arn:aws:eks:<region>:<owner-id>:cluster/<cluster-name> --name <cluster-name> --yes

```
Connect Your Cluster to ArgoCD
```bash
argocd cluster add arn:aws:eks:us-east-1:661013218527:cluster/my_eks --name my_eks --yes
```
Add Your GitHub Repo to ArgoCD
```bash
argocd repo add https://github.com/DanaMostafa48/GP-ITI.git --username <username> --password <token>
```

### 📁 Key Files in cd/kustomize/argocd/
#### app-nodejs.yml

Defines an ArgoCD Application resource to connect your Git repo to ArgoCD. It also includes annotations required by Argo Image Updater to monitor and update the image tag:
    
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: my-app
      namespace: argocd
      annotations:
        argocd-image-updater.argoproj.io/image-list: "myapp=661013218527.dkr.ecr.us-east-1.amazonaws.com/node-app-jenkins2"
        argocd-image-updater.argoproj.io/write-back-method: git
        argocd-image-updater.argoproj.io/git-branch: main
        argocd-image-updater.argoproj.io/myapp.update-strategy: regexp:^\d+\.[a-f0-9]{7}$
    spec:
      project: default
      source:
        repoURL: https://github.com/DanaMostafa48/GP-ITI.git
        targetRevision: HEAD
        path: kustomize/overlays
      destination:
        server: https://<your-eks-cluster-endpoint>
        namespace: default
      syncPolicy:
        automated:
          prune: true
          selfHeal: true

    Apply it using:
    
    kubectl apply -f app-nodejs.yml

#### git-cre.yml

    This Kubernetes Secret connects ArgoCD and Argo Image Updater to your private GitHub repository using base64-encoded credentials:
    
    apiVersion: v1
    kind: Secret
    metadata:
      name: repo-github
      namespace: argocd
      labels:
        argocd.argoproj.io/secret-type: repository
    type: Opaque
    stringData:
      type: git
      url: https://github.com/DanaMostafa48/GP-ITI.git
      username: <base64-encoded-username>
      password: <base64-encoded-token>

#### secrets.yml

    Stores the ArgoCD server address and authentication token used by Argo Image Updater:
    **argocd account generate-token --account image-updater**
    
    apiVersion: v1
    kind: Secret
    metadata:
      name: argocd-image-updater-secret
    stringData:
      ARGOCD_SERVER: https://argocd-server.argocd.svc:443
      ARGOCD_AUTH_TOKEN: <your-auth-token>

#### service-account.yml
    
    Defines a service account used by ArgoCD and Argo Image Updater. It’s annotated with an IAM role ARN that allows access to ECR:
    
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: argo-image-updater
      namespace: argocd
      annotations:
        eks.amazonaws.com/role-arn: arn:aws:iam::661013218527:role/argocd-ecr-access-role

## ⚙️ ArgoCD and Argo Image Updater Configurations
#### argo-values.yaml

    This file overrides the default ArgoCD values to assign our service account to its components:
    
    repoServer:
      serviceAccount:
        create: false
        name: argo-image-updater
    
    applicationController:
      serviceAccount:
        create: false
        name: argo-image-updater
    
    server:
      serviceAccount:
        create: false
        name: argo-image-updater

#### argocd-values.yml

    This configures Argo Image Updater to authenticate with ECR using a shell script:
    
    config:
      registries: 
        - name: ECR
          api_url: https://661013218527.dkr.ecr.us-east-1.amazonaws.com
          prefix: 661013218527.dkr.ecr.us-east-1.amazonaws.com
          credentials: ext:/scripts/auth.sh
          credsexpire: 12h
          ping: yes
          default: true
          insecure: false
    
    authScripts: 
      enabled: true
      scripts:
        auth.sh: |
          #!/bin/sh
          HOME=/tmp aws ecr --region us-east-1 get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d
    
    serviceAccount:
      name: argo-image-updater
      create: false

### 🔄 Deploy Argo Image Updater

Install the Image Updater with Helm:
```bash
helm install argocd-image-updater argo/argocd-image-updater -n argocd -f argocd-values.yml
kubectl rollout status deployment argocd-image-updater -n argocd
kubectl get pods -n argocd
kubectl logs <image-updater-pod> -n argocd

Authenticate to ECR

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 661013218527.dkr.ecr.us-east-1.amazonaws.com

```
### 🧠 How It All Works Together

    ArgoCD syncs manifests from the GitHub repo and deploys them automatically to the EKS cluster.

    Argo Image Updater monitors your ECR repository for new image tags matching your strategy (e.g., 2.5.1, or Git SHA pattern).

    When a new image is available, Image Updater:

        Updates the image tag in the GitHub manifest.

        Commits the change to Git.

        Triggers ArgoCD to deploy the updated image to the cluster (GitOps flow).




# 🚀 Part 4+5 : Kubernetes Deployment Guide: Node.js + MySQL + Redis on AWS EKS
### Overview 🛠️

You're deploying a full-stack application with:

    A Node.js API
    A MySQL database
    A Redis cache

All deployed to an AWS EKS cluster using Kubernetes and managed declaratively with Kustomize.

Your secrets (passwords, credentials) live in AWS Secrets Manager, and are securely pulled into the cluster using the External Secrets Operator (ESO).

## ✅ Step 1: Enable Kubernetes to Access AWS Secrets Manager 🔐

    Purpose: Let the cluster talk to AWS Secrets Manager.
    🔐 Secrets Management
    
    The goal is to securely manage sensitive information like passwords and API keys without hardcoding them into your Kubernetes resources.
    
    We’ll set up a system where:
    
        Kubernetes pulls secrets from AWS Secrets Manager and turns them into Kubernetes Secrets using a tool called External Secrets Operator (ESO).
    
    Breakdown:
    
        Terraform Configuration:
            mysql_secrets.tf and redis_secrets.tf are used to create the secrets in AWS Secrets Manager. These files define the credentials for MySQL and Redis, which will be securely stored in AWS.
            secret_manager.tf (in terraform/roles/) creates an IAM Role in AWS that allows Kubernetes to access those secrets. The IAM Role grants permissions to read secrets from AWS Secrets Manager.
            variables.tf and outputs.tf are helper files that provide reusable variables and outputs, including the IAM Role ARN, for further use in Kubernetes configurations.
        Kubernetes Configuration:
            service-account.yaml: This file creates a Kubernetes ServiceAccount and links it to the IAM role, which allows pods to use AWS credentials securely through IRSA (IAM Roles for Service Accounts).
            secret-store.yaml: It tells ESO to use AWS Secrets Manager as the source for secrets and authenticate using the ServiceAccount created earlier.
            external-secrets-mysql.yaml & external-secrets-redis.yaml: These files instruct ESO to fetch the MySQL and Redis secrets from AWS Secrets Manager and store them as Kubernetes secrets (e.g.,                  mysql-credentials and redis-credentials).

## ✅ Step 2: Fetch Secrets from AWS into Kubernetes 📥

    Purpose: Pull credentials for MySQL and Redis from AWS Secrets Manager and store them as Kubernetes secrets.
    
        external-secrets-mysql.yaml
    
        Defines an ExternalSecret that pulls the MySQL password from AWS Secrets Manager and creates a Kubernetes Secret called mysql-credentials.
    
        external-secrets-redis.yaml
    
        Does the same, but for the Redis password, saved as redis-credentials.

    These secrets are automatically kept in sync with AWS, so updates in Secrets Manager get reflected in the cluster.
    
## ✅ Step 3: Set Up Persistent Storage for MySQL 💾

    Purpose: Ensure MySQL keeps data even if the pod restarts.
    
        mysql-pv.yaml
    
        Defines a PersistentVolume: a piece of disk on the host/node reserved for MySQL data.
    
        mysql-pvc.yaml
    
        Defines a PersistentVolumeClaim: a request from the MySQL pod asking to use storage.
    
    This ensures MySQL doesn’t lose data across restarts.

## ✅ Step 4: Deploy the MySQL Database 🛢️

    Purpose: Run MySQL in the cluster and connect it to the PVC and credentials.
    
        mysql-service.yaml
    
        Creates a ClusterIP service so that other pods (like the Node.js app) can talk to MySQL using mysql:3306.
    
        mysql-statefulset.yaml
    
        Deploys MySQL using a StatefulSet (ideal for databases), mounts the PVC, and loads credentials from the secret mysql-credentials.
    
    This sets up a persistent, secure MySQL database that other services can access.
    
## ✅ Step 5: Deploy Redis ⚡

    Purpose: Launch Redis so it’s accessible to the Node.js app.
    
        redis-deployment.yaml
    
        Deploys a Redis pod. It uses a password pulled via External Secrets Operator from AWS Secrets Manager and stored in the Kubernetes Secret redis-credentials. 
        This secret is not referenced directly in the Redis deployment, assuming default unauthenticated setup, but is used securely in the Node.js app instead.
    
        redis-service.yaml
    
        Creates a ClusterIP service named redis so other pods can access it via redis:6379.
    
    Redis will act as a cache layer for your Node.js application.
    
## ✅ Step 6: Deploy the Node.js Application 🌐

    Purpose: Launch the app and give it access to MySQL and Redis.
    
    **Key Concepts**:
    
            Node.js Container: The Node.js application is deployed in a container, with the Docker image being pulled from a registry (e.g., Amazon ECR or Docker Hub).
    
            Snippet: Pulling the Docker image from Amazon ECR:
    
            image: <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-node-app:latest
    
    **Environment Variables**:
    
        DB_HOST: Points to the MySQL service inside the Kubernetes cluster (usually mysql).
        REDIS_HOST: Points to the Redis service inside the Kubernetes cluster (usually redis).
        These environment variables are essential for the app to connect to MySQL and Redis.
    
    Snippet: Setting environment variables for MySQL and Redis connection:

    env:
      - name: DB_HOST
        value: "mysql"  # MySQL service within Kubernetes cluster
      - name: DB_PORT
        value: "3306"
      - name: REDIS_HOST
        value: "redis"  # Redis service within Kubernetes cluster
      - name: REDIS_PORT
        value: "6379"

    **Secrets Management**:

        Credentials (like MySQL and Redis passwords) are securely injected into the Node.js application using Kubernetes secrets, 
        which are managed by the External Secrets Operator. These secrets are synchronized with AWS Secrets Manager.
    
        Snippet: Fetching secrets from Kubernetes for MySQL and Redis credentials:
    
        env:
          - name: MYSQL_PASSWORD
            valueFrom:
              secretKeyRef:
                name: mysql-credentials  # The secret created from ExternalSecretsOperator
                key: password
          - name: REDIS_PASSWORD
            valueFrom:
              secretKeyRef:
                name: redis-credentials  # The secret created from ExternalSecretsOperator
                key: password

    The application fetches the credentials via environment variables, ensuring secure access to MySQL and Redis.

    **Service Exposure**:
    
        The app is exposed to the internet via a LoadBalancer service on port 80, which forwards traffic to the internal app port 3000.
    
        Snippet: Exposing the Node.js app through a LoadBalancer:
    
        apiVersion: v1
        kind: Service
        metadata:
          name: node-app-service
        spec:
          selector:
            app: node-app
          ports:
            - protocol: TCP
              port: 80  # Public-facing port
              targetPort: 3000  # Internal app port
          type: LoadBalancer
    
            This makes the Node.js API publicly accessible for external communication.
    
    🔗 Public-Facing API: The Node.js service is now accessible from outside the cluster, handling requests from users or other services.

## ✅ Step 7: Use Kustomize to Manage All Resources 🧩

    Purpose: Deploy all files in one clean, modular way.
    🛠️ What is Kustomize?
    
    Kustomize is a tool built into kubectl that lets you group, customize, and deploy Kubernetes resources without editing the original files.
    
    Instead of doing:
    
    kubectl apply -f file1.yaml
    kubectl apply -f file2.yaml
    kubectl apply -f file3.yaml
    
    You just write one file — kustomization.yaml — and run:
    
    kubectl apply -k .
    
    📄 Example kustomization.yaml file
    
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization

    resources:
      - service-account.yaml
      - secret-store.yaml
      - external-secrets-mysql.yaml
      - external-secrets-redis.yaml
      - mysql-pv.yaml
      - mysql-pvc.yaml
      - mysql-statefulset.yaml
      - mysql-service.yaml
      - redis-deployment.yaml
      - redis-service.yaml
      - dep-node.yaml
      - service-node.yaml

## 💡 Why use Kustomize?

    Keeps your deployment modular and organized.
    Lets you reuse and overlay configs across environments (e.g., dev, staging, prod).
    Supports config changes without editing original manifests.

### 🔗 It’s the tool that brings structure and manageability to your Kubernetes setup.


# 8. 🔍 Monitoring – Prometheus & Grafana

In this step, we integrate Prometheus and Grafana into our EKS cluster for real-time monitoring of our Kubernetes workloads.
### 🔧 Setup Using Prometheus Operator

We use the kube-prometheus-stack Helm chart, which bundles Prometheus, Grafana, Alertmanager, and additional monitoring CRDs.
Add Helm Repositories

```bash 
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
```
Install Prometheus Operator Stack
```bash
helm install prometheus prometheus-community/kube-prometheus-stack
```
Verify All Pods Are Running
```bash
kubectl get pods -n default
```
This should include pods like:

    prometheus-kube-prometheus-stack-prometheus

    prometheus-kube-prometheus-stack-grafana

    prometheus-kube-prometheus-stack-operator

    alertmanager-*

### 📊 Accessing Grafana

    Port Forward to Grafana UI:
    ```bash
        kubectl port-forward svc/prometheus-grafana 3000:80
    ```
#### Open Grafana UI in your browser:
    Visit http://localhost:3000

    Login Credentials (default):

        Username: admin

        Password: prom-operator (You can check secrets if this is not set.)

### 🔗 Connecting Grafana to Prometheus

Grafana is pre-configured with Prometheus as a default data source when installed via kube-prometheus-stack. You can verify this by:

    Navigating to Configuration → Data Sources in Grafana.

    Ensuring the Prometheus data source is pointing to:

    http://prometheus-kube-prometheus-prometheus.default.svc.cluster.local:9090

You can now import Kubernetes monitoring dashboards or create your own to visualize CPU, memory, pod health, etc.


# 9. 🛡️ Security – Trivy Vulnerability Scanner

Trivy is an open-source vulnerability scanner developed by Aqua Security. It scans Docker images, file systems, and repositories for known vulnerabilities (CVEs) in OS packages and application dependencies.
### 🧱 Trivy Integration in Docker Image

To ensure image scanning is automated and consistent across environments, I installed Trivy directly inside my custom Docker-in-Docker image by modifying the Dockerfile as follows:
```bash
    ENV TRIVY_VERSION=0.50.1
    RUN wget https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz && \
        tar zxvf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz && \
        mv trivy /usr/local/bin/ && \
        rm -f trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
    RUN trivy --version
```
This makes the scanner available inside the Jenkins CI pipeline, allowing early vulnerability detection during the CI process.
### ⚙️ How I Use Trivy in the CI Pipeline

In my Jenkins pipeline, before pushing the Docker image to Amazon ECR, I run a Trivy scan on the built image:
bash```
trivy image ./your-image-name:tag
```
This step is crucial because it:

    Identifies known vulnerabilities in the image before deployment

    Helps enforce security gates in CI/CD

    Prevents vulnerable code or dependencies from reaching production

    Supports compliance with DevSecOps best practices

Only if the scan passes (or meets acceptable severity thresholds), the pipeline proceeds to:

    docker push 661013218527.dkr.ecr.us-east-1.amazonaws.com/node-app-jenkins2:<tag>

This makes sure the container pushed to ECR is already validated against known vulnerabilities.

