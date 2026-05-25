📘 Three‑Tier Enterprise Network on Azure (Project 2)
Azure CLI • Azure Firewall • Private Endpoints • Private DNS • Bastion • Load Balancers • ASGs • NSGs • Route Tables
This project demonstrates a full enterprise‑grade Azure network architecture, deployed entirely using Azure CLI.
It follows zero‑trust principles, uses private connectivity, and mirrors the design patterns used in real production landing zones.

This is the flagship project of my Azure portfolio.

🧱 Architecture Overview
This solution implements a secure three‑tier application architecture:

```bash 
Internet
   │
Public Load Balancer
   │
Web Tier (IIS)
   │
Internal Load Balancer
   │
App Tier (IIS/API)
   │
Azure SQL (Private Endpoint)
```
All traffic is inspected by Azure Firewall, and all management access is handled through Azure Bastion — no public IPs on any VM.

🌐 Network Topology
Virtual Network: 10.0.0.0/16

| Subnet | CIDR | Purpose |
| --- | --- | --- |
| ``web-subnet`` | 10.0.1.0/24 | Public LB + Web VMs |
| ``app-subnet`` | 10.0.2.0/24 | Internal LB + App VMs |
| ``db-subnet`` | 10.0.3.0/24 | SQL Private Endpoint |
| ``AzureBastionSubnet`` | 10.0.10.0/27 | Azure Bastion |
| ``AzureFirewallSubnet`` | 10.0.20.0/26 | Azure Firewall |
| ``private-endpoints`` | 10.0.30.0/24 | Storage + Key Vault Private Endpoints |


🔐 Security Architecture
Network Security Groups (NSGs)
Web NSG

Allow 80/443 from Internet

App NSG

Allow 8080 from asg-web only

DB NSG

Allow 1433 from asg-app only

Application Security Groups (ASGs)
asg-web

asg-app

asg-db

Azure Firewall (Premium)
All outbound traffic forced through firewall

Application rules for Windows Update, GitHub, web traffic

Network rules for DNS, SQL, NTP

Route Tables (UDRs)
Web → Firewall

App → Firewall

DB → Firewall

This enforces zero‑trust segmentation between tiers.

🛰️ Load Balancers
Public Load Balancer (Web Tier)
Frontend: Public IP

Backend: Web VMs

Probe: TCP 80

Rule: 80 → backend

Internal Load Balancer (App Tier)
Frontend: Private IP

Backend: App VMs

Probe: TCP 8080

Rule: 8080 → backend

🛡️ Private Connectivity
Private Endpoints
Azure SQL

Storage Account (Blob)

Key Vault

Private DNS Zones
privatelink.database.windows.net

privatelink.blob.core.windows.net

privatelink.vaultcore.azure.net

Linked to the VNet for automatic name resolution.

🖥️ Compute Layer
Web Tier
2× Windows Server 2022 VMs

IIS installed via Custom Script Extension

Behind Public Load Balancer

Assigned to asg-web

App Tier
2× Windows Server 2022 VMs

IIS installed (placeholder for API/backend)

Behind Internal Load Balancer

Assigned to asg-app

Database Tier
Azure SQL Database (S0)

Public access disabled

Private Endpoint only

🔒 Secure Access
Azure Bastion
Deployed in AzureBastionSubnet

Provides RDP/SSH without public IPs

All management traffic stays inside Azure backbone

📁 Repository Structure
```bash
/three-tier-architecture
    /architecture
        diagram.png
    /scripts
        deploy-network.ps1
        deploy-firewall.ps1
        route-tables.ps1
        deploy-web.ps1
        deploy-app.ps1
        deploy-db.ps1
        deploy-private-endpoints.ps1
        deploy-bastion.ps1
        nsg-rules.ps1
        cleanup.ps1
    /screenshots
    README.md
```

🚀 Deployment Order

deploy-network.ps1

deploy-firewall.ps1

route-tables.ps1

deploy-web.ps1

deploy-app.ps1

deploy-db.ps1

deploy-private-endpoints.ps1

deploy-bastion.ps1

nsg-rules.ps1

cleanup.ps1 (optional teardown)

🎯 Key Learning Outcomes
By completing this project, I demonstrated:

Designing secure Azure landing zone–style networks

Implementing zero‑trust segmentation

Using Azure Firewall with UDRs

Deploying multi‑tier architectures with load balancers

Enforcing private connectivity with Private Endpoints

Managing DNS with Private DNS Zones

Automating infrastructure with Azure CLI

Securing VM access with Azure Bastion

Applying NSGs and ASGs correctly

Building enterprise‑grade cloud environments

