# Ephemeral Development Environment
# This creates resources that can be destroyed frequently:
# - GKE Cluster
# - Secrets
# These resources reference the persistent platform layer

terraform {
  backend "gcs" {
    bucket = "zebraan-gcp-zebo-dev-terraform-state"
    prefix = "environments/dev"
  }

  required_version = ">= 1.9.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Data source: Get GKE node SA from platform layer
data "google_service_account" "gke_node_sa" {
  account_id = "gke-node-sa"
  project    = var.project_id
}

# Secret Manager for application secrets
module "secret_manager" {
  source     = "../../modules/secret_manager"
  project_id = var.project_id
  secrets    = var.secrets
}

# GKE Cluster
module "gke_cluster" {
  source = "../../modules/gke"

  project_id   = var.project_id
  region       = var.region
  cluster_name = "${var.environment}-gke-cluster"

  # Use service account from platform layer
  gke_node_pool_sa_email = data.google_service_account.gke_node_sa.email

  # Network configuration
  network_name      = var.network_name
  subnetwork_name   = var.subnetwork_name
  ip_range_pods     = var.ip_range_pods
  ip_range_services = var.ip_range_services

  # Node pool configuration
  node_machine_type  = var.node_machine_type
  min_nodes          = var.min_nodes
  max_nodes          = var.max_nodes
  use_spot_instances = var.use_spot_instances

  deletion_protection = var.gke_deletion_protection
}

# Configure Kubernetes provider to use the GKE cluster
data "google_client_config" "provider" {}

data "google_container_cluster" "primary" {
  name       = module.gke_cluster.cluster_name
  location   = var.region
  depends_on = [module.gke_cluster]
}

# Outputs
output "gke_cluster_name" {
  value       = module.gke_cluster.cluster_name
  description = "GKE cluster name"
}

output "gcloud_get_credentials" {
  value       = "gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} --region ${var.region} --project ${var.project_id}"
  description = "Command to configure kubectl"
}
