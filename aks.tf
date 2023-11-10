resource "azurerm_resource_group" "this" {
  name     = "devops_playground_2023"
  location = "UK South"
}

resource "azurerm_kubernetes_cluster" "this" {
  count               = var.aks_deploy_count
  name                = "cool-panda-aks"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "cool-panda-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_B4ms" # https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  role_based_access_control_enabled = true

  tags = {
    Owner = "DevOps Playground 2023"
  }

}