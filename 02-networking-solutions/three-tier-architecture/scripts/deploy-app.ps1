<#
    Project: Three-Tier Network - Project 2
    Script: deploy-app.ps1
    Purpose: Deploy App Tier VMs + Internal Load Balancer + App Server installation
#>

# -----------------------------
# Variables
# -----------------------------
$location      = "uksouth"
$rgName        = "rg-three-tier-network"
$vnetName      = "vnet-three-tier"
$appSubnetName = "app-subnet"

# Internal Load Balancer
$ilbName       = "ilb-app"
$backendPool   = "ilb-app-bepool"
$probeName     = "ilb-app-probe"
$lbRuleName    = "ilb-app-rule"

# App VMs
$vm1Name = "appvm01"
$vm2Name = "appvm02"
$vmSize  = "Standard_B2s"
$adminUser = "azureadmin"

# ASG
$asgAppName = "asg-app"

# Tags
$tags = "Environment=Dev" `
      + " Project=ThreeTierNetwork" `
      + " Owner=Abdulbasit"

# -----------------------------
# 1. Create Internal Load Balancer
# -----------------------------
Write-Host "Creating Internal Load Balancer..." -ForegroundColor Cyan

az network lb create `
  --resource-group $rgName `
  --name $ilbName `
  --sku Standard `
  --location $location `
  --backend-pool-name $backendPool `
  --vnet-name $vnetName `
  --subnet $appSubnetName `
  --tags $tags

# Health probe (port 8080)
az network lb probe create `
  --resource-group $rgName `
  --lb-name $ilbName `
  --name $probeName `
  --protocol tcp `
  --port 8080

# LB rule (8080 → backend)
az network lb rule create `
  --resource-group $rgName `
  --lb-name $ilbName `
  --name $lbRuleName `
  --protocol Tcp `
  --frontend-port 8080 `
  --backend-port 8080 `
  --frontend-ip-name "LoadBalancerFrontEnd" `
  --backend-pool-name $backendPool `
  --probe-name $probeName

# -----------------------------
# 2. Create NICs for App VMs
# -----------------------------
Write-Host "Creating NICs for App VMs..." -ForegroundColor Cyan

# NIC 1
az network nic create `
  --resource-group $rgName `
  --name "$vm1Name-nic" `
  --vnet-name $vnetName `
  --subnet $appSubnetName `
  --application-security-groups $asgAppName `
  --lb-address-pools $backendPool `
  --location $location `
  --tags $tags

# NIC 2
az network nic create `
  --resource-group $rgName `
  --name "$vm2Name-nic" `
  --vnet-name $vnetName `
  --subnet $appSubnetName `
  --application-security-groups $asgAppName `
  --lb-address-pools $backendPool `
  --location $location `
  --tags $tags

# -----------------------------
# 3. Deploy App VMs (No Public IPs)
# -----------------------------
Write-Host "Deploying App VMs..." -ForegroundColor Cyan

az vm create `
  --resource-group $rgName `
  --name $vm1Name `
  --nics "$vm1Name-nic" `
  --image Win2022Datacenter `
  --size $vmSize `
  --admin-username $adminUser `
  --generate-ssh-keys `
  --no-wait `
  --tags $tags

az vm create `
  --resource-group $rgName `
  --name $vm2Name `
  --nics "$vm2Name-nic" `
  --image Win2022Datacenter `
  --size $vmSize `
  --admin-username $adminUser `
  --generate-ssh-keys `
  --no-wait `
  --tags $tags

# -----------------------------
# 4. Install App Server (IIS for testing)
# -----------------------------
Write-Host "Installing IIS on App VMs..." -ForegroundColor Cyan

# VM1 IIS
az vm extension set `
  --resource-group $rgName `
  --vm-name $vm1Name `
  --name CustomScriptExtension `
  --publisher Microsoft.Compute `
  --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server"}'

# VM2 IIS
az vm extension set `
  --resource-group $rgName `
  --vm-name $vm2Name `
  --name CustomScriptExtension `
  --publisher Microsoft.Compute `
  --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server"}'

Write-Host "`nApp tier deployment complete. Internal LB is ready and IIS is installed." -ForegroundColor Green
