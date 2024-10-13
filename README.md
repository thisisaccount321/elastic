### Project Overview
One of the strictest requirements is being production-ready while keeping costs under $300 over six months.

Kubernetes (K8S) is not feasible due to additional components such as the master node and default DaemonSets required for K8S functionality.

The next option to consider is running Elasticsearch directly on a VM, but this greatly reduces the flexibility and recoverability of the application.

The best solution would take advantage of multi-host resiliency (resilient to hardware failure) and the flexibility of containerization (resilient to software failure) while still being lightweight enough to save on costs.

#### Projected Solution

We propose using 2 instances:

- Manager: 1 CPU, 2 GB Memory, 20 GB storage.
- Worker: 2 CPUs, 4 GB Memory, 20 GB storage.

With a 3-year commitment, we can achieve an average cost of $47.48/month in the us-central1 region. The detailed statistics are available in the Cost-projected.csv file.

Automation and Recoverability:

To enhance cluster recoverability, we use Terraform for VM creation and Ansible for configuration. While it’s possible to combine these processes using the Ansible provider for Terraform, we opted to keep provisioning and configuration separate, mainly because the Ansible provider for Terraform is not yet fully mature.

This separation does not pose a problem for automation, as we can easily bridge the two processes and set up the entire pipeline efficiently.


Folder structure:
```
.
├── Cost-projected.csv                 # CSV file with detailed cost analysis
├── Readme.md                          # This documentation
├── ansible                            # Ansible playbooks for configuration management
│   ├── docker-compose                 # Docker Compose files for managing services
│   │   ├── docker-compose.yml         # Main Docker Compose configuration
│   │   └── swarm                      # Docker Swarm-specific stack files
│   │       ├── docker-stack.yml       # Docker stack definition
│   │       └── env.sh                 # Environment variables for the stack
│   ├── docker_swarm_setup.yml         # Ansible playbook to set up Docker Swarm cluster
│   └── hosts.ini                      # Inventory file for Ansible with server IPs
├── main.tf                            # Main Terraform configuration
├── your-gcp-credentials-files.json    # GCP credentials for Terraform
├── provider.tf                        # Terraform provider configuration
├── ssh                                # SSH keys for accessing VMs
│   ├── id_rsa
│   └── id_rsa.pub
├── terraform.tfvars                   # Terraform variables
└── variables.tf                       # Variables for Terraform configuration
```

Note: for ease of demonstration:
- We use your-gcp-credentials-files.json for the service account instead of environment variables.
- We assign public IPs to both VMs, but in real life, there is no need for public IPs, as we would connect to the private network before accessing Elasticsearch.
- We write resources directly without using modules or separating the environment folder structure and use Terragrunt to keep the code DRY.

#### Deployment and Configuration guide

Prepare your-gcp-credentials-files.json, then:
```
terraform init
terraform plan
terraform apply
```
Prepare Env Var
```
export MANAGER_INTERNAL_IP=$(terraform output -raw manager_internal_ip)
export WORKER_INTERNAL_IP=$(terraform output -raw worker_internal_ip)
export MANAGER_PUBLIC_IP=$(terraform output -raw manager_public_ip)
export WORKER_PUBLIC_IP=$(terraform output -raw worker_public_ip)
```
Prepare inventory file:
```
cat << EOF > ./ansible/hosts.ini
[manager]
$MANAGER_PUBLIC_IP

[manager:vars]
ansible_user="temporary"
ansible_ssh_private_key_file=./../ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[worker]
$WORKER_PUBLIC_IP

[worker:vars]
ansible_user="temporary"
ansible_ssh_private_key_file=./../ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
```
Start configuration with Ansible

```
cd ansible
ansible-playbook -i hosts.ini docker_swarm_setup.yml        
```
#### Further consideration for production used.

This setup aims for high availability. For a production-ready environment, consider the following practices:

- Continuous health checks and monitoring for auto-restart to ensure high availability in case of software and hardware failures.
- Data protection: further configure Elasticsearch for sharding and replication, and continuously back up volumes.


```
{
  "cluster_name" : "es-cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  "active_primary_shards" : 1,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```