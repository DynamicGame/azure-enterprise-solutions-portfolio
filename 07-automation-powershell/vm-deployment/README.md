⚙️ PowerShell Automated VM Deployment
Consistent, repeatable infrastructure deployment using PowerShell + Azure CLI
This project demonstrates how to build a fully automated VM deployment pipeline using:

PowerShell

Azure CLI

ARM/Bicep fundamentals

Parameterised deployment

Idempotent infrastructure automation

Reusable scripts

This is the kind of automation expected from a Modern Workplace Engineer, Cloud Administrator, or DevOps Engineer.

🧩 Business Problem
Manual VM creation leads to:

Inconsistent configurations

Human error

Slow provisioning

No repeatability

No standardisation

No audit trail

This project solves these issues by creating a PowerShell‑driven VM deployment automation framework.

🏗️ Architecture Overview
```bash 
check vm-deployment/automation-architecture.png
```
🧱 Azure Services Used
Virtual Machines

Virtual Networks

Network Security Groups

Public IPs

Disks

ARM/Bicep (optional)

Azure CLI

PowerShell

🎯 Automation Features
✔ Fully automated VM deployment
Resource group

VNet + Subnet

NIC

NSG

VM

Tags

Optional public IP

✔ Parameterised
You can deploy multiple VMs with different:

Names

Sizes

Images

Networks

Admin credentials

✔ Idempotent
Safe to run multiple times — only missing resources are created.

✔ Modular
Scripts are split into:

Deployment

Configuration

Cleanup

✔ Production‑ready
Matches real enterprise automation patterns.

🚀 Deployment Scripts
1. deploy-vm.ps1
Creates:

Resource group

VNet + Subnet

NSG

NIC

VM

Supports parameters:

-VmName

-VmSize

-Location

-Image

-AdminUser

-AdminPassword

2. configure-vm.ps1
Applies post‑deployment configuration:

Install updates

Install extensions

Configure WinRM / SSH

Apply tags

Join domain (optional)

Install baseline tools

3. cleanup-vm.ps1
Removes:

VM

NIC

NSG

Public IP

VNet

Resource group (optional)

🧹 Cleanup Script
A cleanup script is included to safely remove all resources created in this project:

cleanup-vm.ps1
This ensures your subscription stays clean and avoids leftover compute/network costs.

📁 Folder Structure
```bash
/07-automation-powershell
    /vm-deployment
        README.md
        deploy-vm.ps1
        configure-vm.ps1
        cleanup-vm.ps1
        templates/
            vm-template.json   (optional ARM)
            vm-template.bicep  (optional Bicep)
        screenshots/
```

🎓 Skills Demonstrated
PowerShell automation

Azure CLI scripting

ARM/Bicep fundamentals

Infrastructure as Code (IaC)

Idempotent deployment patterns

VM networking fundamentals

Azure compute provisioning

🎯 What This Project Demonstrates
This project shows that you can:

Automate infrastructure end‑to‑end

Build reusable deployment scripts

Apply IaC principles

Standardise VM builds

Reduce human error

Deliver consistent, repeatable deployments
