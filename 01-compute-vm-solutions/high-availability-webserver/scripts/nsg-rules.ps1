<#
    Script: nsg-rules.ps1
    Purpose: Create or update NSG rules for the HA Web Server project
    Author: DynamicGame (Abdulbasit)
#>

# -----------------------------
# Variables
# -----------------------------
$rgName    = "rg-ha-web"
$nsgName   = "nsg-web"

Write-Host "Applying NSG rules to $nsgName..." -ForegroundColor Cyan

# -----------------------------
# 1. Allow HTTP (Port 80)
# -----------------------------
az network nsg rule create `
    --resource-group $rgName `
    --nsg-name $nsgName `
    --name Allow-HTTP `
    --priority 100 `
    --protocol Tcp `
    --direction Inbound `
    --source-address-prefixes Internet `
    --destination-port-ranges 80 `
    --access Allow `
    --description "Allow inbound HTTP traffic"

# -----------------------------
# 2. Allow HTTPS (Port 443)
# -----------------------------
az network nsg rule create `
    --resource-group $rgName `
    --nsg-name $nsgName `
    --name Allow-HTTPS `
    --priority 110 `
    --protocol Tcp `
    --direction Inbound `
    --source-address-prefixes Internet `
    --destination-port-ranges 443 `
    --access Allow `
    --description "Allow inbound HTTPS traffic"

# -----------------------------
# 3. Allow RDP (Port 3389) — Restricted
# -----------------------------
# Replace YOUR_PUBLIC_IP with your actual IP for security
$myIP = "YOUR_PUBLIC_IP/32"

az network nsg rule create `
    --resource-group $rgName `
    --nsg-name $nsgName `
    --name Allow-RDP `
    --priority 200 `
    --protocol Tcp `
    --direction Inbound `
    --source-address-prefixes $myIP `
    --destination-port-ranges 3389 `
    --access Allow `
    --description "Allow RDP only from admin IP"

# -----------------------------
# 4. Deny All Other Inbound Traffic (Optional)
# -----------------------------
az network nsg rule create `
    --resource-group $rgName `
    --nsg-name $nsgName `
    --name Deny-All `
    --priority 4096 `
    --protocol "*" `
    --direction Inbound `
    --source-address-prefixes "*" `
    --destination-port-ranges "*" `
    --access Deny `
    --description "Deny all other inbound traffic"

Write-Host "`nNSG rules applied successfully!" -ForegroundColor Green
