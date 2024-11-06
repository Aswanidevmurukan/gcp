variable "region" {
  description = "Region where cluster is created"
}
 
variable "host_project" {
  description = "Network Project ID (GCP Project acting as Shared VPC host)"
}
 
variable "project_id" {
  description = "Cluster Project ID (GCP Project acting as Shared VPC service)"
}

variable "cluster_name" {
  description = "Name of the GKE standard cluster"
}

variable "network_name" {
  description = "The name of the network (Host project)"
}

variable "subnet_name" {
  description = "The name of the subnet (Host project)"
}

variable "pods_range_name" {
  description = "Range of ip for pods"
}

variable "svc_range_name" {
  description = "Range of ip for service"
}

variable "domain_suffix" {
  description = "DNS domain suffix"
}

variable "disable_services_on_destroy" {
   description = "disable_services_on_destroy"
} 

variable "namespace" {
  description = "namespace"
} 



variable "firestore_collection_id" {
  description = "firestore_collection_id" 
  type        = string

}

variable "k8s_sa"{
  description = "The name of the Kubernetes service account to use"
  type        = string
}

variable "bucket_location"{
  description = "The name of the Kubernetes service account to use"
  type        = string
}

variable "network_name" {
  description = "The network name for the Kubernetes cluster."
  type        = string
}

variable "subnet_name" {
  description = "The subnet name for the Kubernetes cluster."
  type        = string
}