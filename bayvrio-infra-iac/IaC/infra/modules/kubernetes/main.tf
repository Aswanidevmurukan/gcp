resource "google_container_cluster" "default" {
  project             = var.project_id
  name                = var.cluster_name
  location            = var.region 
  network             = "projects/${var.host_project}/global/networks/${var.network_name}"
  subnetwork          = "projects/${var.host_project}/regions/${var.region}/subnetworks/${var.subnet_name}"
  deletion_protection = false  # Set to true for protection against accidental deletion

  resource_labels = {
    foo = "bar"
  }

  ip_allocation_policy  {
    cluster_secondary_range_name = var.pods_range_name
    services_secondary_range_name = var.svc_range_name
  }
  
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.21.21.0/28"
  }

  dns_config {
    cluster_dns          = "CLOUD_DNS"
    cluster_dns_scope    = "VPC_SCOPE"
    cluster_dns_domain   = var.domain_suffix
  }

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER", "WORKLOADS"
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER", "POD", "DEPLOYMENT", "STORAGE", "HPA", "DAEMONSET", "STATEFULSET"
    ]
  }
}


# Required for internal ingress
resource "google_compute_subnetwork" "default" {
  name          = var.subnet_name
  ip_cidr_range = "10.2.0.0/16"
  region        = google_container_cluster.default.location
  network       = "projects/${var.host_project}/global/networks/${var.network_name}"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  project       = var.host_project 
}


resource "google_compute_address" "default" {
  name         = "hello-app-ip"
  address_type = "INTERNAL"
  region       = google_container_cluster.default.location
  purpose      = "SHARED_LOADBALANCER_VIP"
  project      = var.host_project  # Ensure this is created in the host project
}