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

data "vsphere_content_library_item" "nginx" {
  name       = "focal-server-cloudimg-amd64"
  type       = "ovf"
  library_id = data.vsphere_content_library.ova.id
}

resource "random_pet" "nginx" {
}

resource "tls_private_key" "nginx" {
  algorithm = "ED25519"
}

output "ssh_private_key" {
  value     = tls_private_key.nginx.private_key_openssh
  sensitive = true
}

resource "vsphere_virtual_machine" "nginx" {
  name             = random_pet.nginx.id
  resource_pool_id = data.vsphere_resource_pool.default.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = trimprefix(data.vsphere_folder.folder.path, "/${data.vsphere_datacenter.datacenter.name}/vm")

  guest_id = "ubuntu64Guest"

  network_interface {
    network_id     = data.vsphere_network.network.id
    use_static_mac = true
    mac_address    = local.mac_address
  }
  disk {
    label            = "disk0"
    size             = 10
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_content_library_item.nginx.id
  }
  cdrom {
    client_device = true
  }

  vapp {
    properties = {
      password = "ubuntu"
      hostname = "config-in-progress"
      user-data = base64encode(templatefile("${path.module}/userdata.tftpl", {
        hostname    = random_pet.nginx.id
        address     = var.testvm_ip_cidr
        gateway     = var.testvm_gateway
        dns_servers = var.testvm_dns_servers
        }
      ))
      public-keys = tls_private_key.nginx.public_key_openssh
    }
  }

  provisioner "local-exec" {
    command = "../scripts/wait_http.sh http://${split("/", var.testvm_ip_cidr)[0]} 200 60"
  }

}

data "http" "nginx" {
  url = "http://${split("/", var.testvm_ip_cidr)[0]}"

  depends_on = [
    vsphere_virtual_machine.nginx
  ]
}

resource "random_integer" "mac_address" {
  min = 0
  max = pow(2, 24) - 1
}

locals {
  mac_address = "00:50:56:${join(":", regexall("..", format("%x", random_integer.mac_address.id)))}"
}
