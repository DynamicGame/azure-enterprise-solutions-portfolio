<#
    Project: Monitoring & Alerting Solutions
    Script: connect-resources.ps1
    Purpose: Connect Virtual Machines and Storage Accounts to the
             Log Analytics Workspace for monitoring + diagnostics.
#>

# -----------------------------
# Variables
# -----------------------------
$rgName        = "rg-monitoring"
$workspaceName = "<YOUR-LAW-NAME>"          # e.g. law-monitoring-1234
$workspaceRg   = $rgName
$location      = "uksouth"

Write-Host "`nConnecting resources to Log Analytics Workspace..." -ForegroundColor Cyan

# -----------------------------
# 1. Get Workspace Resource ID
# -----------------------------
$workspace = az monitor log-analytics workspace show `
    --resource-group $workspaceRg `
    --workspace-name $workspaceName `
    -o json | ConvertFrom-Json

if (-not $workspace) {
    Write-Host "ERROR: Log Analytics Workspace not found." -ForegroundColor Red
    exit
}

$workspaceId = $workspace.customerId
$workspaceResId = $workspace.id

Write-Host "Workspace found: $workspaceName" -ForegroundColor Green
Write-Host "Workspace Resource ID: $workspaceResId"

# -----------------------------
# 2. Connect ALL Virtual Machines
# -----------------------------
Write-Host "`nConnecting Virtual Machines to VM Insights..." -ForegroundColor Yellow

$vms = az vm list -d -o json | ConvertFrom-Json

if ($vms.Count -eq 0) {
    Write-Host "No VMs found in subscription." -ForegroundColor Yellow
} else {
    foreach ($vm in $vms) {
        Write-Host "Enabling monitoring for VM: $($vm.name)" -ForegroundColor Cyan

        az monitor vm insights enable `
            --resource-group $vm.resourceGroup `
            --vm-name $vm.name `
            --workspace $workspaceResId | Out-Null

        Write-Host "Connected: $($vm.name)" -ForegroundColor Green
    }
}

# -----------------------------
# 3. Connect ALL Storage Accounts
# -----------------------------
Write-Host "`nConfiguring diagnostic settings for Storage Accounts..." -ForegroundColor Yellow

$storageAccounts = az storage account list -o json | ConvertFrom-Json

if ($storageAccounts.Count -eq 0) {
    Write-Host "No Storage Accounts found in subscription." -ForegroundColor Yellow
} else {
    foreach ($sa in $storageAccounts) {

        Write-Host "Configuring diagnostics for Storage Account: $($sa.name)" -ForegroundColor Cyan

        az monitor diagnostic-settings create `
            --name "diag-$($sa.name)" `
            --resource $sa.id `
            --workspace $workspaceResId `
            --logs '[{"category":"StorageRead","enabled":true},{"category":"StorageWrite","enabled":true},{"category":"StorageDelete","enabled":true}]' `
            --metrics '[{"category":"Transaction","enabled":true},{"category":"Capacity","enabled":true}]' | Out-Null

        Write-Host "Diagnostics enabled: $($sa.name)" -ForegroundColor Green
    }
}

# -----------------------------
# Summary
# -----------------------------
Write-Host "`nResource onboarding complete." -ForegroundColor Cyan
Write-Host "Workspace: $workspaceName"
Write-Host "VMs connected: $($vms.Count)"
Write-Host "Storage Accounts connected: $($storageAccounts.Count)"
