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
variable "avi_controller_prefix" {
  type    = string
  default = "avi-controller"
}

variable "avi_controller_network" {
  type = object({
    ip_address = string
    netmask    = string
    gateway    = string
  })
}

variable "avi_provisioning_timeout" {
  type        = string
  default     = "20m"
  description = "Maximum time for AVI controller to be ready after VM creation"
}

variable "avi_default_password" {
  type        = string
  sensitive   = true
  description = "AVI default password (can be found in AVI downloads page). Do not disclose."
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