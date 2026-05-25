<#
    Project: Monitoring & Alerting Solutions
    Script: deploy-law.ps1
    Purpose: Deploy a Log Analytics Workspace and prepare it for
             Azure Monitor + VM Insights + Storage diagnostics.
#>

# -----------------------------
# Variables
# -----------------------------
$rgName        = "rg-monitoring"
$location      = "uksouth"
$workspaceName = "law-monitoring-$(Get-Random -Maximum 9999)"

Write-Host "`nDeploying Log Analytics Workspace..." -ForegroundColor Cyan

# -----------------------------
# 1. Create Resource Group
# -----------------------------
$rgExists = az group show `
    --name $rgName `
    --query "name" -o tsv 2>$null

if (-not $rgExists) {
    Write-Host "Creating resource group: $rgName" -ForegroundColor Yellow
    az group create `
        --name $rgName `
        --location $location | Out-Null
} else {
    Write-Host "Resource group already exists: $rgName" -ForegroundColor Green
}

# -----------------------------
# 2. Create Log Analytics Workspace
# -----------------------------
Write-Host "`nCreating Log Analytics Workspace: $workspaceName" -ForegroundColor Yellow

az monitor log-analytics workspace create `
    --resource-group $rgName `
    --workspace-name $workspaceName `
    --location $location `
    --sku PerGB2018 `
    --retention-time 30 | Out-Null

Write-Host "Log Analytics Workspace created." -ForegroundColor Green

# -----------------------------
# 3. Get Workspace Details
# -----------------------------
$workspace = az monitor log-analytics workspace show `
    --resource-group $rgName `
    --workspace-name $workspaceName `
    -o json | ConvertFrom-Json

$workspaceId   = $workspace.customerId
$workspaceName = $workspace.name
$workspaceResId = $workspace.id

Write-Host "`nWorkspace ID: $workspaceId" -ForegroundColor Yellow
Write-Host "Workspace Name: $workspaceName"
Write-Host "Workspace Resource ID: $workspaceResId"

# -----------------------------
# 4. Enable VM Insights (via solution)
# -----------------------------
Write-Host "`nEnabling VM Insights solution..." -ForegroundColor Cyan

az monitor log-analytics solution create `
    --resource-group $rgName `
    --workspace $workspaceName `
    --solution-type "VMInsights" | Out-Null

Write-Host "VM Insights solution enabled." -ForegroundColor Green

# -----------------------------
# 5. Summary
# -----------------------------
Write-Host "`nDeployment complete." -ForegroundColor Cyan
Write-Host "Resource Group: $rgName"
Write-Host "Workspace:      $workspaceName"
Write-Host "Location:       $location"
Write-Host "`nUse this Workspace ID/Resource ID in:" -ForegroundColor Yellow
Write-Host " - connect-resources.ps1"
Write-Host " - create-alerts.ps1"
Write-Host " - create-dashboard.ps1"
