provider "google" {
  credentials = file("google-application-credentials.json")
  project     = var.project_id
  region      = var.region
}