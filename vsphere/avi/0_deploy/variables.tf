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

variable "local_ovf_path" {
  type = string
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
variable "avi_controller_provisioning_timeout" {
  type = string
  default = "20m"
  description = "Maximum time for AVI controller to be ready after VM creation"
}