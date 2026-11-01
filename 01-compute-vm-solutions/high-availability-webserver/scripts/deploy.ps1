#requires -Version 7.3
[CmdletBinding()]
param([string]$Location = 'eastus', [string]$ResourceGroupName = 'rg-ha-web')
. "$PSScriptRoot/../../../tools/Initialize-Lab.ps1"
$password = Read-LabPassword
try {
    $tags = @('Environment=Dev', 'Owner=Abdulbasit', 'Project=HA-Web')
    az group create --name $ResourceGroupName --location $Location --tags $tags --output none
    az network nsg create -g $ResourceGroupName -n nsg-web --output none
    az network nsg rule create -g $ResourceGroupName --nsg-name nsg-web -n Allow-HTTP --priority 100 --direction Inbound --protocol Tcp --source-address-prefixes Internet --destination-port-ranges 80 --access Allow --output none
    az network vnet create -g $ResourceGroupName -n vnet-ha-web --address-prefixes 10.0.0.0/16 --subnet-name snet-web --subnet-prefixes 10.0.1.0/24 --output none
    az network vnet subnet update -g $ResourceGroupName --vnet-name vnet-ha-web -n snet-web --network-security-group nsg-web --output none
    az vm availability-set create -g $ResourceGroupName -n avset-web --platform-fault-domain-count 2 --platform-update-domain-count 5 --output none
    foreach ($vm in @('webvm01', 'webvm02')) {
        # An explicitly created NIC prevents implicit NSG/RDP rules in az vm create.
        az network public-ip create -g $ResourceGroupName -n "$vm-pip" --sku Standard --allocation-method Static --output none
        az network nic create -g $ResourceGroupName -n "$vm-nic" --vnet-name vnet-ha-web --subnet snet-web --public-ip-address "$vm-pip" --output none
        az vm create -g $ResourceGroupName -n $vm --availability-set avset-web --image Win2022Datacenter --size Standard_B2s --nics "$vm-nic" --admin-username azureuser --admin-password $password --tags $tags --output none
        az vm list-ip-addresses -g $ResourceGroupName -n $vm --output table
    }
}
finally { $password = $null }
