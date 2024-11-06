# Create Service Account to use with NodePools
resource "google_service_account" "default" {
  account_id   = "gke-cluster-sa-id"
  display_name = "Service Account for GKE"
  project      = var.project_id
}