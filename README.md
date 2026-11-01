# Azure Enterprise Solutions Portfolio

**Abdulbasit Soliu · Cloud infrastructure, identity and PowerShell automation**

Practical Azure projects that connect an infrastructure problem to a documented design and supporting scripts. My focus is understanding how compute, networks, access control and operations fit together, then making that work easier to repeat.

[LinkedIn](https://www.linkedin.com/in/abdulbasit-soliu-75901b250/) · [GitHub](https://github.com/DynamicGame)

## Start here

- **[Compute: availability-set web servers](01-compute-vm-solutions/high-availability-webserver/)** — two Windows VMs, IIS, network rules and deployment screenshots.
- **[Networking: three-tier architecture](02-networking-solutions/)** — segmented workloads, load balancers, private endpoints, DNS and management access.
- **[Review notes](docs/REVIEW.md)** — implementation boundaries, corrections and the remaining validation work.

## Project map

| Area | What the work covers | Current evidence / status |
| --- | --- | --- |
| [01 · Compute](01-compute-vm-solutions/high-availability-webserver/) | Windows VMs, availability sets, IIS, NSGs | Scripts, diagram and deployment screenshots; revised scripts need a fresh deployment check |
| [02 · Networking](02-networking-solutions/) | Three-tier VNet, ASGs, load balancers, Firewall, Bastion, private DNS | Design and component scripts; integration validation outstanding |
| [03 · Storage](03-storage-solutions/) | Blob/Files private endpoints, RBAC, lifecycle, SAS and retention | Implementation in progress |
| [04 · Identity](04-identity-access-solutions/rbac-environment-model/) | Entra groups and Dev/Test/Prod access scopes | Implementation in progress |
| [05 · Monitoring](05-monitoring-solutions/monitoring-alerts/) | Workspace, agent onboarding, alerts and operations views | Implementation in progress; see monitoring limitations |
| [06 · Governance](06-governance-security-solutions/policy-governance/) | Management groups, policy definitions, assignments and locks | Implementation in progress |
| [07 · Automation](07-automation-powershell/vm-deployment/) | Parameterised VM deployment and ARM/Bicep templates | Implementation in progress |
| [08 · Modern workplace](08-modern-workplace-architecture/) | Intune, Autopilot and endpoint policy design | Design examples and Graph scripts; tenant validation outstanding |

Status describes repository evidence, not a production certification. These are portfolio environments; uptime, recovery and security outcomes require measured tests in an Azure subscription.

## Skills demonstrated

| Discipline | Examples in this repository |
| --- | --- |
| Azure administration | Resource groups, virtual machines, networks, storage and tagging |
| Networking | Subnets, NSGs, ASGs, load-balancer probes, routes and private DNS |
| Identity and workplace | Entra ID group access, Azure RBAC and Intune policy design |
| Automation | PowerShell, Azure CLI and infrastructure templates |
| Engineering practice | Architecture explanations, deployment order, validation plans and teardown notes |

The cloud projects support my AZ-104 learning. Certification attainment is not claimed here.

## Working with the projects

1. Read the project README and [review notes](docs/REVIEW.md) before choosing a script.
2. Use an isolated Azure subscription or dedicated lab scopes. Check the selected tenant and subscription with `az account show`.
3. Install PowerShell 7.3 or later and Azure CLI; sign in using `az login`. Install only the CLI extensions or Graph modules required by the selected project.
4. Supply your own resource names, scope IDs and credentials. Replace draft placeholders before execution. Never commit passwords, SAS tokens, exported tenant data or local parameter files.
5. Follow the documented deployment order, capture checks and remove the lab resources when finished. Firewall, Bastion, VMs, SQL and log ingestion can continue to incur charges.

No script was deployed to Azure as part of the November 2026 repository review. Local parsing and link checks do not establish deployment success.

## Repository guide

Each project README explains the problem, implemented components, architecture, script order, validation and remaining work. Mermaid diagrams are editable documentation; the original PNG diagrams remain available as design history where their assumptions differ from the scripts.

See [contribution and evidence guidance](CONTRIBUTING.md) for the standard used when adding a project or marking a milestone complete.
