#requires -Version 7.3
[CmdletBinding()]
param(
    [string]$ResourceGroupName = 'rg-ha-web',
    [ValidateScript({ $ip = $null; $_ -match '/32$' -and [Net.IPAddress]::TryParse(($_ -split '/')[0], [ref]$ip) -and $ip.AddressFamily -eq 'InterNetwork' })]
    [string]$AdminCidr
)
. "$PSScriptRoot/../../../tools/Initialize-Lab.ps1"
az network nsg rule create -g $ResourceGroupName --nsg-name nsg-web -n Allow-HTTP --priority 100 --direction Inbound --protocol Tcp --source-address-prefixes Internet --destination-port-ranges 80 --access Allow --output none
if ($AdminCidr) {
    az network nsg rule create -g $ResourceGroupName --nsg-name nsg-web -n Allow-RDP --priority 200 --direction Inbound --protocol Tcp --source-address-prefixes $AdminCidr --destination-port-ranges 3389 --access Allow --output none
}
else { Write-Host 'No RDP rule added. This does not revoke an existing rule; inspect existing NSG rules on reused environments.' }
