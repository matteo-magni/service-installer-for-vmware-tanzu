terraform {

  required_version = "~> 1.2.0"

  required_providers {

    avi = {
      source  = "vmware/avi"
      version = "21.1.4"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }

    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.1.1"
    }
  }
}

provider "avi" {
  avi_username   = var.avi_username
  avi_tenant     = var.avi_tenant
  avi_password   = var.avi_password
  avi_controller = var.avi_controller
  avi_version    = var.avi_version
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}
