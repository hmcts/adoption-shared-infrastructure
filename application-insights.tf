module "application_insights" {
  source = "git@github.com:hmcts/terraform-module-application-insights?ref=4.x"

  env     = var.env
  product = var.product
  name    = var.product

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.appinsights_location
  alert_location      = var.appinsights_location
  common_tags         = var.common_tags
  sampling_percentage = contains(["demo"], lower(var.env)) ? 100 : null
}

module "application_insights_uksouth" {
  source = "git@github.com:hmcts/terraform-module-application-insights?ref=4.x"

  env     = var.env
  product = var.product
  name    = "${var.product}-appinsights-uksouth"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  alert_location      = var.alert_location
  common_tags         = var.common_tags

  # Capture full telemetry on the lower environments used for diagnosis (demo)
  # so failures (failed requests, 5xx, exceptions) are not dropped by the module's default
  # non-prod ingestion sampling of 1%, which blocks diagnosis. Remaining environments keep the
  # module defaults (prod = 100%, other non-prod = 1%)
  sampling_percentage = contains(["demo"], lower(var.env)) ? 100 : null
}

moved {
  from = azurerm_application_insights.appinsights
  to   = module.application_insights_uksouth.azurerm_application_insights.this
}

resource "azurerm_key_vault_secret" "appInsights-InstrumentationKey" {
  name         = "AppInsightsInstrumentationKey"
  value        = module.application_insights_uksouth.instrumentation_key
  key_vault_id = module.adoption-app-vault.key_vault_id
}

module "application_insights_preview" {
  count  = var.env == "aat" ? 1 : 0
  source = "git@github.com:hmcts/terraform-module-application-insights?ref=4.x"

  env     = "preview"
  product = var.product
  name    = "${var.product}-appinsights"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.appinsights_location
  alert_location      = var.appinsights_location

  common_tags = var.common_tags
}

moved {
  from = azurerm_application_insights.appinsights_preview[0]
  to   = module.application_insights_preview[0].azurerm_application_insights.this
}
resource "azurerm_key_vault_secret" "AZURE_APPINSIGHTS_KEY_PREVIEW" {
  name         = "AppInsightsInstrumentationKey-Preview-New"
  value        = module.application_insights_preview_uksouth[0].instrumentation_key
  key_vault_id = module.adoption-app-vault.key_vault_id
  count        = var.env == "aat" ? 1 : 0
}

module "application_insights_preview_uksouth" {
  count  = var.env == "aat" ? 1 : 0
  source = "git@github.com:hmcts/terraform-module-application-insights?ref=4.x"

  env     = "preview"
  product = var.product
  name    = "${var.product}-appinsights-uksouth"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  alert_location      = var.appinsights_location

  common_tags = var.common_tags
}

moved {
  from = azurerm_application_insights.appinsights_preview_uksouth[0]
  to   = module.application_insights_preview_uksouth[0].azurerm_application_insights.this
}
