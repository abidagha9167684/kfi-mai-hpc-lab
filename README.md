# KFI-MAI Mini Research HPC Infrastructure

A small Linux High Performance Computing environment designed to demonstrate practical skills in Linux server administration, HPC workload management, automation, shared storage, monitoring, security hardening, troubleshooting, and backup and recovery.

The infrastructure was built on AWS EC2 using Ubuntu Linux and follows a small research computing architecture with separate administration, controller, and compute systems.

The project was created as a practical learning environment for a Technical Administrator role supporting research and HPC infrastructure.

## 1. Project Overview

The environment contains three Linux servers:

| Server | Purpose |
|---|---|
| `hpc-admin` | Administration, Ansible automation, Prometheus, Grafana, Git, backups |
| `hpc-controller` | Slurm controller, researcher login node, NFS server |
| `hpc-compute01` | Slurm compute node used to execute workloads |

The infrastructure supports the following workflow:

```text
Researcher
    |
    | SSH
    v
hpc-controller
    |
    | sbatch
    v
Slurm Controller
    |
    | schedules workload
    v
hpc-compute01
    |
    | executes workload
    v
/research/results
```

## 2. Technologies Used

| Technology | Purpose |
|---|---|
| Ubuntu Linux | Operating system |
| AWS EC2 | Virtual server infrastructure |
| Ansible | Server configuration and automation |
| Slurm | HPC workload scheduling |
| Munge | Authentication between Slurm nodes |
| NFS | Shared research storage |
| Python | Example research workload |
| Prometheus | Metrics collection |
| Node Exporter | Linux server metrics |
| Grafana | Infrastructure monitoring dashboard |
| UFW | Host firewall |
| Fail2ban | Protection against repeated failed login attempts |
| SSH | Secure remote administration |
| Git | Version control |
| GitHub | Source code and project documentation |
| Bash | Administrative and backup scripts |

## 3. Architecture

```text
                           ADMINISTRATOR
                                |
                                |
                          SSH / Ansible
                                |
                                v
                    +----------------------+
                    |      hpc-admin       |
                    |----------------------|
                    | Ubuntu Linux         |
                    | Ansible              |
                    | Prometheus           |
                    | Grafana              |
                    | Git                  |
                    | Backup scripts       |
                    +----------+-----------+
                               |
               Configuration / Monitoring / Backup
                               |
                  +------------+------------+
                  |                         |
                  v                         v
       +---------------------+     +---------------------+
       |   hpc-controller    |     |   hpc-compute01    |
       |---------------------|     |---------------------|
       | Ubuntu Linux        |     | Ubuntu Linux        |
       | slurmctld           |<--->| slurmd              |
       | Munge               |     | Munge               |
       | NFS Server          |---->| NFS Client          |
       | Node Exporter       |     | Node Exporter       |
       | Researcher Login    |     | Job Execution       |
       +----------+----------+     +----------+----------+
                  |                           |
                  +-------------+-------------+
                                |
                                v
                           /research
                         Shared Storage
                                |
                    +-----------+-----------+
                    |                       |
                    v                       v
           /research/projects       /research/results
```

## 4. Server Roles

### hpc-admin

The administration server is used to manage the infrastructure.

Main responsibilities:

- Ansible automation
- Git repository management
- Prometheus monitoring
- Grafana dashboards
- Backup operations
- SSH administration
- Infrastructure configuration

Example:

```bash
ansible all -i inventory.ini -m ping
```

### hpc-controller

The controller is the main HPC management server.

It provides:

- Slurm controller service
- Researcher login environment
- Job submission
- NFS shared storage
- Munge authentication
- Node Exporter monitoring

The main Slurm service running on this server is:

```text
slurmctld
```

`slurmctld` manages the HPC cluster and decides where workloads should run.

### hpc-compute01

The compute node performs the actual research workload.

It provides:

- Slurm compute service
- Python execution
- Shared NFS access
- Munge authentication
- Node Exporter monitoring

The main service is:

```text
slurmd
```

`slurmd` receives jobs from the Slurm controller and executes them.

## 5. Slurm HPC Architecture

Slurm is used as the workload manager.

A researcher does not manually select a compute server.

Instead, the researcher submits a job:

```bash
sbatch medical_job.sh
```

Slurm then decides where the job should run.

```text
Researcher
    |
    | sbatch
    v
slurmctld
hpc-controller
    |
    | schedule job
    v
slurmd
hpc-compute01
    |
    v
Python workload
```

Useful Slurm commands:

```bash
sinfo
```

Shows partitions and compute node status.

```bash
squeue
```

Shows running and waiting jobs.

```bash
sbatch job.sh
```

Submits a batch job.

```bash
srun -N1 hostname
```

Runs a simple job through Slurm.

```bash
scontrol show node hpc-compute01
```

Shows detailed compute node information.

Example healthy cluster:

```text
PARTITION   AVAIL   TIMELIMIT   NODES   STATE   NODELIST
research*   up      infinite    1       idle    hpc-compute01
```

## 6. Munge Authentication

Munge provides authentication between the Slurm controller and compute nodes.

Both machines use the same secret Munge key:

```text
/etc/munge/munge.key
```

Architecture:

```text
hpc-controller
     |
     | authenticated Slurm communication
     |
     v
hpc-compute01
```

The same key must exist on all participating Slurm nodes.

Local Munge test:

```bash
munge -n | unmunge
```

Expected result:

```text
STATUS: Success
```

## 7. Shared Storage With NFS

Researchers submit jobs on the controller, while the workload executes on the compute node.

Both machines therefore need access to the same files.

NFS provides shared storage.

```text
hpc-controller
/research
    |
    | NFS
    v
hpc-compute01
/research
```

Main directories:

```text
/research/projects
/research/results
```

`/research/projects` contains workload scripts and research files.

`/research/results` stores job results.

Example:

```text
/research/projects/medical_analysis.py
/research/projects/medical_job.sh
/research/results/medical-job-11.out
```

The NFS server runs on `hpc-controller`.

The compute node mounts:

```text
hpc-controller:/research
```

to:

```text
/research
```

The persistent NFS mount is configured through:

```text
/etc/fstab
```

## 8. Linux Users and Permissions

Separate Linux users and groups were configured.

Example users:

```text
hpcadmin
researcher1
researcher2
```

Example groups:

```text
hpc-admins
hpc-researchers
```

The research storage uses:

```text
Owner: root
Group: hpc-researchers
```

Example:

```bash
ls -ld /research
```

Result:

```text
drwxrws--- root hpc-researchers /research
```

The `SGID` permission ensures that new files inherit the `hpc-researchers` group.

This supports controlled collaboration between researchers.

## 9. Example Research Workload

The project contains a simple Python research workload using synthetic medical-style data.

No real patient information is used.

File:

```text
research/medical_analysis.py
```

The program generates synthetic values such as:

- Age
- Heart rate
- Systolic blood pressure
- Risk score

It calculates:

- Average age
- Average heart rate
- Average systolic blood pressure
- Number of higher-risk synthetic records

The workload is submitted through:

```text
research/medical_job.sh
```

Example:

```bash
sbatch /research/projects/medical_job.sh
```

Example output:

```text
Starting Slurm research job
Compute node: hpc-compute01
User: researcher1

Medical Research Analysis
=========================

Running on node: hpc-compute01
Patients processed: 100
Average age: ...
Average heart rate: ...
Average systolic BP: ...
High-risk patients: ...

Analysis completed successfully.
Job finished
```

## 10. Ansible Automation

Ansible runs from:

```text
hpc-admin
```

and manages:

```text
hpc-controller
hpc-compute01
```

Inventory structure:

```ini
[hpc_controller]
hpc-controller

[hpc_compute]
hpc-compute01

[hpc_cluster:children]
hpc_controller
hpc_compute

[all:vars]
ansible_user=ubuntu
```

Example connectivity test:

```bash
ansible all -i inventory.ini -m ping
```

Ansible is used for:

- Package installation
- Linux user creation
- Group creation
- Research directory configuration
- Slurm installation
- Munge installation
- Node Exporter installation
- Security hardening
- Firewall configuration

This avoids manually repeating the same configuration on each server.

## 11. Monitoring Architecture

Monitoring uses:

- Node Exporter
- Prometheus
- Grafana

Architecture:

```text
hpc-controller:9100
        \
         \
          v
       Prometheus
        :9090
          |
          v
        Grafana
        :3000
          ^
         /
        /
hpc-compute01:9100
```

Node Exporter collects Linux metrics.

Prometheus stores the metrics.

Grafana displays them.

The dashboard contains:

- HPC Node Status
- CPU Usage
- Memory Usage
- Disk Usage
- Server Uptime
- Network Traffic

Example Prometheus target configuration:

```yaml
- job_name: 'hpc-controller'
  static_configs:
    - targets:
        - 'hpc-controller:9100'

- job_name: 'hpc-compute'
  static_configs:
    - targets:
        - 'hpc-compute01:9100'
```

Example PromQL node status query:

```promql
up{job=~"hpc-controller|hpc-compute"}
```

Result:

```text
1 = UP
0 = DOWN
```

## 12. Security Hardening

The servers were hardened using multiple security controls.

Architecture:

```text
Internet
   |
   v
AWS Security Group
   |
   v
Ubuntu UFW Firewall
   |
   v
SSH Key Authentication
   |
   v
Linux Users and Groups
   |
   v
Application Services
```

Implemented controls include:

- SSH key authentication
- Password SSH login disabled
- Direct root SSH login disabled
- UFW firewall enabled
- Fail2ban enabled
- Automatic security updates enabled
- Linux least-privilege permissions
- AWS Security Groups
- Controlled Slurm ports
- Controlled monitoring ports

SSH settings:

```text
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

Important service ports:

| Port | Purpose |
|---|---|
| 22 | SSH |
| 6817 | Slurm controller |
| 6818 | Slurm compute daemon |
| 9100 | Prometheus Node Exporter |
| 9090 | Prometheus |
| 3000 | Grafana |
| 60001-60010 | Configured Slurm `srun` communication |

The `srun` port range was configured because UFW initially blocked dynamic Slurm job-step communication.

## 13. AWS Network Security

The EC2 systems use private IP communication inside an AWS VPC.

A shared Security Group allows internal communication between cluster systems.

Architecture:

```text
hpc-admin
     |
Private AWS Network
     |
hpc-controller
     |
Private AWS Network
     |
hpc-compute01
```

Public administrative access is restricted separately.

For a production environment, this design could be extended with:

- Private subnets
- Dedicated bastion host
- VPN access
- Central identity management
- Network segmentation
- Dedicated storage
- High availability
- Multiple compute nodes

## 14. Backup and Restore

Backups are initiated from:

```text
hpc-admin
```

Important data is collected from:

```text
hpc-controller
```

Backup flow:

```text
hpc-controller
    |
    | /research
    | /etc/slurm
    | /etc/exports
    v
Compressed archive
    |
    | SCP
    v
hpc-admin
    |
    v
backups/
```

The backup script is located at:

```text
scripts/backup.sh
```

Example execution:

```bash
~/kfi-hpc-lab/scripts/backup.sh
```

A restore test was also performed.

Test process:

```text
Create test research file
        |
        v
Run backup
        |
        v
Delete original file
        |
        v
Extract backup
        |
        v
Recover deleted file
```

This confirms that the backup contains usable recovery data.

## 15. Troubleshooting Experience

Several real infrastructure issues were discovered and resolved during the project.

### Slurm compute node not responding

Symptom:

```text
State=UNKNOWN+NOT_RESPONDING
```

Tools used:

```bash
systemctl status slurmd
journalctl -u slurmd
ping
nc
ss
scontrol
```

Cause:

AWS Security Group rules did not allow the required internal Slurm communication.

Resolution:

Internal communication between cluster nodes was allowed through a shared Security Group.

### Slurm controller communication failure

Error:

```text
Unable to contact slurm controller
```

Verification:

```bash
nc -zv hpc-controller 6817
```

and:

```bash
ss -lntp | grep 6817
```

The required controller communication was restored.

### srun hanging after firewall hardening

The cluster showed:

```text
hpc-compute01 idle
```

but:

```bash
srun -N1 hostname
```

did not complete.

Slurm services and Munge were healthy.

The cause was UFW blocking the job-step communication used by `srun`.

A controlled port range was configured:

```text
60001-60010
```

and allowed through UFW.

Result:

```bash
srun -N1 hostname
```

returned:

```text
hpc-compute01
```

while the firewall remained enabled.

### NFS root access

Remote root initially received:

```text
Permission denied
```

when accessing `/research`.

This behavior was caused by NFS `root_squash`.

The configuration was kept because `root_squash` provides an additional security control.

Research users belonging to:

```text
hpc-researchers
```

could access the shared storage correctly.

## 16. Repository Structure

```text
kfi-mai-hpc-lab/
│
├── ansible/
│   ├── inventory.ini
│   ├── node_exporter.yml
│   ├── security.yml
│   ├── slurm_packages.yml
│   └── users.yml
│
├── monitoring/
│   └── prometheus.yml
│
├── research/
│   ├── medical_analysis.py
│   └── medical_job.sh
│
├── scripts/
│   └── backup.sh
│
├── slurm/
│   └── slurm.conf
│
├── docs/
│
├── screenshots/
│
├── .gitignore
└── README.md
```

Sensitive data is intentionally excluded from Git.

The repository does not contain:

- SSH private keys
- AWS private keys
- Munge secret key
- Passwords
- Tokens
- Backup archives

## 17. Basic Demo

Check Ansible connectivity:

```bash
ansible all -i ansible/inventory.ini -m ping
```

Check the HPC cluster:

```bash
sinfo
```

Test workload execution:

```bash
srun -N1 hostname
```

Submit the research workload:

```bash
sbatch /research/projects/medical_job.sh
```

Check the queue:

```bash
squeue
```

Check results:

```bash
ls -l /research/results
```

Read the latest result:

```bash
cat "$(ls -t /research/results/medical-job-*.out | head -1)"
```

Open Grafana to inspect:

- Node status
- CPU
- Memory
- Disk
- Network
- Uptime

## 18. Skills Demonstrated

This project demonstrates practical experience with:

- Linux administration
- Server management
- HPC concepts
- Slurm administration
- Munge authentication
- AWS networking
- SSH administration
- Linux users and groups
- File permissions
- Shared NFS storage
- Ansible automation
- Python workloads
- Prometheus monitoring
- Grafana dashboards
- Firewall configuration
- Security hardening
- Troubleshooting
- Logging
- Backup and restore
- Git and GitHub
- Technical documentation
- Researcher support

## 19. Future Improvements

The current project contains one controller and one compute node.

Possible future improvements include:

- Additional compute nodes
- GPU compute nodes
- Central LDAP or Active Directory authentication
- Slurm accounting database
- MariaDB and slurmdbd
- High availability controller
- Dedicated NFS storage server
- Object storage
- Automated Grafana provisioning
- Prometheus Alertmanager
- Email or Slack alerts
- TLS certificates
- VPN access
- Private AWS subnets
- Infrastructure as Code with Terraform
- CI/CD pipeline
- Containerized workloads
- Apptainer or Singularity
- Automated disaster recovery

## 20. Project Goal

The goal of this project is to demonstrate the complete lifecycle of a small research computing environment:

```text
Provision
   ↓
Configure
   ↓
Secure
   ↓
Schedule workloads
   ↓
Share data
   ↓
Monitor
   ↓
Troubleshoot
   ↓
Backup
   ↓
Recover
```

It provides a practical environment for understanding Linux server administration and HPC infrastructure used in research-oriented organizations.
