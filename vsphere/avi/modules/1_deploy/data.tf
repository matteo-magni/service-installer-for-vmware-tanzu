data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_avi_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_avi_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_avi_compute_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_avi_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_folder" "folder" {
  path = var.vsphere_avi_folder
}

data "vsphere_content_library" "avi" {
  name = var.vsphere_content_library_avi
}

data "vsphere_content_library_item" "avi_controller" {
  name       = var.vsphere_content_library_item_avi
  type       = "ovf"
  library_id = data.vsphere_content_library.avi.id
}
