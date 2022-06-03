output "avi_admin_password" {
  value     = local.avi_password
  sensitive = true
}

output "avi_backup_passphrase" {
  value     = module.deploy.backup_passphrase
  sensitive = true
}
