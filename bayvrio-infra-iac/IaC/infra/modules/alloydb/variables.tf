
variable "project_id" {
  description = "The Google Cloud Project ID."
  type        = string
}

variable "region" {
  description = "The Google Cloud region for the AlloyDB cluster."
  type        = string
}

variable "cluster_id" {
  description = "The ID of the AlloyDB cluster."
  type        = string
}

variable "instance_id" {
  description = "The ID of the AlloyDB instance."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
}

variable "backup_window" {
  description = "The backup window duration."
  type        = string
  default     = "1800s"
}

variable "backup_schedule" {
  description = "The weekly backup schedule."
  type        = object({
    days_of_week = list(string)
    start_time   = string
  })
}

variable "cpu_count" {
  description = "The number of CPUs for the AlloyDB instance."
  type        = number
  default     = 2
}
