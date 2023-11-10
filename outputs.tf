output "worker1_ips" {
  value       = module.workstation.*.public_ips
  description = "The ip of the workstation instances"
}
output "dns_worker1" {
  value = module.dns_workstation.*.name
}

