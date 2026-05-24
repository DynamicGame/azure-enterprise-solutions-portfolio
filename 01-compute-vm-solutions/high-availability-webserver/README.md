🌐 Highly Available Web Server on Azure
Azure Virtual Machines + Availability Set | Enterprise‑Grade Compute Solution
A production‑ready, highly available web server architecture built using Azure Virtual Machines, Availability Sets, NSGs, and Virtual Networks.
This project demonstrates how to design and deploy resilient compute infrastructure aligned with AZ‑104 Microsoft Azure Administrator skills.

🧩 Business Problem
A company hosts an internal web application that suffers from:

Single‑point‑of‑failure on a physical server

Downtime during OS updates

Hardware‑related outages

Limited scalability

The business needs a redundant, cloud‑based, highly available solution that ensures the application stays online even during failures or maintenance.

Azure Availability Sets solve this by distributing VMs across fault domains and update domains, ensuring at least one VM remains operational.


| Service | Purpose |
| --- | --- |
| **Virtual Machines** | Hosts the web workload |
| **Availability Set** | Ensures redundancy across racks & update cycles |
| **Virtual Network** | Private network boundary |
| **Subnet** | Logical segmentation for compute tier |
| **NSG** | Filters inbound/outbound traffic |
| **Public IP** | Optional external access |
| **Managed Disks** | Encrypted OS disks |
| **Tags** | Cost & ownership governance |

🚀 Deployment Scripts
This project includes three automation scripts located in /scripts.

1. deploy.ps1
Deploys the full environment:
Resource Group
VNet + Subnet
NSG
Availability Set
Two VMs
Tags

2. nsg-rules.ps1
Applies secure NSG rules:
Allow HTTP (80)
Allow HTTPS (443)
Restrict RDP/SSH to admin IP
Optional deny‑all fallback

3. cleanup.ps1
Safely deletes the entire environment with a confirmation prompt.

🔐 Security Considerations
Restrict RDP/SSH to your IP only
Use Azure Bastion for secure remote access
Enable Azure Disk Encryption
Apply NSGs at subnet level for layered security
Use resource locks to prevent accidental deletion
Apply tags for cost tracking and governance

💰 Cost Optimisation
Use B‑series VMs for dev/test
Use D‑series for production workloads
Enable auto‑shutdown for non‑production environments
Use Standard HDD for OS disks unless performance is required
Availability Sets have no cost — only VMs incur charges

🧠 What This Demonstrates (AZ‑104 Skills)
This project validates your ability to:
Deploy and manage Azure Virtual Machines
Design highly available compute solutions
Configure VNets, subnets, NICs, and IP addressing
Implement NSGs and network security
Apply governance (tags, locks)
Automate deployments with PowerShell & CLI
Understand fault domains and update domains
Build resilient, production‑ready infrastructure

📌 Future Enhancements
Add Azure Load Balancer for traffic distribution
Add Azure Bastion for secure remote access
Add VM Scale Set version of this project
Add monitoring + alerts (CPU, disk, availability)
Add Azure Backup & Recovery Vault