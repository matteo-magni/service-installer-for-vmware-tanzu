data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter_test
}
data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore_test
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_compute_cluster_test
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# data "vsphere_host" "host" {
#   name          = var.vsphere_host
#   datacenter_id = data.vsphere_datacenter.datacenter.id
# }

data "vsphere_network" "network" {
  name          = var.vsphere_network_test
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_folder" "folder" {
  path = var.vsphere_folder_test
}

data "vsphere_content_library" "ubuntu" {
  name = var.vsphere_content_library_ubuntu
}

data "vsphere_content_library_item" "ubuntu" {
  name       = var.vsphere_content_library_item_ubuntu
  library_id = data.vsphere_content_library.ubuntu.id
  type       = "ovf"
}

data "avi_cloud" "vsphere" {
  name = var.avi_cloud
}
data "avi_applicationprofile" "l4" {
  name = "System-L4-Application"
}
