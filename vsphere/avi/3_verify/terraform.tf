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
      version = "3.4.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.7.2"
    }
  }

}

# data "terraform_remote_state" "deploy" {
#   backend = "local"
#   config = {
#     path = "../1_deploy/terraform.tfstate"
#   }
# }

# provider "avi" {
#   avi_username   = data.terraform_remote_state.deploy.outputs.avi_config.avi_username
#   avi_tenant     = data.terraform_remote_state.deploy.outputs.avi_config.avi_tenant
#   avi_password   = data.terraform_remote_state.deploy.outputs.avi_config.avi_password
#   avi_controller = data.terraform_remote_state.deploy.outputs.avi_config.avi_controller
#   avi_version    = data.terraform_remote_state.deploy.outputs.avi_config.avi_version
# }

# provider "vsphere" {
#   user           = var.vsphere_user
#   password       = var.vsphere_password
#   vsphere_server = var.vsphere_server

#   allow_unverified_ssl = true
# }
