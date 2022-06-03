output "avi_serviceenginegroup_id" {
  value = avi_serviceenginegroup.vsphere_default.id
}
output "avi_cloud_id" {
  value = avi_cloud.vsphere.id
}
output "avi_vfr_context_vip_id" {
  value = avi_vrfcontext.vip.id
}
output "avi_network_vip_id" {
  value = avi_network.vip.id
}
