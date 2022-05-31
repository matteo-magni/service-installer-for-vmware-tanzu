resource "avi_pool" "dummy" {
  name      = "dummy"
  cloud_ref = data.avi_cloud.cloud.id
  vrf_ref   = data.avi_network.vip.vrf_context_ref

  servers {
    ip {
      addr = split("/", var.testvm_ip_cidr)[0]
      type = "V4"
    }
  }
}

resource "avi_vsvip" "dummy" {
  name            = "dummy"
  cloud_ref       = data.avi_cloud.cloud.id
  vrf_context_ref = data.avi_network.vip.vrf_context_ref
  ipam_selector {
    type = "SELECTOR_IPAM"
    labels {
      key   = "cloud"
      value = var.avi_cloud
    }
  }
  vip {
    vip_id                = "dummy"
    auto_allocate_ip_type = "V4_ONLY"
    auto_allocate_ip      = true
    # ip_address {
    #   addr = var.avi_dummy_vip
    #   type = "V4"
    # }
    ipam_network_subnet {
      network_ref = data.avi_network.vip.id
      subnet {
        ip_addr {
          addr = var.avi_vip_network_addr
          type = "V4"
        }
        mask = var.avi_vip_network_mask
      }
    }
  }
}

resource "avi_virtualservice" "dummy" {
  name = "dummy"
  services {
    port = 80
  }
  application_profile_ref = data.avi_applicationprofile.l4.id
  type                    = "VS_TYPE_NORMAL"
  cloud_ref               = data.avi_cloud.cloud.id
  cloud_type              = "CLOUD_VCENTER"
  pool_ref                = avi_pool.dummy.id
  vsvip_ref               = avi_vsvip.dummy.id
  vrf_context_ref         = data.avi_network.vip.vrf_context_ref
}

resource "random_pet" "ubuntu" {
}

resource "tls_private_key" "ubuntu" {
  algorithm = "ED25519"
}

resource "vsphere_virtual_machine" "ubuntu" {
  name             = random_pet.ubuntu.id
  resource_pool_id = data.vsphere_resource_pool.default.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = trimprefix(data.vsphere_folder.folder.path, "/${data.vsphere_datacenter.datacenter.name}/vm")

  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
    # use_static_mac = true
    # mac_address    = local.mac_address
  }
  disk {
    label            = "disk0"
    size             = 10
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_content_library_item.ubuntu.id
  }
  cdrom {
    client_device = true
  }

  vapp {
    properties = {
      password = "ubuntu"
      hostname = "config-in-progress"
      user-data = base64encode(templatefile("${path.module}/userdata.tftpl", {
        hostname    = random_pet.ubuntu.id
        address     = var.testvm_ip_cidr
        gateway     = var.testvm_gateway
        dns_servers = var.testvm_dns_servers
        }
      ))
      public-keys = tls_private_key.ubuntu.public_key_openssh
    }
  }

  lifecycle {
    ignore_changes = [
      vapp[0].properties
    ]
  }

  provisioner "local-exec" {
    command = "../scripts/wait_http.sh http://${split("/", var.testvm_ip_cidr)[0]} 200 60"
  }

}

data "http" "vip" {
  url = "http://${local.vip_addr}"

  depends_on = [
    vsphere_virtual_machine.ubuntu
  ]
}

# resource "random_integer" "mac_address" {
#   min = 0
#   max = pow(2, 24) - 1
# }

# locals {
#   mac_address = "00:50:56:${join(":", regexall("..", format("%x", random_integer.mac_address.id)))}"
# }
