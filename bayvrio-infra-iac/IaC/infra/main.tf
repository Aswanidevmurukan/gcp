module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 15.0"

  disable_services_on_destroy = var.disable_services_on_destroy
  project_id                  = var.project_id
  activate_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "firestore.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "container.googleapis.com",
    "storage.googleapis.com",
    "alloydb.googleapis.com",
    "logging.googleapis.com",
    "iap.googleapis.com",
    "run.googleapis.com",
  ]
}

data "google_project" "project" {
  depends_on = [
    module.project_services
  ]

  project_id = var.project_id
}

data "google_client_config" "default" {
  depends_on = [
    module.project_services
  ]
}

locals {
  resource_path     = "resource"
  firestore_db_name = "cloud-deployment-gke-${random_id.random_code.hex}"
  collection_fields = {
    (var.firestore_collection_id) = [
      {
        field_path   = "tags"
        array_config = "CONTAINS"
      },
      {
        field_path = "orderNo"
        order      = "DESCENDING"
      },
    ]
  }
  cd_firestore             = [for key, value in local.collection_fields : key][0]
  base_entries = [
    {
      name  = "namespace"
      value = var.namespace
    },
    {
      name  = "k8s_sa"
      value = var.k8s_sa
    },
    {
      name  = "project_id"
      value = data.google_project.project.project_id
    },
    {
      name  = "region"
      value = var.region
    },
  ]
}

module "storage" {
  source = "./modules/storage"

  project_id = data.google_project.project.project_id
  location   = var.bucket_location
  labels     = var.labels
  name       = "cloud-deployment-gke-golang-resource-${data.google_project.project.number}"
}


module "firestore" {
  source = "./modules/firestore"

  project_id        = data.google_project.project.project_id
  collection_fields = local.collection_fields
  firestore_db_name = local.firestore_db_name
}

resource "random_id" "random_code" {
  byte_length = 4
}

module "kubernetes" {
  source = "./modules/kubernetes"
 project_id                 = data.google_project.project.project_id
  name                       = "gke-test-1"
  region                     = var.region
  zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
  network                    = var.network
  subnetwork                 = var.subnetwork
  ip_range_pods              = "us-central1-01-gke-01-pods"
  ip_range_services          = "us-central1-01-gke-01-services"
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  dns_cache                  = false

  node_pools = [
    {
      name                        = "default-node-pool"
      machine_type                = "e2-medium"
      node_locations              = "us-central1-b,us-central1-c"
      min_count                   = 1
      max_count                   = 100
      local_ssd_count             = 0
      spot                        = false
      disk_size_gb                = 100
      disk_type                   = "pd-standard"
      image_type                  = "COS_CONTAINERD"
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      auto_repair                 = true
      auto_upgrade                = true
      service_account             = "project-service-account@<PROJECT ID>.iam.gserviceaccount.com"
      preemptible                 = false
      initial_node_count          = 80
      accelerator_count           = 1
      accelerator_type            = "nvidia-l4"
      gpu_driver_version          = "LATEST"
      gpu_sharing_strategy        = "TIME_SHARING"
      max_shared_clients_per_gpu = 2
    },
  ]
}

module "base_helm" {
  source = "./modules/helm"

  chart_folder_name = "base"
  entries = concat(local.base_entries,
    [
      {
        name  = "google_cloud_service_account_email"
        value = module.kubernetes.google_cloud_service_account_email
      },
    ]
  )
  namespace = local.namespace
}

module "load_balancer" {
  source = "./modules/load-balancer"

  project_id    = data.google_project.project.project_id
  bucket_name   = module.storage.bucket_name
  resource_path = local.resource_path
  labels        = var.labels
  health_check_allow_ports = [
    80,
  ]
}
