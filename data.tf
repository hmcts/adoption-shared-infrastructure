data "azurerm_user_assigned_identity" "jenkins" {
  name                = "jenkins-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}

data "azurerm_key_vault_secret" "adoption_support_email_secret" {
  name         = "${var.product}-support-email"
  key_vault_id = module.key-vault.key_vault_id
}
