# NS11MM Data Platform — Infrastructure as Code

Terraform modules for the NS11MM museum data platform. Provisions Snowflake warehouses, Azure Key Vault, Static Web Apps (dbt docs), monitoring alerts, and CI/CD pipelines.

## Repository Structure

```
terraform/
├── main.tf                          # Orchestrates all module deployments
├── variables.tf                     # All input variables with validation
├── outputs.tf                       # Root-level outputs
├── providers.tf                     # Provider config + backend state
├── modules/
│   ├── snowflake-warehouse/main.tf  # M01: Snowflake warehouse + resource monitor
│   ├── key-vault/main.tf            # M02: Azure Key Vault + access policies
│   ├── static-web-app/main.tf       # M03: dbt docs hosting
│   └── monitor-alerts/main.tf       # M04: Credit/pipeline alerts → Teams
├── environments/
│   ├── dev.tfvars.json              # Dev environment values
│   ├── staging.tfvars.json          # Staging environment values
│   └── prod.tfvars.json             # Production environment values
├── pipelines/
│   ├── deploy-dev.yml               # Azure Pipelines: auto-deploy on main merge
│   ├── deploy-staging.yml           # Azure Pipelines: manual trigger
│   └── deploy-prod.yml              # Azure Pipelines: manual trigger + approval gate
├── CODEOWNERS                       # All changes require JMYERS approval
└── README.md                        # This file
```

## Deployment Order

1. **M02 Key Vault** — deploy first (secrets must exist before anything else)
2. **M01 Snowflake Warehouse** — deploy with or after Key Vault
3. **M03 Static Web Apps** — after M01 + M02 confirmed
4. **M04 Monitor Alerts** — after M01 + M02 (references warehouse + Key Vault)

## Environment Promotion

```
dev (auto-deploy on merge to main)
 → staging (manual trigger, no approval gate)
   → prod (manual trigger + JMYERS approval required)
```

## Prerequisites

Before first deploy:

1. Create Azure resource group `rg-ns11mm-terraform` with a storage account for Terraform state
2. Create service connection `sc-ns11mm-terraform` in Azure DevOps with Contributor access
3. Create variable groups in Azure DevOps:
   - `ns11mm-terraform-dev` — subscription_id, tenant_id, snowflake_user, teams_webhook_url, SP object IDs
   - `ns11mm-terraform-staging` — same vars, staging values
   - `ns11mm-terraform-prod` — same vars, prod values
4. Mark sensitive variables (subscription_id, tenant_id, snowflake_user, teams_webhook_url) as secret

## Usage

```bash
# Initialize (from terraform/ directory)
terraform init

# Plan for dev
terraform plan -var-file=environments/dev.tfvars.json

# Apply to dev
terraform apply -var-file=environments/dev.tfvars.json

# Plan for prod (requires manual approval in pipeline)
terraform plan -var-file=environments/prod.tfvars.json
```

## Change Management

All changes to this repository are Tier 1 infrastructure changes per the NS11MM IaC policy:
- 72-hour advance notice required
- JMYERS written approval required
- Change Log entry required
- Post-deploy validation required
- No manual Azure Portal changes after prod deploy
