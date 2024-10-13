# terraform.tfvars file with example values for variables

region          = "asia-southeast1"
zone            = "asia-southeast1-a"
# For 1 node docker-compose "e2-standard-4" 40GB Storage cost 48.03$
manager_vm_size = "e2-standard-4"

# For Swarm
# manager_vm_size = "e2-standard-2"
worker_vm_size  = "e2-medium"
network         = "default"
subnetwork      = "default"
source_image    = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
vm_username     = "temporary"

