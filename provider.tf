provider "azurerm" {
  features {}

  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

# provider "kubernetes" {
#   host                   = try(azurerm_kubernetes_cluster.wale[0].kube_config[0].host, "")
#   client_certificate     = try(base64decode(azurerm_kubernetes_cluster.wale[0].kube_config[0].client_certificate), "")
#   client_key             = try(base64decode(azurerm_kubernetes_cluster.wale[0].kube_config[0].client_key), "")
#   cluster_ca_certificate = try(base64decode(azurerm_kubernetes_cluster.wale[0].kube_config[0].cluster_ca_certificate), "")
# }

# provider "helm" {
#   kubernetes {
#     host                   = try(azurerm_kubernetes_cluster.wale[0].kube_config[0].host, "")
#     client_certificate     = try(base64decode(azurerm_kubernetes_cluster.wale[0].kube_config[0].client_certificate), "")
#     client_key             = try(base64decode(azurerm_kubernetes_cluster.wale[0].kube_config[0].client_key), "")
#     cluster_ca_certificate = try(base64decode(azurerm_kubernetes_cluster.wale[0].kube_config[0].cluster_ca_certificate), "")
#   }
# }

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.64.0"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "devops-playground-ldn"
    workspaces {
      name = "Azure-infra"
    }
  }
}