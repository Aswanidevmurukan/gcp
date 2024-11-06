
# Create a VPC network for the AlloyDB cluster
resource "google_compute_network" "alloydb_network" {
  name = var.network_name
}

# Allocate private IP range for VPC Peering
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "${var.cluster_id}-private-ip"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  prefix_length = 16
  network       = google_compute_network.alloydb_network.id
}

# Create the service networking connection for VPC peering
resource "google_service_networking_connection" "vpc_connection" {
  network                 = google_compute_network.alloydb_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# Create the AlloyDB Cluster
resource "google_alloydb_cluster" "alloydb_cluster" {
  cluster_id = var.cluster_id
  location   = var.region

  network_config {
    network = google_compute_network.alloydb_network.id
  }

  database_version = "POSTGRES_15"

  initial_user {
    user     = "alloydb-user"
    password = "alloydb-password"
  }

  continuous_backup_config {
    enabled              = true
    recovery_window_days = 14
  }

  automated_backup_policy {
    location      = var.region
    backup_window = var.backup_window
    enabled       = true

    weekly_schedule {
      days_of_week = var.backup_schedule.days_of_week

      start_times {
        hours   = 23
        minutes = 0
        seconds = 0
        nanos   = 0
      }
    }

    quantity_based_retention {
      count = 1
    }
  }

  labels = {
    cluster_id = var.cluster_id
  }
}

# Create the AlloyDB instance within the cluster
resource "google_alloydb_instance" "alloydb_instance" {
  cluster       = google_alloydb_cluster.alloydb_cluster.name
  instance_id   = var.instance_id
  instance_type = "PRIMARY"

  machine_config {
    cpu_count = var.cpu_count
  }

  depends_on = [google_service_networking_connection.vpc_connection]
}