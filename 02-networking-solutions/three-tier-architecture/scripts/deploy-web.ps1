<#
    Project: Three-Tier Network - Project 2
    Script: deploy-web.ps1
    Purpose: Deploy Web Tier VMs + Public Load Balancer + IIS installation
#>

# -----------------------------
# Variables
# -----------------------------
$location      = "uksouth"
$rgName        = "rg-three-tier-network"
$vnetName      = "vnet-three-tier"
$webSubnetName = "web-subnet"

# Load Balancer
$lbName        = "lb-web"
$lbPipName     = "lb-web-pip"
$backendPool   = "lb-web-bepool"
$probeName     = "lb-web-probe"
$lbRuleName    = "lb-web-rule"

# Web VMs
$vm1Name = "webvm01"
$vm2Name = "webvm02"
$vmSize  = "Standard_B2s"
$adminUser = "azureadmin"

# ASG
$asgWebName = "asg-web"

# Tags
$tags = "Environment=Dev" `
      + " Project=ThreeTierNetwork" `
      + " Owner=Abdulbasit"

# -----------------------------
# 1. Public IP for Load Balancer
# -----------------------------
Write-Host "Creating Public IP for Load Balancer..." -ForegroundColor Cyan

az network public-ip create `
  --resource-group $rgName `
  --name $lbPipName `
  --sku Standard `
  --allocation-method Static `
  --location $location `
  --tags $tags

# -----------------------------
# 2. Create Load Balancer
# -----------------------------
Write-Host "Creating Public Load Balancer..." -ForegroundColor Cyan

az network lb create `
  --resource-group $rgName `
  --name $lbName `
  --sku Standard `
  --location $location `
  --public-ip-address $lbPipName `
  --backend-pool-name $backendPool `
  --tags $tags

# Health probe
az network lb probe create `
  --resource-group $rgName `
  --lb-name $lbName `
  --name $probeName `
  --protocol tcp `
  --port 80

# LB rule
az network lb rule create `
  --resource-group $rgName `
  --lb-name $lbName `
  --name $lbRuleName `
  --protocol Tcp `
  --frontend-port 80 `
  --backend-port 80 `
  --frontend-ip-name "LoadBalancerFrontEnd" `
  --backend-pool-name $backendPool `
  --probe-name $probeName

# -----------------------------
# 3. Create NICs for Web VMs
# -----------------------------
Write-Host "Creating NICs for Web VMs..." -ForegroundColor Cyan

# NIC 1
az network nic create `
  --resource-group $rgName `
  --name "$vm1Name-nic" `
  --vnet-name $vnetName `
  --subnet $webSubnetName `
  --application-security-groups $asgWebName `
  --lb-address-pools $backendPool `
  --location $location `
  --tags $tags

# NIC 2
az network nic create `
  --resource-group $rgName `
  --name "$vm2Name-nic" `
  --vnet-name $vnetName `
  --subnet $webSubnetName `
  --application-security-groups $asgWebName `
  --lb-address-pools $backendPool `
  --location $location `
  --tags $tags

# -----------------------------
# 4. Deploy Web VMs (No Public IPs)
# -----------------------------
Write-Host "Deploying Web VMs..." -ForegroundColor Cyan

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
# 5. Install IIS on both VMs
# -----------------------------
Write-Host "Installing IIS on Web VMs..." -ForegroundColor Cyan

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

Write-Host "`nWeb tier deployment complete. Public LB is ready and IIS is installed." -ForegroundColor Green
