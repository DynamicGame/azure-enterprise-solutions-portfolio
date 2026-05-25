<#
    Project: Secure Storage Solutions
    Script: cleanup-storage.ps1
    Purpose: Remove all storage resources created in Project 3:
             - Storage Account
             - Containers
             - Immutability policies (if unlocked)
             - SAS policies
             - Lifecycle management rules
             - Resource group (optional)
#>

# -----------------------------
# Variables
# -----------------------------
$rgName     = "rg-secure-storage"
$saName     = "<YOUR-STORAGE-ACCOUNT-NAME>"

Write-Host "`nStarting cleanup of Storage Solution..." -ForegroundColor Cyan

# -----------------------------
# 1. Remove Lifecycle Management Policy
# -----------------------------
Write-Host "`nRemoving lifecycle management policy..." -ForegroundColor Yellow

az storage account management-policy delete `
    --account-name $saName `
    --resource-group $rgName 2>$null

# -----------------------------
# 2. Remove Immutability Policies (if unlocked)
# -----------------------------
Write-Host "`nRemoving immutability policies (if allowed)..." -ForegroundColor Yellow

$containers = az storage container list `
    --account-name $saName `
    --auth-mode login -o json | ConvertFrom-Json

foreach ($c in $containers) {
    Write-Host "Processing container: $($c.name)" -ForegroundColor Cyan

    # Try to delete immutability policy
    az storage container immutability-policy delete `
        --account-name $saName `
        --resource-group $rgName `
        --container-name $c.name 2>$null

    # Remove legal hold
    az storage container legal-hold delete `
        --account-name $saName `
        --resource-group $rgName `
        --container-name $c.name `
        --tags "Compliance" "DoNotDelete" 2>$null
}

# -----------------------------
# 3. Delete Containers
# -----------------------------
Write-Host "`nDeleting containers..." -ForegroundColor Yellow

foreach ($c in $containers) {
    Write-Host "Deleting container: $($c.name)" -ForegroundColor Cyan
    az storage container delete `
        --name $c.name `
        --account-name $saName `
        --auth-mode login 2>$null
}

# -----------------------------
# 4. Delete Storage Account
# -----------------------------
Write-Host "`nDeleting storage account..." -ForegroundColor Yellow

az storage account delete `
    --name $saName `
    --resource-group $rgName `
    --yes 2>$null

# -----------------------------
# 5. Optional: Delete Resource Group
# -----------------------------
Write-Host "`nDelete resource group $rgName? (y/n)" -ForegroundColor Cyan
$choice = Read-Host

if ($choice -eq "y") {
    az group delete --name $rgName --yes --no-wait
    Write-Host "Resource group deletion started." -ForegroundColor Red
} else {
    Write-Host "Skipping resource group deletion." -ForegroundColor Green
}

Write-Host "`nStorage cleanup complete." -ForegroundColor Green
