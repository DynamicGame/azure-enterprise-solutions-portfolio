<#
    Project: Three-Tier Network - Project 2
    Script: deploy-private-endpoints.ps1
    Purpose: Deploy Storage + Key Vault Private Endpoints + Private DNS Zones
#>

# -----------------------------
# Variables
# -----------------------------
$location      = "uksouth"
$rgName        = "rg-three-tier-network"
$vnetName      = "vnet-three-tier"
$peSubnetName  = "private-endpoints"

# Storage
$storageName = "storagethreetier$(Get-Random)"

# Key Vault
$kvName = "kvthreetier$(Get-Random)"

# DNS Zones
$dnsBlobZone = "privatelink.blob.core.windows.net"
$dnsKvZone   = "privatelink.vaultcore.azure.net"

# Tags
$tags = "Environment=Dev" `
      + " Project=ThreeTierNetwork" `
      + " Owner=Abdulbasit"

# -----------------------------
# 1. Create Storage Account
# -----------------------------
Write-Host "Creating Storage Account..." -ForegroundColor Cyan

az storage account create `
  --name $storageName `
  --resource-group $rgName `
  --location $location `
  --sku Standard_LRS `
  --kind StorageV2 `
  --allow-blob-public-access false `
  --min-tls-version TLS1_2 `
  --tags $tags

# -----------------------------
# 2. Create Private DNS Zone for Blob
# -----------------------------
Write-Host "Creating Private DNS Zone for Blob..." -ForegroundColor Cyan

az network private-dns zone create `
  --resource-group $rgName `
  --name $dnsBlobZone

# Link DNS zone to VNet
az network private-dns link vnet create `
  --resource-group $rgName `
  --zone-name $dnsBlobZone `
  --name "dnslink-blob" `
  --virtual-network $vnetName `
  --registration-enabled false

# -----------------------------
# 3. Create Private Endpoint for Storage (Blob)
# -----------------------------
Write-Host "Creating Private Endpoint for Storage Blob..." -ForegroundColor Cyan

az network private-endpoint create `
  --resource-group $rgName `
  --name "pe-storage-blob" `
  --vnet-name $vnetName `
  --subnet $peSubnetName `
  --private-connection-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$rgName/providers/Microsoft.Storage/storageAccounts/$storageName" `
  --group-id blob `
  --connection-name "storage-blob-pe" `
  --location $location `
  --tags $tags

# DNS zone group
az network private-endpoint dns-zone-group create `
  --resource-group $rgName `
  --endpoint-name "pe-storage-blob" `
  --name "blob-dnszonegroup" `
  --private-dns-zone $dnsBlobZone `
  --zone-name $dnsBlobZone

# -----------------------------
# 4. Create Key Vault
# -----------------------------
Write-Host "Creating Key Vault..." -ForegroundColor Cyan

az keyvault create `
  --name $kvName `
  --resource-group $rgName `
  --location $location `
  --sku standard `
  --enable-rbac-authorization true `
  --public-network-access Disabled `
  --tags $tags

# -----------------------------
# 5. Create Private DNS Zone for Key Vault
# -----------------------------
Write-Host "Creating Private DNS Zone for Key Vault..." -ForegroundColor Cyan

az network private-dns zone create `
  --resource-group $rgName `
  --name $dnsKvZone

# Link DNS zone to VNet
az network private-dns link vnet create `
  --resource-group $rgName `
  --zone-name $dnsKvZone `
  --name "dnslink-kv" `
  --virtual-network $vnetName `
  --registration-enabled false

# -----------------------------
# 6. Create Private Endpoint for Key Vault
# -----------------------------
Write-Host "Creating Private Endpoint for Key Vault..." -ForegroundColor Cyan

az network private-endpoint create `
  --resource-group $rgName `
  --name "pe-keyvault" `
  --vnet-name $vnetName `
  --subnet $peSubnetName `
  --private-connection-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$rgName/providers/Microsoft.KeyVault/vaults/$kvName" `
  --group-id vault `
  --connection-name "kv-pe-connection" `
  --location $location `
  --tags $tags

# DNS zone group
az network private-endpoint dns-zone-group create `
  --resource-group $rgName `
  --endpoint-name "pe-keyvault" `
  --name "kv-dnszonegroup" `
  --private-dns-zone $dnsKvZone `
  --zone-name $dnsKvZone

Write-Host "`nPrivate Endpoints for Storage + Key Vault deployed successfully." -ForegroundColor Green
Write-Host "Both services are now accessible ONLY via private IPs inside the VNet." -ForegroundColor Green
