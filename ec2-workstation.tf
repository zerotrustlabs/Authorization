module "network" {
  count          = 1 // Keep as one otherwise a new vpc will be deployed for each instance. 
  source         = "git::https://github.com/DevOpsPlayground/terraform_modules.git//network"
  PlaygroundName = var.playground_name
}

module "ws-admin" {
  count              = var.aks_deploy_count
  source             = "git::https://github.com/DevOpsPlayground/terraform_modules.git//instance"
  PlaygroundName     = "admin-Workstation"
  security_group_ids = [module.network.0.allow_all_security_group_id]
  subnet_id          = module.network.0.public_subnets.0
  instance_type      = var.instance_type

  user_data = templatefile(
    "${var.script_location}/admin.sh",
    {
      hostname    = "playground"
      username    = "playground"
      ssh_pass    = var.ssh_password
      region      = var.region
      gitrepo     = "${var.playground_git_url}"
      panda_name  = "admin-panda"
      cube_config = azurerm_kubernetes_cluster.this[0].kube_config_raw
      exports     = templatefile("./files/exports", {})
    }
  )

  amiName  = "amzn2-ami-hvm-*"
  amiOwner = "137112412989"
}

module "workstation" {
  count              = var.ec2_deploy_count
  source             = "git::https://github.com/DevOpsPlayground/terraform_modules.git//instance"
  PlaygroundName     = "${element(local.adj, count.index)}-panda-${var.playground_name}-Workstation"
  security_group_ids = [module.network.0.allow_all_security_group_id]
  subnet_id          = module.network.0.public_subnets.0
  instance_type      = var.instance_type

  user_data = templatefile(
    "${var.script_location}/user_data_amzn.sh",
    {
      hostname    = "playground"
      username    = "playground"
      ssh_pass    = var.ssh_password
      region      = var.region
      gitrepo     = "${var.playground_git_url}"
      panda_name  = "${element(local.adj, count.index)}-panda"
      cube_config = azurerm_kubernetes_cluster.this[0].kube_config_raw
      exports     = templatefile("./files/exports", {})
    }
  )

  amiName  = "amzn2-ami-hvm-*"
  amiOwner = "137112412989"
}

module "dns_workstation" {
  count        = var.ec2_deploy_count
  source       = "git::https://github.com/DevOpsPlayground/terraform_modules.git//dns"
  instances    = var.instances
  instance_ips = element(module.workstation.*.public_ips, count.index)
  domain_name  = var.domain_name
  record_name  = "${element(local.adj, count.index)}-panda"
}