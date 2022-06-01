variable "avi_vip_network_name" {
  type = string
}
variable "avi_vip_network_addr" {
  type = string
}
variable "avi_vip_network_mask" {
  type = number
}
variable "avi_cloud" {
  type    = string
  default = "vsphere"
}
variable "avi_serviceenginegroup" {
  type    = string
  default = "default"
}
variable "avi_dummy_vip" {
  type = string
}
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

variable "testvm_ip_cidr" {
  type = string
}
variable "testvm_gateway" {
  type = string
}
variable "testvm_dns_servers" {
  type = list(string)
}
