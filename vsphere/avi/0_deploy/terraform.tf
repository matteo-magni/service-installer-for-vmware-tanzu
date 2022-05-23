terraform {

  required_version = "~> 1.2.0"

  required_providers {

    avi = {
      source  = "vmware/avi"
      version = "21.1.4"
    }

    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.1.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "3.3.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
  }

}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

provider "avi" {
  avi_username   = var.avi_username
  avi_tenant     = var.avi_tenant
  avi_password   = var.avi_password
  avi_controller = var.avi_ipaddress
  avi_version    = var.avi_version
}
