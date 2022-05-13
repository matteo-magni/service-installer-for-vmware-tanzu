resource "random_string" "avi_controller_name" {
  length  = 4
  special = false
  lower   = true
  upper   = false
  number  = true
}

locals {
  avi_controller_name = "${var.avi_controller_prefix}-${random_string.avi_controller_name.id}"
}

resource "tls_private_key" "avi_controller" {
  algorithm = "ED25519"
}

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

## Local OVF/OVA Source
# data "vsphere_ovf_vm_template" "ovfLocal" {
#   name              = "${local.avi_controller_name}_template"
#   disk_provisioning = "thin"
#   resource_pool_id  = data.vsphere_resource_pool.default.id
#   datastore_id      = data.vsphere_datastore.datastore.id
#   host_system_id    = data.vsphere_host.host.id
#   local_ovf_path    = var.local_ovf_path
#   ovf_network_map = {
#     "VM Network" : data.vsphere_network.network.id
#   }
# }

# ## Deployment of VM from Local OVF
# resource "vsphere_virtual_machine" "vmFromLocalOvf" {
#   name                 = local.avi_controller_name
#   folder               = trimprefix(data.vsphere_folder.folder.path, "/${data.vsphere_datacenter.datacenter.name}/vm")
#   datacenter_id        = data.vsphere_datacenter.datacenter.id
#   datastore_id         = data.vsphere_datastore.datastore.id
#   host_system_id       = data.vsphere_host.host.id
#   resource_pool_id     = data.vsphere_resource_pool.default.id
#   num_cpus             = data.vsphere_ovf_vm_template.ovfLocal.num_cpus
#   num_cores_per_socket = data.vsphere_ovf_vm_template.ovfLocal.num_cores_per_socket
#   memory               = data.vsphere_ovf_vm_template.ovfLocal.memory
#   guest_id             = data.vsphere_ovf_vm_template.ovfLocal.guest_id
#   scsi_type            = data.vsphere_ovf_vm_template.ovfLocal.scsi_type
#   nested_hv_enabled    = data.vsphere_ovf_vm_template.ovfLocal.nested_hv_enabled
#   dynamic "network_interface" {
#     for_each = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map
#     content {
#       network_id = network_interface.value
#     }
#   }
#   wait_for_guest_net_timeout = 0
#   wait_for_guest_ip_timeout  = 0
#   ovf_deploy {
#     allow_unverified_ssl_cert = false
#     local_ovf_path            = data.vsphere_ovf_vm_template.ovfLocal.local_ovf_path
#     disk_provisioning         = data.vsphere_ovf_vm_template.ovfLocal.disk_provisioning
#     ovf_network_map           = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map
#   }
#   vapp {
#     properties = {
#       "avi.default-gw" = var.avi_gateway,
#       "avi.hostname" = local.avi_controller_name,
#       "avi.mgmt-ip" = var.avi_ipaddress,
#       "avi.mgmt-mask" = var.avi_netmask,
#       "avi.nsx-t-auth-token" = "",
#       "avi.nsx-t-ip" = "",
#       "avi.nsx-t-node-id" = "",
#       "avi.nsx-t-thumbprint" = "",
#       "avi.sysadmin-public-key" = tls_private_key.avi_controller.public_key_openssh,
#     }
#   }
#   lifecycle {
#     ignore_changes = [
#       annotation,
#       disk[0].io_share_count,
#       disk[1].io_share_count,
#       disk[2].io_share_count,
#       vapp[0].properties,
#     ]
#   }
# }