variable "sddc_manager_url" {
  description = "Base URL for SDDC Manager, e.g. https://sddc-manager.lab.local"
  type        = string
}

variable "bearer_token" {
  description = "Bearer token for SDDC Manager API authentication"
  type        = string
  sensitive   = true
}

variable "skip_tls_verify" {
  description = "Set true only for labs with self-signed certs"
  type        = bool
  default     = false
}

variable "min_domains_expected" {
  description = "Minimum number of workload/management domains expected"
  type        = number
  default     = 1
}

variable "additional_get_paths" {
  description = "Additional read-only API paths to probe with GET"
  type        = list(string)
  default     = []
}
