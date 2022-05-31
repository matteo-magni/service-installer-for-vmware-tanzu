locals {
  vip_addr = flatten(avi_vsvip.dummy.vip[*].ip_address[*].addr)[0]
}

output "vip_addr" {
  value = local.vip_addr
}

output "ssh_private_key" {
  value     = tls_private_key.ubuntu.private_key_openssh
  sensitive = true
}
