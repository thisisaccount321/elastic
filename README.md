### Project Overview
Total possible time of time spent: 1.5 days.

One of the strictest requirements is being production-ready while keeping costs under $300 over six months.

K8S is a great option, as we can easily spread pods across regional nodes for hardware HA, and running multiple pods for software HA by using Helm chart. Moreover, We can take advantage of the built-in self-healing mechanism. of K8s.
However, Kubernetes (K8S) is not feasible due to high additional components such as the master node and default DaemonSets required for K8S functionality.

The next option to consider is running Elasticsearch directly on a VM, but this greatly reduces the flexibility and recoverability of the application.

The best solution would take advantage of multi-host resiliency (resilient to hardware failure) and the flexibility of containerization (resilient to software failure) while still being lightweight enough to save on costs.

The two solutions closest to this are:
- Docker-compose: focus on the ease of reproducing and management, lack of hardware HA.
- Docker Swarm: a lightweight container orchestration tool with more HA (both software and hardware), but more difficult to reproduce.


In this case, I will demonstrate Docker Compose due to time constraints. and I personally cannot contribute more time to the complete solution. I made notes along the way to adapt to Swarm, no need for hardware change.



#### Projected Solution

We propose using 2 instances:

- Manager "e2-standard-2": 2 CPU, 8 GB Memory, 40 GB storage.
- Worker "e2-medium 2": 1 CPUs, 4 GB Memory, 20 GB storage.

With a 3-year commitment, we can achieve an average cost of $39.02/month in the us-central1 region. The detailed statistics are available in the Elasticsearch-cluster-cost-projected.csv file.

Automation and Recoverability:

To enhance cluster recoverability, we use Terraform for VM creation and Ansible for configuration. While it’s possible to combine these processes using the Ansible provider for Terraform, we opted to keep provisioning and configuration separate, mainly because the Ansible provider for Terraform is not yet fully mature.

This separation does not pose a problem for automation, as we can easily bridge the two processes and set up the entire pipeline efficiently.


Folder structure:
```
.
├── Elasticsearch-cluster-cost-projected.csv    # CSV file with detailed cost analysis
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
- Terraform local backend.

#### Deployment and Configuration guide



Prepare your-gcp-credentials-files.json, and export provider env var:
```
export TF_VAR_project_name="your-project-name"
export TF_VAR_region="your-region"
```
then:
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

This Ansible playbook will set up Swarm cluster 2 nodes ready, but just start the docker-compose for demonstration.

To be able to use Docker Swarm for this setup, simply need to do more configuarion on Node discovery for All nodes can join and form a single cluster properly.

There are some minor different between Docker-compose and Docker Swarm, so if you want to delve deeper, please refer to docker-compose/swarm
```
│   ├── docker-compose                 # Docker Compose files for managing services
│   │   ├── docker-compose.yml         # Main Docker Compose configuration
│   │   └── swarm                      # Docker Swarm-specific stack files
│   │       ├── docker-stack.yml       # Docker stack definition
│   │       └── env.sh                 # Environment variables for the stack
```
In case you are not familiar with Docker Swarm CLI, please ref [Docker stack CLI](https://docs.docker.com/reference/cli/docker/stack/)

#### Resilient Cluster creteria
By this setup we can meet:
- All nodes are data node
- Each node are master eligible
- Sharding and replica are set


#### Further consideration for production used.

This setup aims for high availability. For a production-ready environment, consider the following practices:

- Continuous health checks and monitoring for auto-restart to ensure high availability in case of software and hardware failures.
- Data protection: further configure Elasticsearch for sharding and replication, and continuously back up volumes.


