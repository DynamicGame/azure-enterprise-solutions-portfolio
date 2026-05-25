🔐 Identity & Access Solutions
Role‑Based Access Model for Dev / Test / Prod Environments (Enterprise RBAC Architecture)
This project demonstrates how to design and implement a scalable, secure, and least‑privilege access model across three isolated Azure subscriptions: Dev, Test, and Prod.

It reflects how real organisations enforce governance, protect production workloads, and ensure engineers only have the access they need — nothing more.
This is a core responsibility of Modern Workplace Engineers, Azure Administrators, and Cloud Identity Architects.

🧩 Business Problem
Many organisations struggle with:

Engineers having excessive access across environments

No separation between Dev, Test, and Prod

Direct user assignments instead of group‑based access

Over‑privileged roles in production

No consistent RBAC model

No auditability or governance controls

These issues increase operational risk, reduce accountability, and violate least‑privilege principles.

This project solves these challenges by implementing a clean, scalable RBAC architecture using:

Entra ID groups

Subscription‑level isolation

Least‑privilege role assignments

Break‑glass governance for Prod

Automated auditing

🏗️ Architecture Overview
``` bash 
check \rbac-environment-model\architecture-overview.drawio.png
```
🧱 Azure Services Used

Identity & Access

Entra ID Security Groups

Azure RBAC

Custom roles (optional)

User Access Administrator (optional)

Governance

Subscription‑level RBAC

Least privilege enforcement

Break‑glass access model

Access reviews (optional)

🔐 Identity Model

This project uses group‑based access control, which is the recommended enterprise approach:

No direct user assignments

All access is granted via Entra ID groups

Groups map directly to RBAC roles

RBAC roles are assigned at the subscription scope

This ensures:

Auditability

Scalability

Least privilege

Easy onboarding/offboarding

🗂️ Environment Structure
✔ Three separate subscriptions
Subscription‑Dev

Subscription‑Test

Subscription‑Prod

This mirrors real enterprise environments where:

Dev is flexible

Test is controlled

Prod is locked down

👥 Entra ID Group Structure

| Group Name | Purpose | RBAC Role | Scope |
| --- | --- | --- | --- |
| Dev-Readers | View Dev resources | Reader | Dev Subscription |
| Dev-Contributors | Build/change Dev resources | Contributor | Dev Subscription |
| Test-Readers | View Test resources | Reader | Test Subscription |
| Test-Contributors | Modify Test resources | Contributor | Test Subscription |
| Prod-Readers | View Prod resources | Reader | Prod Subscription |
| Prod-Contributors | Limited Prod changes | Contributor | Prod Subscription |
| Prod-Owners | Break-glass only | Owner | Prod Subscription |

🚀 Deployment Steps
1. Create Entra ID Groups
Run:

create-groups.ps1

Creates all Dev/Test/Prod groups.

2. Assign RBAC Roles
Run:

assign-rbac.ps1

Assigns:

Reader

Contributor

Owner (restricted)

At the subscription scope.

3. Create Environment Structure
Run:

create-environment-structure.ps1

Creates:

Subscription‑Dev

Subscription‑Test

Subscription‑Prod

(Or links existing ones.)

4. Audit Access
Run:

audit-access.ps1

Outputs:

All RBAC assignments

Violations (direct user assignments)

Over‑privileged roles

Non‑compliant access

5. Cleanup Script
A cleanup script is included to safely remove all identity and RBAC resources created in this project:

Entra ID groups

RBAC assignments

Placeholder resource groups (if used)

Cleanup Script
cleanup-identity.ps1

This script ensures your tenant remains clean and prevents orphaned RBAC assignments or unused groups.

🧽 Cleanup Workflow
Remove RBAC assignments for all Dev/Test/Prod groups

Delete Entra ID groups

Remove placeholder resource groups (RG‑Dev, RG‑Test, RG‑Prod)

Validate no direct user assignments remain

This reflects real identity governance teardown procedures.

🛡️ Security Considerations
No direct user assignments

No Contributor access in Prod unless justified

Owner role restricted to break‑glass

Access granted only through groups

Subscription‑level isolation

Optional: Access reviews

Optional: Privileged Identity Management (PIM)

💸 Cost Optimisation
Dev/Test subscriptions can use cost‑saving policies

Prod subscription can enforce stricter governance

RBAC prevents accidental resource creation in Prod

Clear separation simplifies cost reporting

🎓 AZ‑104 Skills Demonstrated
RBAC design

Subscription‑level access control

Entra ID group management

Least privilege

Governance and compliance

Access auditing

Identity architecture

📁 Folder Structure
```bash 
/04-identity-access-solutions
    /rbac-environment-model
        README.md
        create-groups.ps1
        assign-rbac.ps1
        create-environment-structure.ps1
        audit-access.ps1
        cleanup-identity.ps1
        screenshots/
```
🎯 What This Project Demonstrates
This project shows that I can:

Design enterprise RBAC models

Implement least‑privilege access

Separate Dev/Test/Prod environments

Use Entra ID groups for scalable access

Apply RBAC at the correct scope

Audit and govern access

Think like a Cloud Identity Architect