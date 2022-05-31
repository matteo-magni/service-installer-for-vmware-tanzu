output "private_key_openssh" {
  value     = tls_private_key.avi_controller.private_key_openssh
  sensitive = true
}

output "backup_passphrase" {
  value     = local.backup_passphrase
  sensitive = true
}

output "avi_config" {
  sensitive = true
  value = {
    avi_username   = var.avi_username
    avi_tenant     = var.avi_tenant
    avi_password   = local.avi_password
    avi_controller = var.avi_ipaddress
    avi_version    = var.avi_version
  }
}