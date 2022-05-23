terraform {

  required_version = "~> 1.1.7"

  required_providers {

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
