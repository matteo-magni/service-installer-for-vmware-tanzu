locals {
  backup_passphrase = var.avi_backup_passphrase == "" ? random_password.backup_passphrase.result : var.avi_backup_passphrase
}

resource "random_password" "backup_passphrase" {
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
    null_resource.avi_ready
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
    null_resource.avi_ready
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
    null_resource.avi_ready,
    null_resource.license,
  ]
}

resource "null_resource" "license" {
  count = var.avi_license_key != "" ? 1 : 0
  provisioner "local-exec" {
    command = "${path.module}/../../scripts/avi.sh"
    environment = {
      AVI_METHOD   = "PUT"
      AVI_HOST     = var.avi_controller_network.ip_address
      AVI_USER     = var.avi_username
      AVI_PASS     = var.avi_password
      AVI_VERSION  = var.avi_version
      AVI_ENDPOINT = "licensing"
      JSON_BODY    = jsonencode({ serial_key = var.avi_license_key })
    }
  }

  depends_on = [
    null_resource.avi_ready
  ]
}

locals {
  ssl_certificate_provided = (var.avi_ssl_key != "" && var.avi_ssl_certificate != "")
}

resource "avi_sslkeyandcertificate" "controller" {
  count = local.ssl_certificate_provided ? 1 : 0

  name = "controller-${random_string.avi_controller_name.id}"
  type = "SSL_CERTIFICATE_TYPE_SYSTEM"
  key  = var.avi_ssl_key

  dynamic "ca_certs" {
    for_each = avi_sslkeyandcertificate.ca
    iterator = ca
    content {
      ca_ref = ca.value.id
    }
  }
  certificate {
    certificate = var.avi_ssl_certificate
  }

  depends_on = [
    null_resource.avi_ready
  ]
}

# read CA certs if provided
data "tls_certificate" "ca" {
  count = var.avi_ssl_cacerts != "" ? 1 : 0

  content = var.avi_ssl_cacerts
}

locals {
  # temporary local variable to store info about CAs
  ca_objects   = { for i, x in flatten(data.tls_certificate.ca[*].certificates) : "ca-${i}" => x }
  tls_versions = []
}

# create cert objects for each CA
resource "avi_sslkeyandcertificate" "ca" {
  for_each = local.ca_objects

  name = "ca-${random_string.avi_controller_name.result}-${each.value.serial_number}"
  type = "SSL_CERTIFICATE_TYPE_CA"
  certificate {
    certificate = each.value.cert_pem
  }

  depends_on = [
    null_resource.avi_ready
  ]
}

data "http" "dhparam" {
  url = "https://ssl-config.mozilla.org/ffdhe2048.txt"
}

# https://ssl-config.mozilla.org/
resource "avi_sslprofile" "mozilla_intermediate" {
  type = "SSL_PROFILE_TYPE_SYSTEM"
  name = "Mozilla-Intermediate"
  accepted_versions {
    type = "SSL_VERSION_TLS1_2"
  }
  # accepted_versions {
  #   type = "SSL_VERSION_TLS1_3"  # not supported yet
  # }
  accepted_ciphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384"
  ciphersuites     = "TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384"
  cipher_enums = [
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
  ]
  dhparam                       = data.http.dhparam.body
  prefer_client_cipher_ordering = false
  enable_ssl_session_reuse      = false

  depends_on = [
    null_resource.avi_ready
  ]
}
