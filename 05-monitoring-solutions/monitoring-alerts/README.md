📡 Monitoring & Alerting Solutions
Azure Monitor + Alerts for Compute and Storage
This project demonstrates how to design and implement a proactive monitoring and alerting solution for Azure compute and storage workloads using:

Azure Monitor

Log Analytics

Metrics Alerts

Activity Log Alerts

Dashboards

Action Groups

This is the foundation of operational excellence, enabling organisations to detect issues early, respond quickly, and maintain service reliability.

🧩 Business Problem
Organisations often struggle with:

No visibility into VM performance

No alerts when CPU, memory, or disk spikes

No monitoring for storage capacity or latency

No centralised logging

No dashboards for operations teams

Reactive firefighting instead of proactive detection

This project solves these challenges by implementing a complete monitoring and alerting architecture for Azure compute and storage.

🏗️ Architecture Overview
```bash 
/monitoring-alerts/architecture-diagram.png
```

🧱 Azure Services Used
Monitoring
Azure Monitor

Log Analytics Workspace

VM Insights

Storage Insights

Metrics Explorer

Dashboards

Alerting
Metric Alerts

Activity Log Alerts

Log Alerts (KQL)

Action Groups

🔍 Monitoring Scenarios Implemented
Compute (VMs)
CPU % > 80%

Memory usage > 80% (via Log Analytics)

Disk queue length > threshold

VM heartbeat missing (VM down)

Guest OS logs (optional)

Storage Accounts
Storage capacity > 80%

Transactions spike

Egress/ingress anomalies

Blob latency > threshold

File share capacity alerts

Activity Log Alerts
VM start/stop

Resource deletion

Role assignment changes

Network security rule changes

🚀 Deployment Steps
1. Deploy Log Analytics Workspace
Run:

deploy-law.ps1

Creates a workspace and enables VM Insights.

2. Connect VMs + Storage to Log Analytics
Run:

connect-resources.ps1

Enables:

VM Insights

Storage diagnostic settings

Activity log streaming

3. Create Action Groups
Run:

create-action-groups.ps1

Creates:

Email notifications

Optional: Teams/Slack webhook

Optional: SMS

4. Create Alerts
Run:

create-alerts.ps1

Creates:

Compute Alerts
CPU high

Memory high

Disk queue length

VM heartbeat missing

Storage Alerts
Capacity threshold

Latency threshold

Transaction spike

Activity Log Alerts
Resource deletion

Role assignment changes

5. Build Dashboards
Run:

create-dashboard.ps1

Creates a unified dashboard showing:

VM performance

Storage performance

Alerts overview

Log Analytics queries

Activity log summary

6. Cleanup Script
A cleanup script is included to remove all monitoring resources created in this project:

Log Analytics Workspace

Diagnostic settings

Alerts

Action Groups

VM Insights extensions

Dashboard

Resource group (optional)

Cleanup Script
cleanup-monitoring.ps1

This prevents unnecessary Log Analytics ingestion costs and avoids alert noise after the project is complete.

🧽 Cleanup Workflow
Remove all alert rules

Remove Action Groups

Remove diagnostic settings from Storage Accounts

Remove VM Insights extensions

Delete dashboard

Delete Log Analytics Workspace

Optionally delete the resource group

This matches real SRE/Cloud Ops teardown standards.

🛡️ Security Considerations
Diagnostic logs stored in Log Analytics (secure, centralised)

Access controlled via RBAC

Alerts routed through secure Action Groups

No public endpoints required

Optional: Private Link for Log Analytics

💸 Cost Optimisation
Log Analytics retention tuned to 30–90 days

Only essential metrics collected

Alerts tuned to avoid noise

Dashboards reduce troubleshooting time

VM Insights uses efficient data collection rules

🎓 AZ‑104 Skills Demonstrated
Azure Monitor

Log Analytics

KQL queries

Metrics + Activity Log alerts

Action Groups

Dashboards

Diagnostic settings

VM Insights

Storage monitoring

📁 Folder Structure
```bash 
/05-monitoring-solutions
    /monitoring-alerts
        README.md
        deploy-law.ps1
        connect-resources.ps1
        create-action-groups.ps1
        create-alerts.ps1
        create-dashboard.ps1
        cleanup-monitoring.ps1
        screenshots/
```

🎯 What This Project Demonstrates
This project shows that I can:

Build proactive monitoring solutions

Detect performance issues early

Configure alerts for compute + storage

Use Log Analytics + KQL effectively

Build dashboards for operations teams

Implement enterprise‑grade observability