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