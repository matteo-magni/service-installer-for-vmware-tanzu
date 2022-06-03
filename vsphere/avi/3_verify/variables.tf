variable "avi_cloud" {
  type = string
}
variable "avi_vfr_context_vip_id" {
  type = string
}
variable "avi_network_vip_id" {
  type = string
}
variable "avi_serviceenginegroup_id" {
  type = string
}

variable "avi_dummy_vip" {
  type = string
}
variable "avi_vip_network_addr" {
  type = string
}
variable "avi_vip_network_mask" {
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
  type    = string
  default = "VM Network"
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
