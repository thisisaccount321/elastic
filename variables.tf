# Define region variable
variable "region" {
  description = "The GCP region where resources will be deployed."
  type        = string
  default     = "us-central1" # Default region, change as needed
}

# Define zone variable
variable "zone" {
  description = "The GCP zone where the VMs will be deployed."
  type        = string
  default     = "us-central1-a" # Default zone, change as needed
}

# Define VM size
variable "manager_vm_size" {
  type    = string
  default = "e2-medium" # Default machine type
}

variable "worker_vm_size" {
  type    = string
  default = "e2-medium" # Default machine type
}

# Define network
variable "network" {
  description = "The GCP network where the VMs will be deployed."
  type        = string
  default     = "default" # Default network, change as needed
}

# Define subnet
variable "subnetwork" {
  description = "The subnetwork where the VMs will be deployed."
  type        = string
  default     = "default" # Default subnetwork, change as needed
}

# Define source image for the VM (e.g., Ubuntu 20.04 LTS)
variable "source_image" {
  description = "The image to use for the VM boot disk."
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts" # Ubuntu 20.04 LTS
}


# Admin username for VM
variable "vm_username" {
  description = "Username for the SSH key and VM login."
  type        = string
  default     = "temporary" # Change this to your desired admin username
}

# variables.tf
variable "project_name" {
  description = "The GCP project name"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}