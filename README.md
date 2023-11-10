# Azure-infra

This creates 1 AKS cluster and multiple ec2 instaces that connect to the AKS cluster. Each ec2 instance is setup with its own namespace.

[Istio Install](https://istio.io/latest/docs/setup/install/istioctl/)
[Istio Getting Started](https://istio.io/latest/docs/setup/getting-started/)
[Kubernetes CheatSheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | =3.64.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.64.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns_workstation"></a> [dns\_workstation](#module\_dns\_workstation) | git::https://github.com/DevOpsPlayground/terraform_modules.git//dns | n/a |
| <a name="module_network"></a> [network](#module\_network) | git::https://github.com/DevOpsPlayground/terraform_modules.git//network | n/a |
| <a name="module_workstation"></a> [workstation](#module\_workstation) | git::https://github.com/DevOpsPlayground/terraform_modules.git//instance | n/a |
| <a name="module_ws-admin"></a> [ws-admin](#module\_ws-admin) | git::https://github.com/DevOpsPlayground/terraform_modules.git//instance | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.64.0/docs/resources/kubernetes_cluster) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.64.0/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_deploy_count"></a> [aks\_deploy\_count](#input\_aks\_deploy\_count) | n/a | `any` | n/a | yes |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | Name of AMI to be used | `string` | `"CentOS-8-ec2-8.2.2004-20200923-1.*"` | no |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | Account number of AMI owner | `string` | `"679593333241"` | no |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | n/a | `any` | n/a | yes |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | n/a | `any` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Your own registered domain name if using dns module | `string` | `"devopsplayground.org"` | no |
| <a name="input_ec2_deploy_count"></a> [ec2\_deploy\_count](#input\_ec2\_deploy\_count) | Change this for the number of users of the playground | `number` | `1` | no |
| <a name="input_instance_role"></a> [instance\_role](#input\_instance\_role) | The Role of the instance to take | `number` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | instance type to be used for instances | `string` | `"t2.medium"` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | number of instances per dns record | `number` | `1` | no |
| <a name="input_playground_git_url"></a> [playground\_git\_url](#input\_playground\_git\_url) | URL to the Playground. Will be cloned onto each node. | `string` | n/a | yes |
| <a name="input_playground_name"></a> [playground\_name](#input\_playground\_name) | The playground name to tag all resouces with | `string` | `"Azure_Playground_2023"` | no |
| <a name="input_policy_location"></a> [policy\_location](#input\_policy\_location) | The location of the policys | `string` | `"./policies"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `any` | n/a | yes |
| <a name="input_script_location"></a> [script\_location](#input\_script\_location) | The location of the userData folder | `string` | `"./files"` | no |
| <a name="input_ssh_password"></a> [ssh\_password](#input\_ssh\_password) | SSH password to log into into the instances | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | n/a | `any` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_worker1"></a> [dns\_worker1](#output\_dns\_worker1) | n/a |
| <a name="output_worker1_ips"></a> [worker1\_ips](#output\_worker1\_ips) | The ip of the workstation instances |
<!-- END_TF_DOCS -->