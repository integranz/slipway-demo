# Values rendered from .slipway/config.yaml. Change them with /slipway:bootstrap, then re-scaffold.
locals {
  project     = "adlc-demo"
  environment = "dev"
  location    = "westeurope"

  resource_group_name = "rg-adlc-demo-dev"
  acr_name            = "acradlcdemo"
  key_vault_name      = "kv-adlc-demo-dev"
  identity_name       = "id-adlc-demo-dev"
  log_analytics_name  = "log-adlc-demo-dev"
  cicd_principal_name = "sp-adlc-demo-github" # created by .slipway/setup-azure.sh

  tags = {
    project     = local.project
    environment = local.environment
    managed_by  = "terraform"
    generator   = "slipway"
  }
}
