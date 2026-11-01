#requires -Version 7.3
[CmdletBinding()]
param([string]$ResourceGroupName = 'rg-ha-web')
. "$PSScriptRoot/../../../tools/Initialize-Lab.ps1"
foreach ($vm in @('webvm01', 'webvm02')) {
    $result = az vm run-command invoke -g $ResourceGroupName -n $vm --command-id RunPowerShellScript --scripts '$ErrorActionPreference = "Stop"; Install-WindowsFeature -Name Web-Server -IncludeManagementTools; Get-Service W3SVC' --output json | ConvertFrom-Json
    # The command transport can succeed while the guest script fails; inspect guest output.
    $result.value | Select-Object code, message | Format-List
}
Write-Host 'Inspect guest output and test HTTP on both VM addresses before recording success.'
