<#
    Project: Three-Tier Network - Project 2
    Script: route-tables.ps1
    Purpose: Add UDRs to force traffic through Azure Firewall and associate route tables
#>

# -----------------------------
# Variables
# -----------------------------
$rgName        = "rg-three-tier-network"
$vnetName      = "vnet-three-tier"

# Subnets
$webSubnetName = "web-subnet"
$appSubnetName = "app-subnet"
$dbSubnetName  = "db-subnet"

# Route tables
$rtWebName = "rt-web"
$rtAppName = "rt-app"
$rtDbName  = "rt-db"

# Firewall
$fwName = "fw-core"

# -----------------------------
# 1. Get Firewall Private IP
# -----------------------------
Write-Host "Retrieving Azure Firewall private IP..." -ForegroundColor Cyan

$fwPrivateIp = az network firewall ip-config list `
  --firewall-name $fwName `
  --resource-group $rgName `
  --query "[0].privateIpAddress" `
  -o tsv

Write-Host "Firewall private IP: $fwPrivateIp" -ForegroundColor Yellow

# -----------------------------
# 2. Add UDRs to Route Tables
# -----------------------------
Write-Host "Adding UDRs to route tables..." -ForegroundColor Cyan

# Web → Firewall
az network route-table route create `
  --resource-group $rgName `
  --route-table-name $rtWebName `
  --name "DefaultToFirewall" `
  --address-prefix "0.0.0.0/0" `
  --next-hop-type VirtualAppliance `
  --next-hop-ip-address $fwPrivateIp

# App → Firewall
az network route-table route create `
  --resource-group $rgName `
  --route-table-name $rtAppName `
  --name "DefaultToFirewall" `
  --address-prefix "0.0.0.0/0" `
  --next-hop-type VirtualAppliance `
  --next-hop-ip-address $fwPrivateIp

# DB → Firewall
az network route-table route create `
  --resource-group $rgName `
  --route-table-name $rtDbName `
  --name "DefaultToFirewall" `
  --address-prefix "0.0.0.0/0" `
  --next-hop-type VirtualAppliance `
  --next-hop-ip-address $fwPrivateIp

# -----------------------------
# 3. Associate Route Tables with Subnets
# -----------------------------
Write-Host "Associating route tables with subnets..." -ForegroundColor Cyan

# Web subnet
az network vnet subnet update `
  --resource-group $rgName `
  --vnet-name $vnetName `
  --name $webSubnetName `
  --route-table $rtWebName

# App subnet
az network vnet subnet update `
  --resource-group $rgName `
  --vnet-name $vnetName `
  --name $appSubnetName `
  --route-table $rtAppName

# DB subnet
az network vnet subnet update `
  --resource-group $rgName `
  --vnet-name $vnetName `
  --name $dbSubnetName `
  --route-table $rtDbName

Write-Host "`nRoute table configuration complete. Traffic is now forced through Azure Firewall." -ForegroundColor Green
