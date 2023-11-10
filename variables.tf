variable "client_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "region" {}
variable "aks_deploy_count" {}

variable "playground_name" {
  type        = string
  default     = "Azure_Playground_2023"
  description = "The playground name to tag all resouces with"
}
variable "instances" {
  type        = number
  default     = 1
  description = "number of instances per dns record"
}
variable "domain_name" {
  type        = string
  default     = "devopsplayground.org"
  description = "Your own registered domain name if using dns module"
}

// PLEASE TAKE CARE WHEN EDITING THIS DUE TO COSTS. 

variable "ec2_deploy_count" {
  type        = number
  description = "Change this for the number of users of the playground"
  default     = 1
}
variable "instance_role" {
  type        = number
  default     = null
  description = "The Role of the instance to take"
}
variable "instance_type" {
  type        = string
  description = "instance type to be used for instances"
  default     = "t2.medium"
}
variable "script_location" {
  type        = string
  default     = "./files"
  description = "The location of the userData folder"
}
variable "policy_location" {
  type        = string
  default     = "./policies"
  description = "The location of the policys"
}
variable "ssh_password" {
  type        = string
  description = "SSH password to log into into the instances"
}

variable "playground_git_url" {
  type        = string
  description = "URL to the Playground. Will be cloned onto each node."
}

variable "ami_name" {
  type        = string
  default     = "CentOS-8-ec2-8.2.2004-20200923-1.*"
  description = "Name of AMI to be used"
}

variable "ami_owner" {
  type        = string
  default     = "679593333241"
  description = "Account number of AMI owner"
}