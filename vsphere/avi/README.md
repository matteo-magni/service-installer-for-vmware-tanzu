# VMware NSX Advanced Load Balancer Terraform automation (formerly AVI Networks)

The goal of this project is to quickly build a simple VMware NSX Advanced Load Balancer (AVI) environment mostly for lab/learning purposes which can be further extended based on specific needs.

Terraform has been used as much as possible leveraging multiple providers like `vsphere` and `vmware/avi`.
However, some specific use cases required some custom bash scripts which have been triggered via provisioners in order to maintain the Terraform code as consistent as possible.
On the other hand, there are some prerequisites that have to be carried out manually from the vCenter UI in order to speed up the process by avoiding unnecessary network traffic.

The whole automation has been thought of as to be run in a blank environment where no AVI infrastructure exists, and as such the only user that comes with a new installation is `admin`, which gets eventually its default password changed.
However, the very same automation _might_ be used even on an existing AVI platform, provided a different tenant and credentials to interact with it.

The process is split into different phases assigned to different personas, just in case the customer and/or the environment requires different people with different roles to operate on different levels of the infrastructure.
More specifically, the "vSphere admin" persona is responsible for managing the vSphere platform and as such has got very high privileges on it, whereas the "AVI admin" persona has limited permissions on vSphere but has to be granted high privileges on the AVI platform.

Both prerequisites and deploy phases are meant to be run by the vSphere admin, whilst the AVI admin takes care of the configuration phase as well as the verification phase, provided he's got enough permissions on vSphere to deploy a test virtual machine.

## Phase 0: Prerequisites - fetch OVAs

For deploying the AVI controller in phase 1 and the Ubuntu test VM in phase 3 we need to make the OVAs available in a content library.
The `vsphere` Terraform provider documentation claims that the `vsphere_content_library_item` resource can be configured with the `file_url` attribute so that the vCenter can download the item directly from the source.
However, the Terraform control node will still have to download the item to fetch its metadata, slowing down the process especially when items are a few GBs in size on unpredictable network conditions.

The vCenter UI allows to import items into a content library directly from a HTTP server which is really handy because it doesn't require the operator to download the item somewhere and then upload it to the vCenter.

**WARNING: the vCenter needs access to the Internet.** If this is not possible at a customer's (i.e. security policies) then the items will need to be downloaded from an authorised workstation and then uploade

1. **Create a content library**\
Connect to the vCenter and create a local content library named `ova`.
If the name has been already used choose a new one, you will need to set it into the variables file as value for the variable  `vsphere_content_library_avi` as explained afterwards.

1. **Get the AVI controller download URL from [customerconnect.vmware.com](https://customerconnect.vmware.com)**\
Go to downloads for the product "VMware NSX Advanced Load Balancer" and follow the links to get the URL for VMware platform. The link will look like this `https://portal.avipulse.vmware.com/api/portal/download/SoftwaresDownloads/Version-21.1.4-2p3/controller-21.1.4-2p3-9009.ova?X-Amz-Algorithm=AWS4-HMAC-SHA256&...` and will expire in 6 hours.

1. **Import the AVI controller into the content library**\
Connect to the vCenter and open the content library created at step 1.
Import a new item by specifying the URL from step 2 so that the vCenter can download it.
Choose a name for the destination item, you will need to set it into the variables file as value for the variable `vsphere_content_library_item_avi`.

1. **Import the Ubuntu OVA into the content library**\
Connect to the vCenter and open the content library created at step 1.
Import a new item by specifying the URL `https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.ova` so that the vCenter can download it.
Choose a name for the destination item, you will need to set it into the variables file as value for the variable `vsphere_content_library_item_ubuntu`.

## Phase 1: Deploy

This phase is about deploying the actual AVI controller as a virtual machine.

## Phase 3: Verify

The last step verifies that the configuration applied in the previous steps is actually working:

* It configures a virtual service with a VIP on the frontend and backed by a pool of servers.
* The pool gets actually populated by a single IP address where a Nginx HTTP service on a virtual machine is listening.
* Finally, a HTTP request is issued against the VIP to make sure it is responding as expected.


## Bugs

During the development of this project a bug in the Terraform provider has been revealed and promptly reported to the development team (https://github.com/vmware/terraform-provider-avi/issues/376).
At the time of writing the bug is still open, therefore in order to properly destroy the configuration at step #1 it's necessary to destroy the Service Engine Group manually via web UI.

