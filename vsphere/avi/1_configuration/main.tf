data "avi_tenant" "admin" {
  name = var.avi_tenant
}

resource "avi_cloud" "vsphere" {
  name = var.avi_cloud

  dhcp_enabled      = "true"
  license_tier      = var.avi_license_tier
  license_type      = var.avi_license_type
  vtype             = "CLOUD_VCENTER"
  ipam_provider_ref = avi_ipamdnsproviderprofile.vsphere_ipam.id

  vcenter_configuration {
    datacenter         = var.vsphere_datacenter
    management_network = var.avi_mgmt_network_name
    password           = var.vsphere_password
    privilege          = "WRITE_ACCESS"
    username           = var.vsphere_user
    vcenter_url        = var.vsphere_server
  }

}

resource "avi_network" "vip" {
  name                = var.avi_vip_network_name
  cloud_ref           = avi_cloud.vsphere.id
  dhcp_enabled        = false
  ip6_autocfg_enabled = false
  configured_subnets {
    prefix {
      ip_addr {
        addr = var.avi_vip_network_addr
        type = "V4"
      }
      mask = var.avi_vip_network_mask
    }
    static_ip_ranges {
      type = "STATIC_IPS_FOR_VIP"
      range {
        begin {
          addr = var.avi_vip_network_begin
          type = "V4"
        }
        end {
          addr = var.avi_vip_network_end
          type = "V4"
        }
      }
    }
  }
}


locals {

  ipam_http_body_apply = {
    replace = {
      internal_profile = {
        usable_networks = [
          { nw_ref = avi_network.vip.id },
        ]
      }
    }
  }

  ipam_http_body_destroy = {
    replace = {
      internal_profile = {
        usable_networks = []
      }
    }
  }
}

resource "null_resource" "avi_ipamdnsproviderprofile_usablenetworks" {

  triggers = {
    ipam_uuid              = avi_ipamdnsproviderprofile.vsphere_ipam.uuid
    avi_username           = var.avi_username
    avi_password           = var.avi_password
    avi_controller         = var.avi_controller
    avi_version            = var.avi_version
    ipam_http_body_apply   = jsonencode(local.ipam_http_body_apply)
    ipam_http_body_destroy = jsonencode(local.ipam_http_body_destroy)
  }

  provisioner "local-exec" {
    command = "../scripts/ipam_networks_update.sh -h ${self.triggers.avi_controller} -u ${self.triggers.avi_username} -p '${replace(self.triggers.avi_password, "'", "'\"'\"")}' -v ${self.triggers.avi_version} -i ${self.triggers.ipam_uuid} -j '${self.triggers.ipam_http_body_apply}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "../scripts/ipam_networks_update.sh -h ${self.triggers.avi_controller} -u ${self.triggers.avi_username} -p '${replace(self.triggers.avi_password, "'", "'\"'\"")}' -v ${self.triggers.avi_version} -i ${self.triggers.ipam_uuid} -j '${self.triggers.ipam_http_body_destroy}'"
  }

  depends_on = [
    avi_ipamdnsproviderprofile.vsphere_ipam,
    avi_network.vip,
  ]
}

resource "avi_ipamdnsproviderprofile" "vsphere_ipam" {
  name = "vsphere_ipam"
  type = "IPAMDNS_TYPE_INTERNAL"
}
