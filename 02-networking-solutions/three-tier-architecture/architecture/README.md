🧠 Architecture Explanation

1. Web Tier (Public‑Facing Layer)
Exposed to the internet through a Public Load Balancer

Hosts IIS web servers

Only ports 80/443 allowed from the internet

Assigned to asg-web

Protected by NSG + Azure Firewall

Purpose:  
Handles user traffic and serves the front‑end.

2. App Tier (Internal Logic Layer)
Accessible only from the Web Tier

Behind an Internal Load Balancer

Runs backend logic / APIs

Only port 8080 allowed from asg-web

Assigned to asg-app

Purpose:  
Processes business logic and communicates with the database.

3. Database Tier (Private Data Layer)
Azure SQL Database

Public access disabled

Exposed only via Private Endpoint

Private DNS zone resolves SQL to a private IP

Only port 1433 allowed from asg-app

Purpose:  
Stores application data securely with no public exposure.

4. Azure Firewall (Premium)
All outbound traffic forced through firewall using UDRs

Application rules for Windows Update, GitHub, HTTPS

Network rules for DNS, SQL, NTP

Protects all tiers

Purpose:  
Centralized security inspection and egress control.

5. Route Tables (UDRs)
Web → Firewall

App → Firewall

DB → Firewall

Purpose:  
Ensures all outbound traffic is inspected (zero‑trust).

6. Azure Bastion
Deployed in AzureBastionSubnet

Provides RDP/SSH without public IPs

All management traffic stays inside Azure

Purpose:  
Secure VM access without exposing public IPs.

7. Private Endpoints + Private DNS
Storage Account

Key Vault

SQL Database

Purpose:  
Ensures all service traffic stays on the Azure backbone network.
