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
  source = "./modules/1_deploy"
  providers = {
    vsphere = vsphere.admin
  }

  vsphere_admin_user     = var.vsphere_admin_user
  vsphere_admin_password = var.vsphere_admin_password
  vsphere_admin_server   = var.vsphere_admin_server

  vsphere_avi_folder          = var.vsphere_avi_folder
  vsphere_avi_datacenter      = var.vsphere_avi_datacenter
  vsphere_avi_datastore       = var.vsphere_avi_datastore
  vsphere_avi_compute_cluster = var.vsphere_avi_compute_cluster
  vsphere_avi_network         = var.vsphere_avi_network

  avi_controller_network           = var.avi_controller_network
  avi_default_password             = var.avi_default_password
  avi_tenant                       = var.avi_tenant
  avi_username                     = var.avi_username
  avi_password                     = local.avi_password
  avi_version                      = var.avi_version
  avi_ssl_key                      = var.avi_ssl_key
  avi_ssl_certificate              = var.avi_ssl_certificate
  avi_ssl_cacerts                  = var.avi_ssl_cacerts
  avi_backup_passphrase            = var.avi_backup_passphrase
  avi_dns_domain                   = var.avi_dns_domain
  avi_dns_servers_ipv4             = var.avi_dns_servers_ipv4
  avi_ntp_servers_fqdn             = var.avi_ntp_servers_fqdn
  avi_session_timeout              = var.avi_session_timeout
  avi_license_key                  = var.avi_license_key
  avi_license_tier                 = var.avi_license_tier
  vsphere_content_library_avi      = var.vsphere_content_library_avi
  vsphere_content_library_item_avi = var.vsphere_content_library_item_avi
}

module "configuration" {
  source = "./modules/2_configuration"

  depends_on = [
    module.deploy
  ]

  providers = {
    vsphere = vsphere.cloud
  }

  vsphere_cloud_user       = var.vsphere_cloud_user
  vsphere_cloud_password   = var.vsphere_cloud_password
  vsphere_cloud_server     = var.vsphere_cloud_server
  vsphere_cloud_datacenter = var.vsphere_cloud_datacenter
  vsphere_cloud_network    = var.vsphere_cloud_network

  avi_cloud        = var.avi_cloud
  avi_tenant       = var.avi_tenant
  avi_username     = var.avi_username
  avi_password     = local.avi_password
  avi_controller   = var.avi_controller_network.ip_address
  avi_version      = var.avi_version
  avi_license_tier = var.avi_license_tier
  avi_license_type = var.avi_license_type

  avi_vip_network_name    = var.avi_vip_network_name
  avi_vip_network_addr    = var.avi_vip_network_addr
  avi_vip_network_mask    = var.avi_vip_network_mask
  avi_vip_network_gateway = var.avi_vip_network_gateway
  avi_vip_network_begin   = var.avi_vip_network_begin
  avi_vip_network_end     = var.avi_vip_network_end

  avi_se_network_name    = var.avi_se_network_name
  avi_se_network_addr    = var.avi_se_network_addr
  avi_se_network_mask    = var.avi_se_network_mask
  avi_se_network_gateway = var.avi_se_network_gateway
  avi_se_network_begin   = var.avi_se_network_begin
  avi_se_network_end     = var.avi_se_network_end

  avi_ha_mode               = var.avi_ha_mode
  vcpus_per_se              = var.vcpus_per_se
  memory_per_se             = var.memory_per_se
  disk_per_se               = var.disk_per_se
  min_se                    = var.min_se
  max_se                    = var.max_se
  min_scaleout_per_vs       = var.min_scaleout_per_vs
  max_scaleout_per_vs       = var.max_scaleout_per_vs
  algo                      = var.algo
  dedicated_dispatcher_core = var.dedicated_dispatcher_core
  se_vcenter_folder         = var.se_vcenter_folder
  se_vsphere_cluster        = var.se_vsphere_cluster
  se_deprovision_delay      = var.se_deprovision_delay
  buffer_se                 = var.buffer_se
}

module "verify" {
  source = "./modules/3_verify"
  count  = var.run_test ? 1 : 0

  depends_on = [
    module.configuration
  ]

  providers = {
    vsphere = vsphere.cloud
  }

  avi_cloud                 = var.avi_cloud
  avi_vfr_context_vip_id    = module.configuration.avi_vfr_context_vip_id
  avi_network_vip_id        = module.configuration.avi_network_vip_id
  avi_serviceenginegroup_id = module.configuration.avi_serviceenginegroup_id

  avi_dummy_vip        = var.avi_dummy_vip
  avi_vip_network_addr = var.avi_vip_network_addr
  avi_vip_network_mask = var.avi_vip_network_mask

  testvm_dns_servers = var.testvm_dns_servers
  testvm_gateway     = var.testvm_gateway
  testvm_ip_cidr     = var.testvm_ip_cidr

  vsphere_datacenter_test             = var.vsphere_datacenter_test
  vsphere_datastore_test              = var.vsphere_datastore_test
  vsphere_compute_cluster_test        = var.vsphere_compute_cluster_test
  vsphere_network_test                = var.vsphere_network_test
  vsphere_folder_test                 = var.vsphere_folder_test
  vsphere_content_library_ubuntu      = var.vsphere_content_library_ubuntu
  vsphere_content_library_item_ubuntu = var.vsphere_content_library_item_ubuntu

  static_mac_address = var.static_mac_address
}