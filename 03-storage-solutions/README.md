📦 Secure Storage Solutions (Blob + Azure Files + Private Endpoint)
Enterprise‑Grade Storage Architecture with SAS, RBAC, Lifecycle Policies & Azure AD Kerberos
This project demonstrates how to design and deploy a secure, scalable, and compliant Azure Storage solution using Blob Storage and Azure Files, protected with private endpoints, RBAC, SAS governance, immutability, and lifecycle management.

It reflects real‑world requirements for organisations that need to store, protect, and govern data in the cloud while maintaining strict access control and compliance.

This solution aligns with AZ‑104, Modern Workplace Engineering, and enterprise security best practices.

🧩 Business Problem
Organisations often struggle with:

Uncontrolled access to storage accounts

Over‑permissioned users

Lack of governance around SAS tokens

Data stored indefinitely without lifecycle rules

No immutability or compliance protection

Public endpoints exposing data to the internet

Inconsistent access to Azure Files across devices

This project solves these challenges by implementing a secure, private, identity‑integrated storage architecture.

🏗️ Architecture Overview

```bash
 Check 03-storage-solutions\Architecture.drawio.png
                      
```
🧱 Azure Services Used
Core Services
Azure Storage Account (StorageV2)

Blob Storage

Azure Files

Private Endpoints

Private DNS Zones

Azure AD Kerberos Authentication

Azure RBAC

SAS Tokens (Account, Service, User Delegation)

Governance & Security
Immutability Policies (Legal Hold + Time‑Based Retention)

Soft Delete (Blobs + Containers + File Shares)

Versioning

Firewall Rules

Lifecycle Management Policies

🔐 Identity Model: Azure AD Kerberos (Cloud‑Only)
Azure Files is configured to use Azure AD Kerberos authentication, enabling:

Passwordless access

No domain controllers required

Works with Entra ID joined devices

NTFS‑style permissions enforced via Kerberos

Modern, cloud‑native identity model

This is the recommended approach for Modern Workplace environments.

🚀 Deployment Steps
1. Deploy the Storage Account
Run:

deploy-storage.ps1

This script:

Creates the Storage Account

Enforces TLS 1.2

Disables public access

Enables soft delete + versioning

Creates Blob + File shares

Creates private endpoints

Creates Private DNS zones

Configures network rules

2. Configure RBAC
Run:

configure-rbac.ps1

Assigns least‑privilege roles:

Storage Blob Data Reader

Storage Blob Data Contributor

Storage File Data SMB Share Contributor

Storage File Data SMB Share Elevated Contributor

3. Generate SAS Tokens
Run:

generate-sas.ps1

Generates:

Account SAS

Service SAS

User Delegation SAS

Time‑bound SAS

IP‑restricted SAS

Includes warnings about SAS misuse.

4. Apply Lifecycle Policies
Modify lifecycle-policy.json then run:

apply-lifecycle.ps1

Default rules:

Hot → Cool after 30 days

Cool → Archive after 90 days

Delete after 365 days

Delete old versions

Delete snapshots

5. Enable Immutability
Run:

enable-immutability.ps1

Enables:

Time‑based retention

Legal hold

WORM protection

6. Cleanup Script
A full cleanup script is included to safely remove all storage resources created in this project:

Storage Account

Containers

Lifecycle management policies

SAS policies

Immutability policies (if unlocked)

Resource group (optional)

Cleanup Script
cleanup-storage.ps1

This script ensures no storage costs continue after the project and prevents leftover diagnostic or immutable configurations.

🧽 Cleanup Workflow
Remove lifecycle management rules

Remove immutability policies (if allowed)

Remove legal holds

Delete containers

Delete the storage account

Optionally delete the resource group

This mirrors real enterprise teardown procedures.

🛡️ Security Considerations
No public endpoints

Private endpoints for Blob + File

RBAC enforced at the Storage Account level

NTFS‑style permissions enforced via Azure AD Kerberos

SAS tokens restricted by:

Time

IP

Permissions

Immutability prevents tampering

Lifecycle rules reduce stale data

Soft delete protects against accidental deletion

💸 Cost Optimisation
Lifecycle rules automatically tier or delete old data

Archive tier reduces long‑term storage cost

Versioning + soft delete configured with retention limits

Private endpoints reduce risk of data exfiltration

Azure Files premium tier optional (only if needed)

🎓 AZ‑104 Skills Demonstrated
Secure Storage Account configuration

RBAC + identity integration

SAS governance

Private endpoints + DNS

Lifecycle management

Immutability + compliance

Azure Files authentication

PowerShell + CLI automation

📁 Folder Structure
``` bash
/03-storage-solutions
    /secure-storage
        README.md
        deploy-storage.ps1
        configure-rbac.ps1
        generate-sas.ps1
        lifecycle-policy.json
        apply-lifecycle.ps1
        enable-immutability.ps1
        cleanup-storage.ps1
        screenshots/
```
🎯 What This Project Demonstrates
This project shows that I can:

Build secure storage architectures

Integrate identity with Azure AD Kerberos

Enforce governance and compliance

Automate deployments

Apply least‑privilege access

Protect data with immutability

Implement lifecycle optimisation

Use private networking for storage


