<#
    Project: Three-Tier Network - Project 2
    Script: deploy-firewall.ps1
    Purpose: Deploy Azure Firewall + Firewall Policy + Rules in UK South
#>

# -----------------------------
# Variables
# -----------------------------
$location      = "uksouth"
$rgName        = "rg-three-tier-network"

$fwName        = "fw-core"
$fwPipName     = "fw-core-pip"
$fwPolicyName  = "fw-core-policy"



# Tags
$tags = "Environment=Dev" `
      + " Project=ThreeTierNetwork" `
      + " Owner=Abdulbasit"

# -----------------------------
# 1. Create Public IP for Firewall
# -----------------------------
Write-Host "Creating Azure Firewall Public IP..." -ForegroundColor Cyan

az network public-ip create `
  --resource-group $rgName `
  --name $fwPipName `
  --sku Standard `
  --allocation-method Static `
  --location $location `
  --tags $tags

# -----------------------------
# 2. Create Firewall Policy
# -----------------------------
Write-Host "Creating Azure Firewall Policy..." -ForegroundColor Cyan

az network firewall policy create `
  --resource-group $rgName `
  --name $fwPolicyName `
  --location $location `
  --sku Premium `
  --tags $tags

# -----------------------------
# 3. Add Firewall Rules
# -----------------------------
Write-Host "Adding Firewall Rules..." -ForegroundColor Cyan

# Allow DNS (Azure DNS)
az network firewall policy rule-collection-group create `
  --resource-group $rgName `
  --policy-name $fwPolicyName `
  --name "rcg-dns" `
  --priority 100

az network firewall policy rule-collection-group collection add-filter-rule `
  --resource-group $rgName `
  --policy-name $fwPolicyName `
  --rule-collection-group-name "rcg-dns" `
  --name "Allow-DNS" `
  --rule-type NetworkRule `
  --action Allow `
  --ip-protocols UDP `
  --source-addresses "*" `
  --destination-addresses "168.63.129.16" `
  --destination-ports 53 `
  --priority 100

# Allow Windows Update
az network firewall policy rule-collection-group create `
  --resource-group $rgName `
  --policy-name $fwPolicyName `
  --name "rcg-windows-update" `
  --priority 200

az network firewall policy rule-collection-group collection add-application-rule `
  --resource-group $rgName `
  --policy-name $fwPolicyName `
  --rule-collection-group-name "rcg-windows-update" `
  --name "Allow-WindowsUpdate" `
  --action Allow `
  --source-addresses "*" `
  --protocols Http=80 Https=443 `
  --target-fqdns `
    "windowsupdate.microsoft.com" `
    "*.windowsupdate.microsoft.com" `
    "*.update.microsoft.com" `
    "*.windows.com" `
    "*.msftconnecttest.com" `
  --priority 200

# Allow GitHub (for app deployments)
az network firewall policy rule-collection-group create `
  --resource-group $rgName `
  --policy-name $fwPolicyName `
  --name "rcg-github" `
  --priority 300

az network firewall policy rule-collection-group collection add-application-rule `
  --resource-group $rgName `
  --policy-name $fwPolicyName `
  --rule-collection-group-name "rcg-github" `
  --name "Allow-GitHub" `
  --action Allow `
  --source-addresses "*" `
  --protocols Https=443 `
  --target-fqdns "*.github.com" `
  --priority 300

# Allow outbound web browsing (optional)
az network firewall policy rule-collection-group create `
  --resource-group $rgName `
  --policy-name $fwPolicyName `
  --name "rcg-web" `
  --priority 400

az network firewall policy rule-collection-group collection add-application-rule `
  --resource-group $rgName `
  --policy-name $fwPolicyName `
  --rule-collection-group-name "rcg-web" `
  --name "Allow-Web" `
  --action Allow `
  --source-addresses "*" `
  --protocols Http=80 Https=443 `
  --target-fqdns "*" `
  --priority 400

# -----------------------------
# 4. Deploy Azure Firewall
# -----------------------------
Write-Host "Deploying Azure Firewall..." -ForegroundColor Cyan

az network firewall create `
  --resource-group $rgName `
  --name $fwName `
  --location $location `
  --sku AZFW_VNet `
  --tier Premium `
  --tags $tags

# Attach public IP
az network firewall ip-config create `
  --firewall-name $fwName `
  --resource-group $rgName `
  --name "fw-ipconfig" `
  --public-ip-address $fwPipName `
  --vnet-name "vnet-three-tier"

# Attach firewall policy
az network firewall update `
  --name $fwName `
  --resource-group $rgName `
  --firewall-policy $fwPolicyName

Write-Host "`nAzure Firewall deployment complete. Next: route tables." -ForegroundColor Green
