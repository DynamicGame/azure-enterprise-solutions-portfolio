<#
    Project: Three-Tier Network - Project 2
    Script: deploy-network.ps1
    Purpose: Create core networking (VNet, subnets, NSGs, ASGs, route tables) in UK South
#>

# -----------------------------
# Variables
# -----------------------------
$location      = "uksouth"
$rgName        = "rg-three-tier-network"
$vnetName      = "vnet-three-tier"
$vnetAddress   = "10.0.0.0/16"

# Subnets
$webSubnetName        = "web-subnet"
$webSubnetPrefix      = "10.0.1.0/24"

$appSubnetName        = "app-subnet"
$appSubnetPrefix      = "10.0.2.0/24"

$dbSubnetName         = "db-subnet"
$dbSubnetPrefix       = "10.0.3.0/24"

$bastionSubnetName    = "AzureBastionSubnet"
$bastionSubnetPrefix  = "10.0.10.0/27"

$fwSubnetName         = "AzureFirewallSubnet"
$fwSubnetPrefix       = "10.0.20.0/26"

$peSubnetName         = "private-endpoints"
$peSubnetPrefix       = "10.0.30.0/24"

# NSGs
$webNsgName = "nsg-web"
$appNsgName = "nsg-app"
$dbNsgName  = "nsg-db"

# ASGs
$asgWebName = "asg-web"
$asgAppName = "asg-app"
$asgDbName  = "asg-db"

# Route tables
$rtWebName = "rt-web"
$rtAppName = "rt-app"
$rtDbName  = "rt-db"

# Tags
$tags = "Environment=Dev" `
      + " Project=ThreeTierNetwork" `
      + " Owner=Abdulbasit"

# -----------------------------
# 1. Resource Group
# -----------------------------
Write-Host "Creating resource group..." -ForegroundColor Cyan

az group create `
  --name $rgName `
  --location $location `
  --tags $tags

# -----------------------------
# 2. VNet + Base Subnet
# -----------------------------
Write-Host "Creating virtual network and subnets..." -ForegroundColor Cyan

az network vnet create `
  --resource-group $rgName `
  --name $vnetName `
  --address-prefixes $vnetAddress `
  --subnet-name $webSubnetName `
  --subnet-prefixes $webSubnetPrefix

# Additional subnets
az network vnet subnet create `
  --resource-group $rgName `
  --vnet-name $vnetName `
  --name $appSubnetName `
  --address-prefixes $appSubnetPrefix

az network vnet subnet create `
  --resource-group $rgName `
  --vnet-name $vnetName `
  --name $dbSubnetName `
  --address-prefixes $dbSubnetPrefix

az network vnet subnet create `
  --resource-group $rgName `
  --vnet-name $vnetName `
  --name $bastionSubnetName `
  --address-prefixes $bastionSubnetPrefix

az network vnet subnet create `
  --resource-group $rgName `
  --vnet-name $vnetName `
  --name $fwSubnetName `
  --address-prefixes $fwSubnetPrefix

az network vnet subnet create `
  --resource-group $rgName `
  --vnet-name $vnetName `
  --name $peSubnetName `
  --address-prefixes $peSubnetPrefix

# -----------------------------
# 3. Application Security Groups
# -----------------------------
Write-Host "Creating ASGs..." -ForegroundColor Cyan

az network asg create `
  --resource-group $rgName `
  --name $asgWebName `
  --location $location `
  --tags $tags

az network asg create `
  --resource-group $rgName `
  --name $asgAppName `
  --location $location `
  --tags $tags

az network asg create `
  --resource-group $rgName `
  --name $asgDbName `
  --location $location `
  --tags $tags

# -----------------------------
# 4. Network Security Groups
# -----------------------------
Write-Host "Creating NSGs..." -ForegroundColor Cyan

# Web NSG
az network nsg create `
  --resource-group $rgName `
  --name $webNsgName `
  --location $location `
  --tags $tags

# Allow HTTP/HTTPS from Internet to web subnet
az network nsg rule create `
  --resource-group $rgName `
  --nsg-name $webNsgName `
  --name "Allow-HTTP" `
  --priority 100 `
  --direction Inbound `
  --access Allow `
  --protocol Tcp `
  --source-address-prefixes Internet `
  --source-port-ranges "*" `
  --destination-address-prefixes "*" `
  --destination-port-ranges 80

az network nsg rule create `
  --resource-group $rgName `
  --nsg-name $webNsgName `
  --name "Allow-HTTPS" `
  --priority 110 `
  --direction Inbound `
  --access Allow `
  --protocol Tcp `
  --source-address-prefixes Internet `
  --source-port-ranges "*" `
  --destination-address-prefixes "*" `
  --destination-port-ranges 443

# App NSG (locked down; detailed rules added later)
az network nsg create `
  --resource-group $rgName `
  --name $appNsgName `
  --location $location `
  --tags $tags

# DB NSG (locked down; detailed rules added later)
az network nsg create `
  --resource-group $rgName `
  --name $dbNsgName `
  --location $location `
  --tags $tags

# -----------------------------
# 5. Associate NSGs with Subnets
# -----------------------------
Write-Host "Associating NSGs with subnets..." -ForegroundColor Cyan

az network vnet subnet update `
  --resource-group $rgName `
  --vnet-name $vnetName `
  --name $webSubnetName `
  --network-security-group $webNsgName

az network vnet subnet update `
  --resource-group $rgName `
  --vnet-name $vnetName `
  --name $appSubnetName `
  --network-security-group $appNsgName

az network vnet subnet update `
  --resource-group $rgName `
  --vnet-name $vnetName `
  --name $dbSubnetName `
  --network-security-group $dbNsgName

# -----------------------------
# 6. Route Tables (empty for now)
# -----------------------------
Write-Host "Creating route tables (to be used with Azure Firewall)..." -ForegroundColor Cyan

az network route-table create `
  --resource-group $rgName `
  --name $rtWebName `
  --location $location `
  --tags $tags

az network route-table create `
  --resource-group $rgName `
  --name $rtAppName `
  --location $location `
  --tags $tags

az network route-table create `
  --resource-group $rgName `
  --name $rtDbName `
  --location $location `
  --tags $tags

Write-Host "`nCore network deployment complete. Next: firewall, routes, and workloads." -ForegroundColor Green
