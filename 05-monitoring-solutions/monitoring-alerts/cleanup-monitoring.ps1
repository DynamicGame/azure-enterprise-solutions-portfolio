<#
    Project: Monitoring & Alerting Solutions
    Script: cleanup-monitoring.ps1
    Purpose: Remove all monitoring resources created in Project 5:
             - Log Analytics Workspace
             - Diagnostic settings
             - Alerts
             - Action Groups
             - Dashboard
             - VM Insights extensions
             - Optional: Resource Group
#>

# -----------------------------
# Variables
# -----------------------------
$rgName     = "rg-monitoring"
$workspaceName = "<YOUR-LAW-NAME>"     # e.g. law-monitoring-1234
$dashName   = "dash-monitoring-overview"

Write-Host "`nStarting cleanup of Monitoring & Alerting resources..." -ForegroundColor Cyan

# -----------------------------
# 1. Remove Alerts
# -----------------------------
Write-Host "`nRemoving alert rules..." -ForegroundColor Yellow

$alerts = az monitor alert list --resource-group $rgName -o json | ConvertFrom-Json

foreach ($alert in $alerts) {
    Write-Host "Deleting alert: $($alert.name)" -ForegroundColor Cyan
    az monitor alert delete `
        --name $alert.name `
        --resource-group $rgName | Out-Null
}

# -----------------------------
# 2. Remove Action Groups
# -----------------------------
Write-Host "`nRemoving Action Groups..." -ForegroundColor Yellow

$actionGroups = az monitor action-group list --resource-group $rgName -o json | ConvertFrom-Json

foreach ($ag in $actionGroups) {
    Write-Host "Deleting Action Group: $($ag.name)" -ForegroundColor Cyan
    az monitor action-group delete `
        --name $ag.name `
        --resource-group $rgName | Out-Null
}

# -----------------------------
# 3. Remove Diagnostic Settings from Storage Accounts
# -----------------------------
Write-Host "`nRemoving diagnostic settings from Storage Accounts..." -ForegroundColor Yellow

$storageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($sa in $storageAccounts) {
    $diag = az monitor diagnostic-settings list --resource $sa.id -o json | ConvertFrom-Json

    foreach ($d in $diag) {
        Write-Host "Deleting diagnostic setting: $($d.name) on $($sa.name)" -ForegroundColor Cyan
        az monitor diagnostic-settings delete `
            --name $d.name `
            --resource $sa.id | Out-Null
    }
}

# -----------------------------
# 4. Remove VM Insights Extensions
# -----------------------------
Write-Host "`nRemoving VM Insights extensions..." -ForegroundColor Yellow

$vms = az vm list -d -o json | ConvertFrom-Json

foreach ($vm in $vms) {
    Write-Host "Removing VM Insights from VM: $($vm.name)" -ForegroundColor Cyan

    az vm extension delete `
        --resource-group $vm.resourceGroup `
        --vm-name $vm.name `
        --name "AzureMonitorWindowsAgent" 2>$null

    az vm extension delete `
        --resource-group $vm.resourceGroup `
        --vm-name $vm.name `
        --name "AzureMonitorLinuxAgent" 2>$null
}

# -----------------------------
# 5. Delete Dashboard
# -----------------------------
Write-Host "`nDeleting dashboard..." -ForegroundColor Yellow

az portal dashboard delete `
    --name $dashName `
    --resource-group $rgName 2>$null

# -----------------------------
# 6. Delete Log Analytics Workspace
# -----------------------------
Write-Host "`nDeleting Log Analytics Workspace..." -ForegroundColor Yellow

az monitor log-analytics workspace delete `
    --resource-group $rgName `
    --workspace-name $workspaceName `
    --yes | Out-Null

# -----------------------------
# 7. Optional: Delete Resource Group
# -----------------------------
Write-Host "`nDo you want to delete the entire resource group ($rgName)? (y/n)" -ForegroundColor Cyan
$choice = Read-Host

if ($choice -eq "y") {
    Write-Host "Deleting resource group..." -ForegroundColor Red
    az group delete --name $rgName --yes --no-wait
} else {
    Write-Host "Skipping resource group deletion." -ForegroundColor Green
}

# -----------------------------
# Summary
# -----------------------------
Write-Host "`nCleanup complete." -ForegroundColor Green
Write-Host "All monitoring resources have been removed."
