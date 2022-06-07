resource "avi_cloud" "vsphere" {
  name = var.avi_cloud

  dhcp_enabled      = "true"
  license_tier      = var.avi_license_tier
  license_type      = var.avi_license_type
  vtype             = "CLOUD_VCENTER"
  ipam_provider_ref = avi_ipamdnsproviderprofile.vsphere.id

  vcenter_configuration {
    vcenter_url        = var.vsphere_cloud_server
    username           = var.vsphere_cloud_user
    password           = var.vsphere_cloud_password
    datacenter         = var.vsphere_cloud_datacenter
    management_network = var.vsphere_cloud_network
    privilege          = "WRITE_ACCESS"
  }

}

resource "avi_ipamdnsproviderprofile" "vsphere" {
  name = var.avi_cloud
  type = "IPAMDNS_TYPE_INTERNAL"
}

resource "avi_network" "vip" {
  name                = var.avi_vip_network_name
  cloud_ref           = avi_cloud.vsphere.id
  dhcp_enabled        = false
  ip6_autocfg_enabled = false
  vrf_context_ref     = avi_vrfcontext.vip.id
  configured_subnets {
    prefix {
      ip_addr {
        addr = var.avi_vip_network_addr
        type = "V4"
      }
      mask = var.avi_vip_network_mask
    }
    static_ip_ranges {
      type = "STATIC_IPS_FOR_VIP_AND_SE"
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

resource "avi_network" "se" {
  name                = var.avi_se_network_name
  cloud_ref           = avi_cloud.vsphere.id
  dhcp_enabled        = false
  ip6_autocfg_enabled = false
  configured_subnets {
    prefix {
      ip_addr {
        addr = var.avi_se_network_addr
        type = "V4"
      }
      mask = var.avi_se_network_mask
    }
    static_ip_ranges {
      type = "STATIC_IPS_FOR_SE"
      range {
        begin {
          addr = var.avi_se_network_begin
          type = "V4"
        }
        end {
          addr = var.avi_se_network_end
          type = "V4"
        }
      }
    }
  }
}

resource "avi_vrfcontext" "se" {
  name      = "se"
  cloud_ref = avi_cloud.vsphere.id

  static_routes {
    route_id = "1"
    next_hop {
      addr = var.avi_se_network_gateway
      type = "V4"
    }
    prefix {
      ip_addr {
        addr = "0.0.0.0"
        type = "V4"
      }
      mask = "0"
    }
  }
}

resource "avi_vrfcontext" "vip" {
  name      = "vip"
  cloud_ref = avi_cloud.vsphere.id

  static_routes {
    route_id = "1"
    next_hop {
      addr = var.avi_vip_network_gateway
      type = "V4"
    }
    prefix {
      ip_addr {
        addr = "0.0.0.0"
        type = "V4"
      }
      mask = "0"
    }
  }
}

# resource "null_resource" "vrfcontext_dereference" {
#   triggers = {
#     uuid           = avi_network.vip.uuid
#     avi_username   = var.avi_username
#     avi_password   = var.avi_password
#     avi_controller = var.avi_controller
#     avi_version    = var.avi_version
#   }

#   provisioner "local-exec" {
#     when = destroy
#     command = "JSON_BODY=$(${path.module}/../../scripts/avi.sh | jq -cr '.vrf_context_ref=\"\"') ${path.module}/../../scripts/avi.sh -m PUT"
#     environment = {
#       AVI_HOST     = self.triggers.avi_controller
#       AVI_USER     = self.triggers.avi_username
#       AVI_PASS     = self.triggers.avi_password
#       AVI_VERSION  = self.triggers.avi_version
#       AVI_ENDPOINT = "network/${self.triggers.uuid}"
#     }
#   }
# }


resource "null_resource" "avi_ipamdnsproviderprofile_usablenetworks" {
  triggers = {
    ipam_uuid      = avi_ipamdnsproviderprofile.vsphere.uuid
    avi_username   = var.avi_username
    avi_password   = var.avi_password
    avi_controller = var.avi_controller
    avi_version    = var.avi_version
    ipam_http_body_apply = jsonencode({
      replace = {
        internal_profile = {
          usable_networks = [
            {
              labels = [{
                key   = "cloud",
                value = var.avi_cloud
              }],
              nw_ref = avi_network.vip.id
            },
          ]
        }
      }
    })
    ipam_http_body_destroy = jsonencode({
      replace = {
        internal_profile = {
          usable_networks = []
        }
      }
    })
  }

  provisioner "local-exec" {
    command = "${path.module}/../../scripts/avi.sh"
    environment = {
      AVI_METHOD   = "PATCH"
      AVI_HOST     = self.triggers.avi_controller
      AVI_USER     = self.triggers.avi_username
      AVI_PASS     = self.triggers.avi_password
      AVI_VERSION  = self.triggers.avi_version
      AVI_ENDPOINT = "ipamdnsproviderprofile/${self.triggers.ipam_uuid}"
      JSON_BODY    = self.triggers.ipam_http_body_apply
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/../../scripts/avi.sh"
    environment = {
      AVI_METHOD   = "PATCH"
      AVI_HOST     = self.triggers.avi_controller
      AVI_USER     = self.triggers.avi_username
      AVI_PASS     = self.triggers.avi_password
      AVI_VERSION  = self.triggers.avi_version
      AVI_ENDPOINT = "ipamdnsproviderprofile/${self.triggers.ipam_uuid}"
      JSON_BODY    = self.triggers.ipam_http_body_destroy
    }
  }

  depends_on = [
    avi_ipamdnsproviderprofile.vsphere,
    avi_network.vip,
  ]
}

locals {
  avi_serviceenginegroup_name = var.avi_serviceenginegroup_name == "" ? var.avi_cloud : var.avi_serviceenginegroup_name
}
resource "avi_serviceenginegroup" "vsphere_default" {
  name      = local.avi_serviceenginegroup_name
  cloud_ref = avi_cloud.vsphere.id

  active_standby            = var.avi_ha_mode == "HA_MODE_LEGACY_ACTIVE_STANDBY" ? true : false
  algo                      = var.algo
  buffer_se                 = var.buffer_se
  se_name_prefix            = var.se_name_prefix
  vcpus_per_se              = var.vcpus_per_se
  ha_mode                   = var.avi_ha_mode
  mem_reserve               = true
  memory_per_se             = var.memory_per_se
  disk_per_se               = var.disk_per_se
  min_se                    = var.min_se
  max_se                    = var.max_se
  min_scaleout_per_vs       = var.min_scaleout_per_vs
  max_scaleout_per_vs       = var.max_scaleout_per_vs
  dedicated_dispatcher_core = var.dedicated_dispatcher_core
  vcenter_folder            = var.se_vcenter_folder
  vcenter_clusters {
    cluster_refs = [
      "https://${var.avi_controller}/api/vimgrclusterruntime/${data.vsphere_compute_cluster.se.id}-${avi_cloud.vsphere.uuid}"
    ]
    include = true
  }
  se_deprovision_delay = var.se_deprovision_delay
}

# workaround to issue https://github.com/vmware/terraform-provider-avi/issues/376
resource "null_resource" "seg_destroy" {
  triggers = {
    uuid           = avi_serviceenginegroup.vsphere_default.uuid
    avi_username   = var.avi_username
    avi_password   = var.avi_password
    avi_controller = var.avi_controller
    avi_version    = var.avi_version
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/../../scripts/avi.sh"
    environment = {
      AVI_METHOD   = "DELETE"
      AVI_HOST     = self.triggers.avi_controller
      AVI_USER     = self.triggers.avi_username
      AVI_PASS     = self.triggers.avi_password
      AVI_VERSION  = self.triggers.avi_version
      AVI_ENDPOINT = "serviceenginegroup/${self.triggers.uuid}"
    }
  }
}
