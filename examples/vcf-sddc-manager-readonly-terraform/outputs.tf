output "domains_count" {
  description = "Number of workload/management domains visible to the token."
  value       = local.domains_count
}

output "domains_status_code" {
  description = "HTTP status code from GET /v1/domains."
  value       = data.http.vcf_domains.status_code
}

output "additional_probe_status_codes" {
  description = "HTTP status codes per additional GET path."
  value       = local.probe_status_codes
}
