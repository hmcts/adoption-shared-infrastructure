# Application Insights Access Management
# This file manages external access to Application Insights for services that need to query logs

data "azurerm_application_insights" "main" {
  name                = module.application_insights_uksouth.name
  resource_group_name = azurerm_resource_group.rg.name
}

# Slack alerts function app needs to query Application Insights
# Function app is in a different subscription, so we reference it by its managed identity principal ID
# Only created in prod environment where the slack alerts function runs

# Grant access to the Log Analytics Workspace (required for querying logs)
resource "azurerm_role_assignment" "slack_alerts_monitoring_reader_workspace" {
  count = var.env == "prod" ? 1 : 0

  scope                = data.azurerm_application_insights.main.workspace_id
  role_definition_name = "Monitoring Reader"
  principal_id         = var.slack_alerts_principal_id

  description = "Allows slack alerts function app to query Application Insights workspace using Azure AD authentication"
}

# Also grant access to the Application Insights resource itself
resource "azurerm_role_assignment" "slack_alerts_monitoring_reader_appinsights" {
  count = var.env == "prod" ? 1 : 0

  scope                = data.azurerm_application_insights.main.id
  role_definition_name = "Monitoring Reader"
  principal_id         = var.slack_alerts_principal_id

  description = "Allows slack alerts function app to read Application Insights metadata"
}

