# VCF 9.0.1 SDDC Manager Read-Only API Pipeline Check (Terraform)

This example is designed for **blog/demo usage** where you want a useful pipeline element that validates SDDC Manager API reachability, but does **not** mutate your environment.

It uses Terraform with the `hashicorp/http` provider to perform only `GET` requests:

- Required probe: `GET /v1/domains`
- Optional extra probes: any additional read-only API paths you provide

Because there are no resources and no `POST/PUT/PATCH/DELETE` calls, this behaves as a **non-destructive API health gate**.

## What this checks

1. `GET /v1/domains` returns HTTP `200`
2. At least `min_domains_expected` domains are visible
3. Any optional `additional_get_paths` you provide return a `2xx` status

## Prerequisites

- Terraform `>= 1.5.0`
- Network access to SDDC Manager API endpoint
- A bearer token that can read the endpoints

## Quick start

1. Copy the example vars file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your values.

3. Run:

```bash
terraform init
terraform validate
terraform plan
```

If checks pass, `terraform plan` succeeds and exits `0`.
If any check fails, `terraform plan` exits non-zero, which makes it useful in CI/CD as a gate.

## Example `terraform.tfvars`

```hcl
sddc_manager_url      = "https://sddc-manager.example.com"
bearer_token          = "REPLACE_WITH_TOKEN"
skip_tls_verify       = false
min_domains_expected  = 1
additional_get_paths  = []
```

Optional extra probes (if you want more than `/v1/domains`):

```hcl
additional_get_paths = [
  "/v1/tasks"
]
```

## Minimal CI pipeline stage example

```bash
#!/usr/bin/env bash
set -euo pipefail

cd examples/vcf-sddc-manager-readonly-terraform

terraform init -input=false
terraform validate
terraform plan -input=false -lock=false
```

### Why this is safe for a test-only gate

- No Terraform resources are declared
- Data source calls are read-only HTTP GET
- The pipeline succeeds/fails strictly on API response checks

