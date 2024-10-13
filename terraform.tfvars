# terraform.tfvars file with example values for variables

region          = "asia-southeast1"
zone            = "asia-southeast1-a"
# manager_vm_size = "custom-2-8192"
# manager_vm_size = "custom-4-16384"
manager_vm_size = "e2-standard-2"

# manager_vm_size  = "custom-2-4096"
worker_vm_size  = "e2-medium"
network         = "default"
subnetwork      = "default"
source_image    = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
vm_username     = "temporary"

