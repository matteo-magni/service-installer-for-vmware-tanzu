data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "se" {
  name          = var.seg_vcenter_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "avi_serviceenginegroup" "default" {
  name      = "default"
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
  vcenter_folder            = var.seg_vcenter_folder
  vcenter_clusters {
    cluster_refs = [
      "https://${var.avi_controller}/api/vimgrclusterruntime/${data.vsphere_compute_cluster.se.id}-${avi_cloud.vsphere.uuid}"
    ]
    include = true
  }
  se_deprovision_delay = var.se_deprovision_delay
}
