variable "avi_cloud" {
  type    = string
  default = "vsphere"
}
variable "avi_tenant" {
  type    = string
  default = "admin"
}
variable "avi_username" {
  type      = string
  sensitive = true
}
variable "avi_password" {
  type      = string
  sensitive = true
}
variable "avi_controller" {
  type = string
}
variable "avi_version" {
  type    = string
  default = "21.1.4"
}
variable "avi_license_tier" {
  type    = string
  default = "ESSENTIALS"
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
variable "se_app_cache_percent" {
  type    = number
  default = 10
  validation {
    condition     = 0 <= var.se_app_cache_percent && var.se_app_cache_percent <= 100
    error_message = "Acceptable values are numbers between 0 and 100"
  }
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
  default = "PLACEMENT_ALGO_DISTRIBUTED"
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