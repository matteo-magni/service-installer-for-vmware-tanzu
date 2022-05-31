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
    vsphere_virtual_machine.avi_controller
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

  name = "ca-${random_string.avi_controller_name.id}-${each.value.serial_number}"
  type = "SSL_CERTIFICATE_TYPE_CA"
  certificate {
    certificate = each.value.cert_pem
  }

  depends_on = [
    vsphere_virtual_machine.avi_controller
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
  #   type = "SSL_VERSION_TLS1_3"
  # }
  accepted_ciphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
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
    vsphere_virtual_machine.avi_controller
  ]
}
