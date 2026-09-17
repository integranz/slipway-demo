# Values rendered from .slipway/config.yaml for app `api`. Change them with /slipway:bootstrap, then re-scaffold.
locals {
  project     = "adlc-demo"
  environment = "dev"
  app         = "api"

  resource_group_name = "rg-adlc-demo-dev"
  acr_name            = "acradlcdemo"
  key_vault_name      = "kv-adlc-demo-dev"
  identity_name       = "id-adlc-demo-dev"
  cae_name            = "cae-adlc-demo-dev"

  tags = {
    project     = local.project
    environment = local.environment
    managed_by  = "terraform"
    layer       = "app"
    generator   = "slipway"
  }
}
