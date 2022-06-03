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
