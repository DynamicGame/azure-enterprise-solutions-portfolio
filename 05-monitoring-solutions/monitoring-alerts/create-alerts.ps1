<#
    Project: Monitoring & Alerting Solutions
    Script: create-alerts.ps1
    Purpose: Create Azure Monitor alerts for VMs, Storage Accounts,
             and Activity Log events using Action Groups.
#>

# -----------------------------
# Variables
# -----------------------------
$rgName          = "rg-monitoring"
$actionGroupEmail = "ag-email-alerts"
$actionGroupOps   = "ag-ops-webhook"

Write-Host "`nCreating Azure Monitor Alerts..." -ForegroundColor Cyan

# -----------------------------
# Helper: Get Action Group ID
# -----------------------------
function Get-AG($name) {
    return az monitor action-group show `
        --name $name `
        --resource-group $rgName `
        --query "id" -o tsv
}

$agEmailId = Get-AG $actionGroupEmail
$agOpsId   = Get-AG $actionGroupOps

if (-not $agEmailId) { Write-Host "ERROR: Email Action Group not found." -ForegroundColor Red; exit }
if (-not $agOpsId)   { Write-Host "ERROR: Ops Action Group not found."   -ForegroundColor Red; exit }

# -----------------------------
# 1. VM Alerts (CPU, Memory, Disk, Heartbeat)
# -----------------------------
Write-Host "`nCreating VM Alerts..." -ForegroundColor Yellow

$vms = az vm list -d -o json | ConvertFrom-Json

foreach ($vm in $vms) {

    $vmId = $vm.id
    $vmName = $vm.name
    

    Write-Host "Configuring alerts for VM: $vmName" -ForegroundColor Cyan

    # CPU > 80%
    az monitor metrics alert create `
        --name "CPU-High-$vmName" `
        --resource-group $rgName `
        --scopes $vmId `
        --condition "avg Percentage CPU > 80" `
        --description "CPU usage above 80% on $vmName" `
        --action $agEmailId `
        --severity 2 `
        --window-size 5m `
        --evaluation-frequency 1m | Out-Null

    # Memory > 80% (Log Analytics)
    az monitor scheduled-query alert create `
        --name "Memory-High-$vmName" `
        --resource-group $rgName `
        --scopes $vmId `
        --description "Memory usage above 80% on $vmName" `
        --condition "avg Perf | where CounterName == 'Available MBytes' | summarize avg(CounterValue) < 500" `
        --action $agEmailId `
        --severity 2 `
        --evaluation-frequency 5m `
        --window-size 10m | Out-Null

    # Heartbeat missing (VM down)
    az monitor scheduled-query alert create `
        --name "VM-Down-$vmName" `
        --resource-group $rgName `
        --scopes $vmId `
        --description "VM heartbeat missing for $vmName" `
        --condition "Heartbeat | summarize Last=max(TimeGenerated) by Computer | where Last < ago(5m)" `
        --action $agOpsId `
        --severity 1 `
        --evaluation-frequency 5m `
        --window-size 10m | Out-Null
}

# -----------------------------
# 2. Storage Alerts (Capacity, Transactions, Latency)
# -----------------------------
Write-Host "`nCreating Storage Alerts..." -ForegroundColor Yellow

$storageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($sa in $storageAccounts) {

    $saId = $sa.id
    $saName = $sa.name

    Write-Host "Configuring alerts for Storage Account: $saName" -ForegroundColor Cyan

    # Capacity > 80%
    az monitor metrics alert create `
        --name "Storage-Capacity-$saName" `
        --resource-group $rgName `
        --scopes $saId `
        --condition "avg UsedCapacity > 80" `
        --description "Storage capacity above 80% on $saName" `
        --action $agEmailId `
        --severity 2 `
        --window-size 15m `
        --evaluation-frequency 5m | Out-Null

    # Transactions spike
    az monitor metrics alert create `
        --name "Storage-Transactions-$saName" `
        --resource-group $rgName `
        --scopes $saId `
        --condition "total Transactions > 5000" `
        --description "High transaction volume on $saName" `
        --action $agOpsId `
        --severity 2 `
        --window-size 15m `
        --evaluation-frequency 5m | Out-Null
}

# -----------------------------
# 3. Activity Log Alerts (Security + Governance)
# -----------------------------
Write-Host "`nCreating Activity Log Alerts..." -ForegroundColor Yellow

# Resource deletion
az monitor activity-log alert create `
    --name "Resource-Deletion-Alert" `
    --resource-group $rgName `
    --scopes "/subscriptions/$(az account show --query id -o tsv)" `
    --condition category=Administrative `
    --condition "operationName=Microsoft.Resources/subscriptions/resourceGroups/delete" `
    --action-group $agOpsId `
    --description "Alert when any resource group is deleted" | Out-Null

# Role assignment changes
az monitor activity-log alert create `
    --name "RBAC-Change-Alert" `
    --resource-group $rgName `
    --scopes "/subscriptions/$(az account show --query id -o tsv)" `
    --condition category=Administrative `
    --condition "operationName=Microsoft.Authorization/roleAssignments/write" `
    --action-group $agEmailId `
    --description "Alert when RBAC role assignments change" | Out-Null

# -----------------------------
# Summary
# -----------------------------
Write-Host "`nAlerts created successfully." -ForegroundColor Green
Write-Host "VM Alerts: CPU, Memory, Heartbeat"
Write-Host "Storage Alerts: Capacity, Transactions"
Write-Host "Activity Log Alerts: Deletion, RBAC Changes"
