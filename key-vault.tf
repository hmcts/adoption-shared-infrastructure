module "adoption-app-vault" {
  source                     = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                       = "${var.product}-${var.env}"
  product                    = var.product
  env                        = var.env
  tenant_id                  = var.tenant_id
  object_id                  = var.jenkins_AAD_objectId
  resource_group_name        = azurerm_resource_group.rg.name
  product_group_name         = "DTS Adoption"
  common_tags                = local.tags
  create_managed_identity    = true
  // managed_identity_object_id = var.managed_identity_object_id
}

output "vaultName" {
  value = module.adoption-app-vault.key_vault_name
}