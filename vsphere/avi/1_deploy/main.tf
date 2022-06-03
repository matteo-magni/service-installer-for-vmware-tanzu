resource "random_string" "avi_controller_name" {
  length  = 4
  special = false
  lower   = true
  upper   = false
  number  = true
}

resource "tls_private_key" "avi_controller" {
  algorithm = "ED25519"
}

resource "vsphere_virtual_machine" "avi_controller" {
  name             = "${var.avi_controller_prefix}-${random_string.avi_controller_name.result}"
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
      "default-gw"          = var.avi_controller_network.gateway
      "mgmt-ip"             = var.avi_controller_network.ip_address
      "mgmt-mask"           = var.avi_controller_network.netmask
      "sysadmin-public-key" = tls_private_key.avi_controller.public_key_openssh
    }
  }
  lifecycle {
    ignore_changes = [
      vapp[0].properties
    ]
  }

  # wait for https endpoint to be available
  provisioner "local-exec" {
    command = "${path.module}/../scripts/wait_http.sh https://${var.avi_controller_network.ip_address} 200 ${var.avi_provisioning_timeout}"
  }

  # change user default password
  provisioner "local-exec" {
    command = "${path.module}/../scripts/avi.sh"
    environment = {
      AVI_METHOD   = "PUT"
      AVI_HOST     = var.avi_controller_network.ip_address
      AVI_USER     = var.avi_username
      AVI_PASS     = var.avi_default_password
      AVI_VERSION  = var.avi_version
      AVI_ENDPOINT = "useraccount"
      JSON_BODY = jsonencode({
        username     = var.avi_username
        password     = var.avi_password
        old_password = var.avi_default_password
      })
    }
  }
}
