variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type = string
}

variable "vsphere_server" {
  type = string
}

variable "vsphere_folder" {
  type = string
}

variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_datastore" {
  type = string
}

variable "vsphere_compute_cluster" {
  type = string
}

variable "vsphere_host" {
  type = string
}

variable "vsphere_network" {
  type    = string
  default = "VM Network"
}

variable "avi_controller_prefix" {
  type    = string
  default = "avi-controller"
}

variable "avi_ipaddress" {
  type = string
}

variable "avi_netmask" {
  type = string
}

variable "avi_gateway" {
  type = string
}

variable "avi_provisioning_timeout" {
  type        = string
  default     = "20m"
  description = "Maximum time for AVI controller to be ready after VM creation"
}

variable "avi_default_password" {
  type = string
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

variable "avi_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "New password to be set or \"RANDOM\" for a random password or blank to keep the default"
}

variable "avi_version" {
  type    = string
  default = "21.1.4"
}

variable "avi_ssl_key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "avi_ssl_certificate" {
  type    = string
  default = ""
}

variable "avi_ssl_cacerts" {
  type    = string
  default = ""
}

variable "avi_backup_passphrase" {
  type      = string
  default   = ""
  sensitive = true
}

variable "avi_dns_domain" {
  type    = string
  default = ""
}

variable "avi_dns_servers_ipv4" {
  type = set(string)
}

variable "avi_ntp_servers_fqdn" {
  type = set(string)
  default = [
    "pool.ntp.org"
  ]
}

variable "avi_session_timeout" {
  type    = number
  default = 15
}

variable "avi_license_key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "avi_license_tier" {
  type    = string
  default = "ESSENTIALS"

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