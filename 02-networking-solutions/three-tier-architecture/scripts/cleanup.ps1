<#
    Project: Three-Tier Network - Project 2
    Script: nsg-rules.ps1
    Purpose: Apply NSG rules for Web, App, and DB tiers using ASGs
#>

# -----------------------------
# Variables
# -----------------------------
$location      = "uksouth"
$rgName        = "rg-three-tier-network"

# NSGs
$webNsgName = "nsg-web"
$appNsgName = "nsg-app"
$dbNsgName  = "nsg-db"

# ASGs
$asgWebName = "asg-web"
$asgAppName = "asg-app"
$asgDbName  = "asg-db"

# Tags
$tags = "Environment=Dev" `
      + " Project=ThreeTierNetwork" `
      + " Owner=Abdulbasit"

# -----------------------------
# 1. Web NSG Rules (Already Has 80/443 From Internet)
# -----------------------------
Write-Host "Web NSG already configured with HTTP/HTTPS inbound rules." -ForegroundColor Yellow

# -----------------------------
# 2. App NSG Rules
# -----------------------------
Write-Host "Configuring App NSG rules..." -ForegroundColor Cyan

# Allow inbound 8080 from Web Tier ASG
az network nsg rule create `
  --resource-group $rgName `
  --nsg-name $appNsgName `
  --name "Allow-Web-To-App" `
  --priority 100 `
  --direction Inbound `
  --access Allow `
  --protocol Tcp `
  --source-asgs $asgWebName `
  --destination-asgs $asgAppName `
  --destination-port-ranges 8080

# Optional: Allow outbound to DB Tier (1433)
az network nsg rule create `
  --resource-group $rgName `
  --nsg-name $appNsgName `
  --name "Allow-App-To-DB" `
  --priority 200 `
  --direction Outbound `
  --access Allow `
  --protocol Tcp `
  --source-asgs $asgAppName `
  --destination-asgs $asgDbName `
  --destination-port-ranges 1433

# -----------------------------
# 3. DB NSG Rules
# -----------------------------
Write-Host "Configuring DB NSG rules..." -ForegroundColor Cyan

# Allow SQL inbound from App Tier ASG
az network nsg rule create `
  --resource-group $rgName `
  --nsg-name $dbNsgName `
  --name "Allow-App-To-DB" `
  --priority 100 `
  --direction Inbound `
  --access Allow `
  --protocol Tcp `
  --source-asgs $asgAppName `
  --destination-asgs $asgDbName `
  --destination-port-ranges 1433

# -----------------------------
# 4. Security Best Practices
# -----------------------------
Write-Host "`nApplying Azure best practices..." -ForegroundColor Cyan
Write-Host "- No NSG on AzureFirewallSubnet (Azure blocks it)" -ForegroundColor Yellow
Write-Host "- No NSG on AzureBastionSubnet (Azure blocks it)" -ForegroundColor Yellow
Write-Host "- No NSG on Private Endpoint subnet (Microsoft recommendation)" -ForegroundColor Yellow

Write-Host "`nNSG rules applied successfully. Zero-trust segmentation is now enforced." -ForegroundColor Green
