<#
    Script: cleanup.ps1
    Purpose: Safely delete all resources created for the HA Web Server project
    Author: DynamicGame (Abdulbasit)
#>

# -----------------------------
# Variables
# -----------------------------
$rgName = "rg-ha-web"

Write-Host "WARNING: This will delete the entire resource group '$rgName' and all resources inside it." -ForegroundColor Yellow
Write-Host "This includes VMs, NICs, Disks, NSGs, VNet, Public IPs, and the Availability Set." -ForegroundColor Yellow

# Confirm deletion
$confirmation = Read-Host "Type 'YES' to continue"

if ($confirmation -ne "YES") {
    Write-Host "Cleanup cancelled." -ForegroundColor Red
    exit
}

# -----------------------------
# Delete Resource Group
# -----------------------------
Write-Host "Deleting resource group $rgName..." -ForegroundColor Cyan

az group delete `
    --name $rgName `
    --yes `
    --no-wait

Write-Host "`nCleanup initiated. Resources are being deleted in the background." -ForegroundColor Green
Write-Host "You can check progress with: az group show -n $rgName" -ForegroundColor DarkGray
