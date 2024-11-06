output "alloydb_cluster_name" {
  description = "The name of the AlloyDB cluster."
  value       = google_alloydb_cluster.alloydb_cluster.name
}

output "alloydb_instance_name" {
  description = "The name of the AlloyDB instance."
  value       = google_alloydb_instance.alloydb_instance.instance_id
}

output "alloydb_cluster_private_ip" {
  description = "The private IP address allocated for the AlloyDB cluster."
  value       = google_compute_global_address.private_ip_alloc.address
}

output "alloydb_cluster_network" {
  description = "The network associated with the AlloyDB cluster."
  value       = google_compute_network.alloydb_network.name
}

output "alloydb_instance_machine_type" {
  description = "The machine type (CPU count) for the AlloyDB instance."
  value       = google_alloydb_instance.alloydb_instance.machine_config[0].cpu_count
}

output "alloydb_cluster_backup_schedule" {
  description = "The backup schedule for the AlloyDB cluster."
  value = google_alloydb_cluster.alloydb_cluster.automated_backup_policy[0].weekly_schedule
}

output "alloydb_cluster_location" {
  description = "The location where the AlloyDB cluster is created."
  value       = google_alloydb_cluster.alloydb_cluster.location
}

output "alloydb_instance_ip" {
  description = "The private IP address of the AlloyDB instance."
  value       = google_alloydb_instance.alloydb_instance.ip_address
}
