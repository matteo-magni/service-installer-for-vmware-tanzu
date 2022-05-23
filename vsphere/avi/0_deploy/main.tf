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

data "vsphere_content_library" "ova" {
  name = "ova"
}

data "vsphere_content_library_item" "avi_controller" {
  name       = "avi-controller-21.1.4-9210"
  type       = "ovf"
  library_id = data.vsphere_content_library.ova.id
}

# resource "vsphere_content_library_item" "avi_controller" {
#   name       = "avi-controller-21.1.4-9210"
#   type       = "ovf"
#   library_id = data.vsphere_content_library.ova.id
# }

resource "vsphere_virtual_machine" "avi_controller" {
  name             = local.avi_controller_name
  resource_pool_id = data.vsphere_resource_pool.default.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = trimprefix(data.vsphere_folder.folder.path, "/${data.vsphere_datacenter.datacenter.name}/vm")

  num_cpus = 8
  memory   = 24576
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label            = "disk0"
    size             = 128
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_content_library_item.avi_controller.id
  }
  vapp {
    properties = {
      "default-gw"          = var.avi_gateway
      "mgmt-ip"             = var.avi_ipaddress
      "mgmt-mask"           = var.avi_netmask
      "sysadmin-public-key" = tls_private_key.avi_controller.public_key_openssh
    }
  }
  lifecycle {
    ignore_changes = [
      vapp[0].properties
    ]
  }

}

resource "null_resource" "wait_for_avi_controller" {
  provisioner "local-exec" {
    command = "../scripts/wait_for_avi_controller.sh https://${var.avi_ipaddress} 200 ${var.avi_controller_provisioning_timeout}"
  }

  depends_on = [
    vsphere_virtual_machine.avi_controller
  ]

  lifecycle {
    # wait again if the virtual machine get recreated
    # replace_triggered_by is a new lifecycle argument as of terraform v1.2.0
    replace_triggered_by = [
      vsphere_virtual_machine.avi_controller
    ]
  }
}

locals {
  newpassword_body = {
    username     = var.avi_username
    password     = var.avi_password
    old_password = var.avi_default_password
  }
}
resource "null_resource" "change_admin_password" {
  provisioner "local-exec" {
    command = "../scripts/avi.sh"
    environment = {
      AVI_METHOD   = "PUT"
      AVI_HOST     = var.avi_ipaddress
      AVI_USER     = var.avi_username
      AVI_PASS     = var.avi_default_password
      AVI_VERSION  = var.avi_version
      AVI_ENDPOINT = "useraccount"
      JSON_BODY    = jsonencode(local.newpassword_body)
    }
  }

  depends_on = [
    null_resource.wait_for_avi_controller
  ]
  lifecycle {
    replace_triggered_by = [
      vsphere_virtual_machine.avi_controller
    ]
  }
}
