##### BEGIN DEPLOY VARIABLES #####

variable "vsphere_admin_user" {
  type        = string
  sensitive   = true
  description = "Username to connect as for deploying the AVI infrastructure"
}
variable "vsphere_admin_password" {
  type        = string
  sensitive   = true
  description = "`vsphere_admin_user`'s password"
}
variable "vsphere_admin_server" {
  type        = string
  description = "vCenter IP address or FQDN to connect to for deploying the AVI infrastructure"
}

variable "vsphere_avi_folder" {
  type        = string
  description = "VM folder for AVI"
}
variable "vsphere_avi_datacenter" {
  type        = string
  description = "Datacenter for AVI"
}
variable "vsphere_avi_datastore" {
  type        = string
  description = "Datastore for AVI"
}
variable "vsphere_avi_compute_cluster" {
  type        = string
  description = "Compute cluster for AVI"
}
variable "vsphere_avi_network" {
  type        = string
  description = "Network for AVI"
}

variable "avi_controller_network" {
  type = object({
    ip_address = string
    netmask    = string
    gateway    = string
  })
  description = "IPv4 network settings for AVI controller"
}
variable "avi_tenant" {
  type    = string
  default = "admin"
}
variable "avi_username" {
  type      = string
  sensitive = true
  default   = "admin"
}
variable "avi_default_password" {
  type        = string
  sensitive   = true
  description = "AVI default password (can be found in AVI downloads page). Do not disclose."
}
variable "avi_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "New password to be set or \"RANDOM\" for a random password or blank to keep the default"
}
variable "avi_version" {
  type        = string
  default     = "21.1.4"
  description = "Version of the AVI controller, it depends on the downloaded OVA."
}

variable "avi_ssl_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "SSL private key for the AVI portal (optional)"
}
variable "avi_ssl_certificate" {
  type        = string
  default     = ""
  description = "SSL certificate for the AVI portal (optional)"
}
variable "avi_ssl_cacerts" {
  type        = string
  default     = ""
  description = "SSL CA certificates for the AVI portal (optional)"
}

variable "avi_backup_passphrase" {
  type        = string
  default     = ""
  sensitive   = true
  description = "AVI backup passphrase. If not provided it will be randomly generated."
}

variable "avi_dns_domain" {
  type        = string
  default     = ""
  description = "AVI DNS search domain"
}
variable "avi_dns_servers_ipv4" {
  type        = set(string)
  description = "AVI DNS servers list"
}
variable "avi_ntp_servers_fqdn" {
  type = set(string)
  default = [
    "pool.ntp.org"
  ]
  description = "AVI NTP servers FQDN list"
}

variable "avi_session_timeout" {
  type        = number
  default     = 15
  description = "AVI UI session timeout"
}

variable "avi_license_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "AVI license key"
}
variable "avi_license_tier" {
  type        = string
  default     = "ESSENTIALS"
  description = "AVI license tier. Must be either ESSENTIALS or ENTERPRISE."

  validation {
    condition     = contains(["ESSENTIALS", "ENTERPRISE"], var.avi_license_tier)
    error_message = "Allowed values for avi_license_tier are \"ESSENTIALS\" or \"ENTERPRISE\"."
  }
}

variable "vsphere_content_library_avi" {
  type        = string
  default     = "ova"
  description = "Name of the content library that stores the AVI controller OVA"
}
variable "vsphere_content_library_item_avi" {
  type        = string
  default     = "avi-controller-21.1.4-9210"
  description = "Name of the AVi controller OVA in `vsphere_content_library_avi` content library"
}

##### END DEPLOY VARIABLES #####

##### BEGIN CONFIGURATION VARIABLES #####

variable "avi_cloud" {
  type    = string
  default = "vsphere"
}
variable "avi_license_type" {
  type    = string
  default = "LIC_CORES"
}

variable "vsphere_cloud_user" {
  type      = string
  sensitive = true
}
variable "vsphere_cloud_password" {
  type      = string
  sensitive = true
}
variable "vsphere_cloud_server" {
  type = string
}
variable "vsphere_cloud_datacenter" {
  type = string
}
variable "vsphere_cloud_network" {
  type = string
}

variable "avi_vip_network_name" {
  type = string
}
variable "avi_vip_network_addr" {
  type = string
}
variable "avi_vip_network_mask" {
  type = string
}
variable "avi_vip_network_gateway" {
  type = string
}
variable "avi_vip_network_begin" {
  type = string
}
variable "avi_vip_network_end" {
  type = string
}

variable "avi_se_network_name" {
  type = string
}
variable "avi_se_network_addr" {
  type = string
}
variable "avi_se_network_mask" {
  type = string
}
variable "avi_se_network_gateway" {
  type = string
}
variable "avi_se_network_begin" {
  type = string
}
variable "avi_se_network_end" {
  type = string
}

variable "se_name_prefix" {
  type    = string
  default = "Avi"
}
variable "avi_ha_mode" {
  type        = string
  default     = "HA_MODE_LEGACY_ACTIVE_STANDBY"
  description = "ha_mode: HA_MODE_LEGACY_ACTIVE_STANDBY (Active/Standby), HA_MODE_SHARED_PAIR (Active/Active), HA_MODE_SHARED (N+M)"
  validation {
    condition     = contains(["HA_MODE_LEGACY_ACTIVE_STANDBY", "HA_MODE_SHARED_PAIR", "HA_MODE_SHARED"], var.avi_ha_mode)
    error_message = "Acceptable values: HA_MODE_LEGACY_ACTIVE_STANDBY (Active/Standby), HA_MODE_SHARED_PAIR (Active/Active), HA_MODE_SHARED (N+M)"
  }
}
variable "vcpus_per_se" {
  type    = number
  default = 1
}
variable "memory_per_se" {
  type    = number
  default = 2048
}
variable "disk_per_se" {
  type    = number
  default = 15
}
variable "min_se" {
  type    = number
  default = 1
}
variable "max_se" {
  type    = number
  default = 6
}
variable "min_scaleout_per_vs" {
  type    = number
  default = 1
}
variable "max_scaleout_per_vs" {
  type    = number
  default = 4
}
variable "algo" {
  type    = string
  default = "PLACEMENT_ALGO_PACKED"
  validation {
    condition     = contains(["PLACEMENT_ALGO_PACKED", "PLACEMENT_ALGO_DISTRIBUTED"], var.algo)
    error_message = "Acceptable values: PLACEMENT_ALGO_PACKED, PLACEMENT_ALGO_DISTRIBUTED"
  }
}
variable "dedicated_dispatcher_core" {
  type    = string
  default = "false"
}
variable "se_vcenter_folder" {
  type    = string
  default = "AviSeFolder"
}
variable "se_vsphere_cluster" {
  type = string
}
variable "se_deprovision_delay" {
  type    = number
  default = 0
}
variable "buffer_se" {
  type    = number
  default = 0
}
variable "avi_serviceenginegroup_name" {
  type        = string
  default     = ""
  description = "Name of the default Service Engine Group to create. Empty string means it will be named after the cloud."
}

##### END CONFIGURATION VARIABLES

##### BEGIN VERIFY VARIABLES #####

variable "avi_dummy_vip" {
  type = string
}
variable "testvm_ip_cidr" {
  type = string
}
variable "testvm_gateway" {
  type = string
}
variable "testvm_dns_servers" {
  type = list(string)
}

variable "vsphere_folder_test" {
  type = string
}
variable "vsphere_datacenter_test" {
  type = string
}
variable "vsphere_datastore_test" {
  type = string
}
variable "vsphere_compute_cluster_test" {
  type = string
}
# variable "vsphere_host_test" {
#   type = string
# }
variable "vsphere_network_test" {
  type = string
}
variable "vsphere_content_library_ubuntu" {
  type        = string
  default     = "ova"
  description = "Name of the content library that stores the Ubuntu OVA"
}
variable "vsphere_content_library_item_ubuntu" {
  type        = string
  default     = "focal-server-cloudimg-amd64"
  description = "Name of the Ubuntu OVA in `vsphere_content_library_ubuntu` content library"
}

variable "static_mac_address" {
  type        = string
  default     = ""
  description = "Static MAC to apply to the test VM's NIC to prevent ARP caching issues when testing repeatedly"
}

##### END VERIFY VARIABLES #####
