<#
    Project: Three-Tier Network - Project 2
    Script: deploy-db.ps1
    Purpose: Deploy Azure SQL Database + Private Endpoint + Private DNS Zone
#>

# -----------------------------
# Variables
# -----------------------------
$location      = "uksouth"
$rgName        = "rg-three-tier-network"
$vnetName      = "vnet-three-tier"
$peSubnetName  = "private-endpoints"

# SQL
$sqlServerName = "sqlserverthree$(Get-Random)"
$sqlDbName     = "appdb"
$sqlAdminUser  = "sqladminuser"
$sqlAdminPass  = "P@ssword12345!"   # You can change this

# Private DNS Zone
$dnsZoneName = "privatelink.database.windows.net"

# Tags
$tags = "Environment=Dev" `
      + " Project=ThreeTierNetwork" `
      + " Owner=Abdulbasit"

# -----------------------------
# 1. Create Azure SQL Server
# -----------------------------
Write-Host "Creating Azure SQL Server..." -ForegroundColor Cyan

az sql server create `
  --name $sqlServerName `
  --resource-group $rgName `
  --location $location `
  --admin-user $sqlAdminUser `
  --admin-password $sqlAdminPass `
  --tags $tags

# Disable public network access (private endpoint only)
az sql server update `
  --name $sqlServerName `
  --resource-group $rgName `
  --set publicNetworkAccess="Disabled"

# -----------------------------
# 2. Create Azure SQL Database
# -----------------------------
Write-Host "Creating Azure SQL Database..." -ForegroundColor Cyan

az sql db create `
  --resource-group $rgName `
  --server $sqlServerName `
  --name $sqlDbName `
  --service-objective S0 `
  --tags $tags

# -----------------------------
# 3. Create Private DNS Zone
# -----------------------------
Write-Host "Creating Private DNS Zone..." -ForegroundColor Cyan

az network private-dns zone create `
  --resource-group $rgName `
  --name $dnsZoneName

# Link DNS zone to VNet
az network private-dns link vnet create `
  --resource-group $rgName `
  --zone-name $dnsZoneName `
  --name "dnslink-three-tier" `
  --virtual-network $vnetName `
  --registration-enabled false

# -----------------------------
# 4. Create Private Endpoint for Azure SQL
# -----------------------------
Write-Host "Creating Private Endpoint for Azure SQL..." -ForegroundColor Cyan

az network private-endpoint create `
  --resource-group $rgName `
  --name "pe-sql" `
  --vnet-name $vnetName `
  --subnet $peSubnetName `
  --private-connection-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$rgName/providers/Microsoft.Sql/servers/$sqlServerName" `
  --group-id sqlServer `
  --connection-name "sql-pe-connection" `
  --location $location `
  --tags $tags

# -----------------------------
# 5. Create DNS Zone Group for Private Endpoint
# -----------------------------
Write-Host "Creating DNS Zone Group..." -ForegroundColor Cyan

az network private-endpoint dns-zone-group create `
  --resource-group $rgName `
  --endpoint-name "pe-sql" `
  --name "sql-dnszonegroup" `
  --private-dns-zone $dnsZoneName `
  --zone-name $dnsZoneName

Write-Host "`nAzure SQL + Private Endpoint deployment complete." -ForegroundColor Green
Write-Host "Database is now reachable ONLY from App Tier via private IP." -ForegroundColor Green
