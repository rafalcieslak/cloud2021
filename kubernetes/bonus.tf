# This example is here only to show that it’s possible
# to configure K8s's basic resources with Terraform

provider "google" {
  project = "project_id"
  region  = "project_region"
}

# The google_client_config data source fetches a token from the Google Authorization server, which expires in 1 hour by default.
data "google_client_config" "default" {}

resource "google_service_account" "k8s_cluster" {
  account_id   = "main-k8s-cluster"
  display_name = "Service Account for main K8s cluster"
}

resource "google_container_cluster" "k8s_cluster" {
  name     = "main-k8s-cluster"
  location = "us-east1-b" # region (multi-az) or single zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "k8s_cluster_nodes" {
  name       = "main-k8s-cluster-node-pool"
  location   = google_container_cluster.k8s_cluster.location
  cluster    = google_container_cluster.k8s_cluster.name
  node_count = 3

  node_config {
    preemptible  = true       # spots that live max 24h
    machine_type = "g1-small" # f1-micro machines are not supported due to insufficient memory
    disk_size_gb = 10
    image_type   = "COS"

    service_account = google_service_account.k8s_cluster.email
    # oauth_scopes    = [
    #   "https://www.googleapis.com/auth/cloud-platform"
    # ]
  }
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.k8s_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.k8s_cluster.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx-pod"
    labels = {
      app = "nginx"
    }
  }

  spec {
    container {
      image = "nginx:1.20"
      name  = "nginx"

      port {
        container_port = 80
      }
    }
  }

  lifecycle {
    # ignore volume_mount with service account added by GCP
    ignore_changes = [
      spec.0.container.0.volume_mount
    ]
  }
}


resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
  }

  spec {
    selector = {
      app = kubernetes_pod.nginx.metadata.0.labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

output "load_balancer_ip" {
  value = kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.ip
}
