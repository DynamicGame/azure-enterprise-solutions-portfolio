<#
    Project: Three-Tier Network - Project 2
    Script: deploy-bastion.ps1
    Purpose: Deploy Azure Bastion for secure VM access (no public IPs)
#>

# -----------------------------
# Variables
# -----------------------------
$location      = "uksouth"
$rgName        = "rg-three-tier-network"
$bastionName   = "bastion-host"
$bastionPip    = "bastion-pip"


# Tags
$tags = "Environment=Dev" `
      + " Project=ThreeTierNetwork" `
      + " Owner=Abdulbasit"

# -----------------------------
# 1. Create Public IP for Bastion
# -----------------------------
Write-Host "Creating Public IP for Azure Bastion..." -ForegroundColor Cyan

az network public-ip create `
  --resource-group $rgName `
  --name $bastionPip `
  --sku Standard `
  --allocation-method Static `
  --location $location `
  --tags $tags

# -----------------------------
# 2. Deploy Azure Bastion
# -----------------------------
Write-Host "Deploying Azure Bastion..." -ForegroundColor Cyan

az network bastion create `
  --resource-group $rgName `
  --name $bastionName `
  --location $location `
  --public-ip-address $bastionPip `
  --vnet-name "vnet-three-tier" `
  --sku Standard `
  --tags $tags

Write-Host "`nAzure Bastion deployment complete. Secure access to all VMs is now enabled." -ForegroundColor Green
