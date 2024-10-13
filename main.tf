# Public IP for Manager VM
resource "google_compute_address" "manager_ip" {
  name   = "manager-ip"
  region = var.region
}

# Public IP for Worker VM
resource "google_compute_address" "worker_ip" {
  name   = "worker-ip"
  region = var.region
}

# Manager VM
resource "google_compute_instance" "manager_vm" {
  name                      = "manager-vm"
  machine_type              = var.manager_vm_size
  zone                      = var.zone
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = var.source_image
      size  = 40
    }
  }

  # Define the network interface inside the compute instance
  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {
      # Public IP is assigned
      nat_ip = google_compute_address.manager_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${file("${path.module}/ssh/id_rsa.pub")}"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Install Docker
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Add the 'temporary' user to the 'docker' group
    sudo usermod -aG docker temporary

    echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p

    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

  EOT

  tags = ["docker-manager"]
}

# Worker VM
resource "google_compute_instance" "worker_vm" {
  name                      = "worker-vm"
  machine_type              = var.worker_vm_size
  zone                      = var.zone
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = var.source_image
      size  = 20
    }
  }

  # Define the network interface inside the compute instance
  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {
      # Public IP is assigned
      nat_ip = google_compute_address.worker_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${file("${path.module}/ssh/id_rsa.pub")}"
  }
  # ${var.admin_username}
  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Install Docker
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker


    # Add the 'temporary' user to the 'docker' group
    sudo usermod -aG docker temporary

    echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p


  EOT

  tags = ["docker-worker"]
}
# Output the public IP of the Manager node
output "manager_public_ip" {
  value = google_compute_address.manager_ip.address
}

# Output the public IP of the Worker node
output "worker_public_ip" {
  value = google_compute_address.worker_ip.address
}
# Output the internal IP of the Manager node
output "manager_internal_ip" {
  value = google_compute_instance.manager_vm.network_interface[0].network_ip
}

# Output the internal IP of the Worker node
output "worker_internal_ip" {
  value = google_compute_instance.worker_vm.network_interface[0].network_ip
}