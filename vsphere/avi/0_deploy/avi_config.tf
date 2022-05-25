locals {
  backup_passphrase = var.avi_backup_passphrase == "" ? random_string.backup_passphrase.id : var.avi_backup_passphrase
}

resource "random_string" "backup_passphrase" {
  length  = 32
  special = false
  lower   = true
  upper   = true
  number  = true
}

resource "avi_backupconfiguration" "default" {
  name              = "Backup-Configuration"
  backup_passphrase = local.backup_passphrase
  save_local        = true

  depends_on = [
    vsphere_virtual_machine.avi_controller
  ]
}

resource "avi_controllerproperties" "default" {
  api_idle_timeout = var.avi_session_timeout
  ssl_certificate_expiry_warning_days = [
    30,
    7,
    1,
  ]

  depends_on = [
    vsphere_virtual_machine.avi_controller
  ]
}

resource "avi_systemconfiguration" "default" {

  welcome_workflow_complete = true
  default_license_tier      = var.avi_license_tier

  # from https://infosec.mozilla.org/guidelines/openssh
  ssh_ciphers = [
    "chacha20-poly1305@openssh.com",
    "aes256-gcm@openssh.com",
    "aes128-gcm@openssh.com",
    "aes256-ctr",
    "aes192-ctr",
    "aes128-ctr",
  ]
  ssh_hmacs = [
    "hmac-sha2-512-etm@openssh.com",
    "hmac-sha2-256-etm@openssh.com",
    "hmac-sha2-512",
    "hmac-sha2-256",
  ]

  dns_configuration {
    search_domain = var.avi_dns_domain

    dynamic "server_list" {
      for_each = var.avi_dns_servers_ipv4
      iterator = dns
      content {
        addr = dns.key
        type = "V4"
      }
    }
  }

  ntp_configuration {
    dynamic "ntp_servers" {
      for_each = var.avi_ntp_servers_fqdn
      iterator = ntp
      content {
        server {
          addr = ntp.key
          type = "DNS"
        }
      }
    }
  }

  email_configuration {
    smtp_type = "SMTP_NONE"
  }

  portal_configuration {
    allow_basic_authentication     = false
    api_force_timeout              = 24
    disable_remote_cli_shell       = false
    disable_swagger                = false
    enable_clickjacking_protection = true
    enable_http                    = true
    enable_https                   = true
    minimum_password_length        = 8
    password_strength_check        = false
    redirect_to_https              = true
    http_port                      = 80
    https_port                     = 443
    sslkeyandcertificate_refs      = local.ssl_certificate_provided ? avi_sslkeyandcertificate.controller[*].id : []
    sslprofile_ref                 = avi_sslprofile.mozilla_intermediate.id
  }

  depends_on = [
    vsphere_virtual_machine.avi_controller,
    null_resource.license,
  ]
}

resource "null_resource" "license" {
  count = var.avi_license_key != "" ? 1 : 0
  provisioner "local-exec" {
    command = "../scripts/avi.sh"
    environment = {
      AVI_METHOD   = "PUT"
      AVI_HOST     = var.avi_ipaddress
      AVI_USER     = var.avi_username
      AVI_PASS     = local.avi_password
      AVI_VERSION  = var.avi_version
      AVI_ENDPOINT = "licensing"
      JSON_BODY    = jsonencode({ serial_key = var.avi_license_key })
    }
  }

  depends_on = [
    vsphere_virtual_machine.avi_controller
  ]
}