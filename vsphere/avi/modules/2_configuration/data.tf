data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_cloud_datacenter
}

data "vsphere_compute_cluster" "se" {
  name          = var.se_vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
