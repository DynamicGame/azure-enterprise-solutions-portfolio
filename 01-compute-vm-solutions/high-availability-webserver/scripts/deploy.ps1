<#
    Project: Highly Available Web Server (Azure VMs + Availability Set)
    Author: DynamicGame (Abdulbasit)
    Purpose: Deploy a HA VM environment aligned with AZ-104 skills
#>

# -----------------------------
# Variables
# -----------------------------
$location        = "eastus"
$rgName          = "rg-ha-web"
$vnetName        = "vnet-ha-web"
$subnetName      = "snet-web"
$addressPrefix   = "10.0.0.0/16"
$subnetPrefix    = "10.0.1.0/24"
$nsgName         = "nsg-web"
$avSetName       = "avset-web"
$vm1Name         = "webvm01"
$vm2Name         = "webvm02"
$adminUser       = "azureuser"
$tags            = @{ Environment="Dev"; Owner="Abdulbasit"; Project="HA-Web" }

# -----------------------------
# 1. Create Resource Group
# -----------------------------
Write-Host "Creating Resource Group..." -ForegroundColor Cyan
az group create `
    --name $rgName `
    --location $location

# -----------------------------
# 2. Create Virtual Network + Subnet
# -----------------------------
Write-Host "Creating VNet and Subnet..." -ForegroundColor Cyan
az network vnet create `
    --resource-group $rgName `
    --name $vnetName `
    --address-prefix $addressPrefix `
    --subnet-name $subnetName `
    --subnet-prefix $subnetPrefix

# -----------------------------
# 3. Create Network Security Group
# -----------------------------
Write-Host "Creating NSG..." -ForegroundColor Cyan
az network nsg create `
    --resource-group $rgName `
    --name $nsgName

# Allow HTTP
az network nsg rule create `
    --resource-group $rgName `
    --nsg-name $nsgName `
    --name Allow-HTTP `
    --priority 100 `
    --protocol Tcp `
    --destination-port-ranges 80 `
    --access Allow

# Allow HTTPS
az network nsg rule create `
    --resource-group $rgName `
    --nsg-name $nsgName `
    --name Allow-HTTPS `
    --priority 110 `
    --protocol Tcp `
    --destination-port-ranges 443 `
    --access Allow

# Allow RDP (restricted)
az network nsg rule create `
    --resource-group $rgName `
    --nsg-name $nsgName `
    --name Allow-RDP `
    --priority 200 `
    --protocol Tcp `
    --destination-port-ranges 3389 `
    --access Allow

# -----------------------------
# 4. Create Availability Set
# -----------------------------
Write-Host "Creating Availability Set..." -ForegroundColor Cyan
az vm availability-set create `
    --resource-group $rgName `
    --name $avSetName `
    --platform-fault-domain-count 2 `
    --platform-update-domain-count 5

# -----------------------------
# 5. Deploy VM1
# -----------------------------
Write-Host "Deploying VM1..." -ForegroundColor Cyan
az vm create `
    --resource-group $rgName `
    --name $vm1Name `
    --availability-set $avSetName `
    --image Win2022Datacenter `
    --size Standard_B2s `
    --vnet-name $vnetName `
    --subnet $subnetName `
    --nsg $nsgName `
    --admin-username $adminUser `
    --generate-ssh-keys `
    --tags $tags

# -----------------------------
# 6. Deploy VM2
# -----------------------------
Write-Host "Deploying VM2..." -ForegroundColor Cyan
az vm create `
    --resource-group $rgName `
    --name $vm2Name `
    --availability-set $avSetName `
    --image Win2022Datacenter `
    --size Standard_B2s `
    --vnet-name $vnetName `
    --subnet $subnetName `
    --nsg $nsgName `
    --admin-username $adminUser `
    --generate-ssh-keys `
    --tags $tags

# -----------------------------
# 7. Output Public IP
# -----------------------------
Write-Host "`nDeployment complete!" -ForegroundColor Green
Write-Host "Public IP for VM1:" -ForegroundColor Yellow
az vm list-ip-addresses -g $rgName -n $vm1Name --query "[].virtualMachine.network.publicIpAddresses[].ipAddress" -o tsv
