output "endpoint" {
  description = "The IP address of the cluster master."
  sensitive   = true
  value       = google_container_cluster.primary.endpoint
}