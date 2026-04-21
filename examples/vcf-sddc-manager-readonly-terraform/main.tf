locals {
  normalized_base_url = trimsuffix(var.sddc_manager_url, "/")
}

data "http" "vcf_domains" {
  url = "${local.normalized_base_url}/v1/domains"

  request_headers = {
    Accept        = "application/json"
    Authorization = "Bearer ${var.bearer_token}"
  }

  insecure = var.skip_tls_verify
}

data "http" "probe" {
  for_each = toset(var.additional_get_paths)

  url = "${local.normalized_base_url}${each.value}"

  request_headers = {
    Accept        = "application/json"
    Authorization = "Bearer ${var.bearer_token}"
  }

  insecure = var.skip_tls_verify
}

locals {
  # VCF domain list normally returns {"elements":[...], ...}
  domains_response = jsondecode(data.http.vcf_domains.response_body)
  domains_count    = try(length(local.domains_response.elements), 0)

  probe_status_codes = {
    for path, result in data.http.probe :
    path => result.status_code
  }

  failed_probes = {
    for path, code in local.probe_status_codes :
    path => code
    if code < 200 || code > 299
  }
}

check "domains_endpoint_reachable" {
  assert {
    condition     = data.http.vcf_domains.status_code == 200
    error_message = "GET /v1/domains did not return HTTP 200."
  }
}

check "minimum_domains_present" {
  assert {
    condition     = local.domains_count >= var.min_domains_expected
    error_message = "Expected at least ${var.min_domains_expected} domain(s), found ${local.domains_count}."
  }
}

check "optional_paths_healthy" {
  assert {
    condition     = length(local.failed_probes) == 0
    error_message = "One or more additional GET probes failed: ${jsonencode(local.failed_probes)}"
  }
}
