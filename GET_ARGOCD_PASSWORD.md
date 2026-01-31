# How to Get ArgoCD Password

Your ArgoCD installation was successful! Here are several ways to get the admin password:

## Option 1: Check GitHub Actions Logs (Fastest)

1. Go to your GitHub repository
2. Click on "Actions" tab
3. Find your latest successful workflow run
4. Look for the "Display Outputs" step
5. The ArgoCD admin password should be displayed there (though marked as sensitive)

## Option 2: Install gcloud CLI and Use Terraform (Recommended)

### Step 1: Install Google Cloud SDK

For macOS:
```bash
# Using Homebrew
brew install --cask google-cloud-sdk

# Or download from: https://cloud.google.com/sdk/docs/install
```

### Step 2: Authenticate with Google Cloud
```bash
# Authenticate for gcloud commands
gcloud auth login

# Authenticate for Terraform/application access
gcloud auth application-default login

# Set your project
gcloud config set project zebraan-gcp-zebo-dev
```

### Step 3: Get ArgoCD Password via Terraform
```bash
cd /Users/aninda/workspace/git/zebo-terraform/environments/dev
terraform init
terraform output -raw argocd_admin_password
```

## Option 3: Direct Kubernetes Access (After gcloud is installed)

### Step 1: Install kubectl (if not already installed)
```bash
brew install kubectl
```

### Step 2: Get cluster credentials
```bash
gcloud container clusters get-credentials dev-gke-cluster \
  --region asia-south1 \
  --project zebraan-gcp-zebo-dev
```

### Step 3: Get ArgoCD password from Kubernetes secret
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

## Option 4: Use Google Cloud Console (Web UI)

1. Go to https://console.cloud.google.com
2. Select project: `zebraan-gcp-zebo-dev`
3. Navigate to: Kubernetes Engine → Clusters
4. Click on `dev-gke-cluster`
5. Click "Connect" button
6. Click "Run in Cloud Shell" 
7. In the Cloud Shell, run:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret \
     -o jsonpath="{.data.password}" | base64 -d && echo
   ```

## ArgoCD Access Information

- **Username**: `admin`
- **URL**: Check the GitHub Actions output or run:
  ```bash
  terraform output -raw argocd_url
  ```

## Next Steps After Login

1. Change the default admin password
2. Set up your repositories in ArgoCD
3. Create ArgoCD applications for your deployments

## Troubleshooting

If you get authentication errors:
- Make sure you're logged in: `gcloud auth list`
- Verify your project: `gcloud config get-value project`
- Re-authenticate if needed: `gcloud auth application-default login`
