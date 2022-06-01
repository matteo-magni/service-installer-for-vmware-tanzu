data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_compute_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_folder" "folder" {
  path = var.vsphere_folder
}

data "vsphere_content_library" "ubuntu" {
  name = var.vsphere_content_library_ubuntu
}

data "vsphere_content_library_item" "ubuntu" {
  name       = var.vsphere_content_library_item_ubuntu
  library_id = data.vsphere_content_library.ubuntu.id
  type       = "ovf"
}

data "avi_cloud" "cloud" {
  name = var.avi_cloud
}

data "avi_serviceenginegroup" "group" {
  name = var.avi_serviceenginegroup
}

data "avi_network" "vip" {
  name      = var.avi_vip_network_name
  cloud_ref = data.avi_cloud.cloud.id
}

data "avi_applicationprofile" "l4" {
  name = "System-L4-Application"
}
