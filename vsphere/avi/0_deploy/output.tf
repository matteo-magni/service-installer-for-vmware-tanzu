output "private_key_openssh" {
  value     = tls_private_key.avi_controller.private_key_openssh
  sensitive = true
}

output "backup_passphrase" {
  value     = local.backup_passphrase
  sensitive = true
}