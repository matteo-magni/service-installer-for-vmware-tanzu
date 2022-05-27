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

data "avi_cloud" "cloud" {
  name = var.avi_cloud
}

data "avi_network" "vip" {
  name      = var.avi_vip_network_name
  cloud_ref = data.avi_cloud.cloud.id
}

data "avi_applicationprofile" "l4" {
  name = "System-L4-Application"
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
