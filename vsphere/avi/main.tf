locals {
  avi_password = var.avi_password == "" ? var.avi_default_password : (var.avi_password == "RANDOM" ? random_password.avi_password.result : var.avi_password)
}

resource "random_password" "avi_password" {
  length  = 32
  special = true
  lower   = true
  upper   = true
  number  = true
}

module "deploy" {
  source = "./1_deploy"
  providers = {
    vsphere = vsphere
    avi = avi
   }

  vsphere_admin_user = var.vsphere_admin_user
  vsphere_admin_password = var.vsphere_admin_password
  vsphere_admin_server = var.vsphere_admin_server

  vsphere_avi_folder = var.vsphere_avi_folder
  vsphere_avi_datacenter = var.vsphere_avi_datacenter
  vsphere_avi_datastore = var.vsphere_avi_datastore
  vsphere_avi_compute_cluster = var.vsphere_avi_compute_cluster
  vsphere_avi_network = var.vsphere_avi_network

  avi_controller_network = var.avi_controller_network
  avi_default_password = var.avi_default_password
  avi_tenant = var.avi_tenant
  avi_username = var.avi_username
  avi_password = local.avi_password
  avi_version = var.avi_version
  avi_ssl_key = var.avi_ssl_key
  avi_ssl_certificate = var.avi_ssl_certificate
  avi_ssl_cacerts = var.avi_ssl_cacerts
  avi_backup_passphrase = var.avi_backup_passphrase
  avi_dns_domain = var.avi_dns_domain
  avi_dns_servers_ipv4 = var.avi_dns_servers_ipv4
  avi_ntp_servers_fqdn = var.avi_ntp_servers_fqdn
  avi_session_timeout = var.avi_session_timeout
  avi_license_key = var.avi_license_key
  avi_license_tier = var.avi_license_tier
  vsphere_content_library_avi = var.vsphere_content_library_avi
  vsphere_content_library_item_avi = var.vsphere_content_library_item_avi
}

# module "configuration" {
#   source = "./2_configuration"

#   depends_on = [
#     module.deploy
#   ]

#   vsphere_cloud_user = var.vsphere_admin_user
#   vsphere_cloud_password = var.vsphere_admin_password
#   vsphere_cloud_server = var.vsphere_admin_server


# }

# module "verify" {
#   source = "./3_verify"

#   depends_on = [
#     module.configuration
#   ]
# }