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
  default = "20.1.8"
}

variable "vsphere_user" {
  type      = string
  sensitive = true
}
variable "vsphere_password" {
  type      = string
  sensitive = true
}
variable "vsphere_server" {
  type = string
}
variable "vsphere_datacenter" {
  type = string
}
variable "avi_mgmt_network_name" {
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
