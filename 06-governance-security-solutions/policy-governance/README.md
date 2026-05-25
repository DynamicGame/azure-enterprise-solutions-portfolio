🛡️ Governance & Compliance Solutions
Tag Enforcement + Resource Locks + Azure Policy
This project demonstrates how to design and implement a governance and compliance framework using:

Azure Policy

Tag enforcement

Resource locks

Management groups

Compliance reporting

This ensures that resources are deployed consistently, cost governance is enforced, and accidental deletion or misconfiguration is prevented.

This is the kind of work expected from a Cloud Governance Engineer, Azure Administrator, or Cloud Architect.

🧩 Business Problem
Organisations often struggle with:

No tagging standards → cost chaos

No enforcement → inconsistent deployments

Accidental deletion of critical resources

No central governance model

No visibility into compliance

No guardrails for engineers

This project solves these issues by implementing a governance baseline using Azure-native tools.

🏗️ Architecture Overview
```bash
check \policy-governace\governance-architecture.png
```

🧱 Azure Services Used
Governance
Management Groups

Azure Policy

Policy Assignments

Policy Remediation

Initiative Definitions

Security
Resource Locks

Allowed Locations Policy

SKU Restrictions

Cost Governance
Tag enforcement

Required tags:

Environment

Owner

CostCenter

🎯 Governance Controls Implemented
1. Tag Enforcement
Policies implemented:

Require tag: Environment

Require tag: Owner

Require tag: CostCenter

Deny resource creation if tags are missing

2. Allowed Locations
Prevents deployments outside approved regions:

uksouth

ukwest

3. SKU Restrictions
Prevents expensive or non-approved SKUs:

Restrict VM sizes

Restrict Storage SKUs

Restrict Public IP SKUs

4. Resource Locks
Applied to:

Production resource groups

Critical storage accounts

Log Analytics workspaces

Identity resources

Types:

ReadOnly

Delete

5. Compliance Reporting
Azure Policy compliance dashboard shows:

Compliant resources

Non-compliant resources

Remediation tasks

Policy evaluation results

🚀 Deployment Steps
1. Create Management Group Structure
Run:

create-management-groups.ps1

Creates:

Root

Corp

Dev/Test/Prod child groups

2. Deploy Governance Policies
Run:

deploy-policies.ps1

Deploys:

Tag enforcement

Allowed locations

SKU restrictions

Policy initiatives

3. Assign Policies to Management Groups
Run:

assign-policies.ps1

Applies policies at the Corp management group level.

4. Apply Resource Locks
Run:

apply-locks.ps1

Applies:

Delete locks

ReadOnly locks

To critical resources.

5. Review Compliance
Run:

audit-compliance.ps1

Outputs:

Non-compliant resources

Missing tags

Violations

Remediation recommendations

🧹 Cleanup Script
A cleanup script is included to safely remove all governance resources created in this project:

Policy definitions

Policy assignments

Management groups (optional)

Resource locks

Initiatives

Cleanup Script
cleanup-governance.ps1

This ensures your tenant remains clean and prevents leftover governance objects.

🧽 Cleanup Workflow
Remove policy assignments

Remove policy definitions

Remove initiatives

Remove resource locks

Optionally remove management groups

This mirrors real enterprise governance teardown procedures.

📁 Folder Structure
```bash 
/06-governance-security-solutions
    /policy-governance
        README.md
        create-management-groups.ps1
        deploy-policies.ps1
        assign-policies.ps1
        apply-locks.ps1
        audit-compliance.ps1
        cleanup-governance.ps1   
        screenshots/
```
🎓 AZ‑104 Skills Demonstrated
Azure Policy

Management Groups

Resource Locks

Tag governance

Policy assignments

Policy compliance

Governance architecture

🎯 What This Project Demonstrates
This project shows that I can:

Build enterprise governance frameworks

Enforce tagging and cost controls

Prevent accidental deletion

Apply policies at scale

Use management groups effectively

Audit and remediate compliance issues
