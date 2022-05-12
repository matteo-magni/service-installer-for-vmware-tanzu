data "avi_tenant" "admin" {
  name = var.avi_tenant
}

resource "avi_cloud" "vsphere" {
  name       = var.avi_cloud
  tenant_ref = data.avi_tenant.admin.id

  dhcp_enabled      = "true"
  license_tier      = "ENTERPRISE"
  license_type      = "LIC_CORES"
  vtype             = "CLOUD_VCENTER"
  ipam_provider_ref = avi_ipamdnsproviderprofile.vsphere.id

  vcenter_configuration {
    datacenter         = var.vsphere_datacenter
    management_network = var.avi_mgmt_network
    password           = var.vsphere_password
    privilege          = "WRITE_ACCESS"
    username           = var.vsphere_user
    vcenter_url        = var.vsphere_server
  }

}

resource "avi_network" "avi_workload" {
  name                = var.avi_workload_network_name
  cloud_ref           = avi_cloud.vsphere.id
  dhcp_enabled        = false
  ip6_autocfg_enabled = false
  configured_subnets {
    prefix {
      ip_addr {
        addr = var.avi_workload_network_addr
        type = "V4"
      }
      mask = var.avi_workload_network_mask
    }
    static_ip_ranges {
      type = "STATIC_IPS_FOR_VIP"
      range {
        begin {
          addr = var.avi_workload_network_begin
          type = "V4"
        }
        end {
          addr = var.avi_workload_network_end
          type = "V4"
        }
      }
    }
  }
}

locals {

  ipam_http_curl_args = sensitive(
    join(" ", [
      "-sLk",
      "-X PATCH",
      "-H 'X-Avi-Version: ${var.avi_version}'",
      "-H 'Authorization: Basic ${base64encode(join(":", [var.avi_username, var.avi_password]))}'",
      "-H 'Content-Type: application/json'",
      "https://${var.avi_controller}/api/ipamdnsproviderprofile/${avi_ipamdnsproviderprofile.vsphere.uuid}",
    ])
  )

  ipam_http_body_apply = {
    replace = {
      internal_profile = {
        usable_networks = [
          { nw_ref = avi_network.avi_workload.id },
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
    ipam_uuid = avi_ipamdnsproviderprofile.vsphere.uuid
    # ipam_http_curl_args    = local.ipam_http_curl_args
    avi_username           = var.avi_username
    avi_password           = var.avi_password
    avi_controller         = var.avi_controller
    avi_version            = var.avi_version
    ipam_http_body_apply   = jsonencode(local.ipam_http_body_apply)
    ipam_http_body_destroy = jsonencode(local.ipam_http_body_destroy)
  }

  provisioner "local-exec" {
    command = "./scripts/ipam_networks_update.sh -h ${self.triggers.avi_controller} -u ${self.triggers.avi_username} -p '${replace(self.triggers.avi_password, "'", "'\"'\"")}' -v ${self.triggers.avi_version} -i ${self.triggers.ipam_uuid} -j '${self.triggers.ipam_http_body_apply}'"
    # command = "curl -d '${self.triggers.ipam_http_body_apply}' ${self.triggers.ipam_http_curl_args}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "./scripts/ipam_networks_update.sh -h ${self.triggers.avi_controller} -u ${self.triggers.avi_username} -p '${replace(self.triggers.avi_password, "'", "'\"'\"")}' -v ${self.triggers.avi_version} -i ${self.triggers.ipam_uuid} -j '${self.triggers.ipam_http_body_destroy}'"
    # command = "curl -d '${self.triggers.ipam_http_body_destroy}' ${self.triggers.ipam_http_curl_args}"
  }

  depends_on = [
    avi_ipamdnsproviderprofile.vsphere,
    avi_network.avi_workload,
  ]
}

resource "avi_ipamdnsproviderprofile" "vsphere" {
  name       = "vsphere-ipam"
  tenant_ref = data.avi_tenant.admin.id
  type       = "IPAMDNS_TYPE_INTERNAL"

  # lifecycle {
  #   ignore_changes = [
  #     internal_profile
  #   ]
  # }
}
