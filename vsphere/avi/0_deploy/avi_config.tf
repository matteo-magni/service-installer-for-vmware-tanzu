locals {
  backup_passphrase = var.backup_passphrase == "" ? random_string.backup_passphrase.id : var.backup_passphrase
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
    null_resource.change_admin_password
  ]
  lifecycle {
    ignore_changes = [
      backup_passphrase
    ]
    replace_triggered_by = [
      random_string.backup_passphrase
    ]
  }
}

resource "avi_sslkeyandcertificate" "default" {
  name = "controller"
  type = "SSL_CERTIFICATE_TYPE_SYSTEM"
  key  = var.avi_ssl_keycert.key
  certificate {
    certificate = var.avi_ssl_keycert.cert
  }

  depends_on = [
    null_resource.change_admin_password
  ]
}

resource "avi_systemconfiguration" "default" {

  welcome_workflow_complete = true

  default_license_tier = "ESSENTIALS"
  ssh_ciphers = [
    "aes128-ctr",
    "aes256-ctr",
  ]
  ssh_hmacs = [
    "hmac-sha2-512-etm@openssh.com",
    "hmac-sha2-256-etm@openssh.com",
    "hmac-sha2-512",
  ]

  dns_configuration {
    search_domain = "h2o-2-351.h2o.vmware.com"  #TODO use variable

    server_list {
      addr = "10.79.2.5"  #TODO use variable
      type = "V4"
    }
    server_list {
      addr = "10.79.2.6"  #TODO use variable
      type = "V4"
    }
  }

  ntp_configuration {

    ntp_servers {
      server {
        addr = "time1.oc.vmware.com"  #TODO use variable
        type = "DNS"
      }
    }
    ntp_servers {
      server {
        addr = "time2.oc.vmware.com"  #TODO use variable
        type = "DNS"
      }
    }
  }

  email_configuration {
    smtp_type = "SMTP_NONE"
  }

  portal_configuration {
    sslkeyandcertificate_refs = [
      avi_sslkeyandcertificate.default.id
    ]
  }
}