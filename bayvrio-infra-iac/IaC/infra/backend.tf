terraform {
  backend "gcs" {
    bucket = ""
    prefix  = "gke/terraform/bayvrio"
    credentials = "google-application-credentials.json"
  }
}