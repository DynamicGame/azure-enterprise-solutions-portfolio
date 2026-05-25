<#
    Project: Automation – PowerShell VM Deployment
    Script: cleanup-vm.ps1
    Purpose: Remove all resources created by deploy-vm.ps1:
             - VM
             - NIC
             - NSG
             - Public IP
             - VNet + Subnet
             - OS + Data disks
             - Optional: Resource Group
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VmName,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [switch]$DeleteResourceGroup
)

Write-Host "`n=== VM Cleanup Script ===" -ForegroundColor Cyan

# -----------------------------
# 1. Check if VM exists
# -----------------------------
$vm = az vm show -g $ResourceGroupName -n $VmName -o json 2>$null | ConvertFrom-Json

if (-not $vm) {
    Write-Host "VM not found: $VmName" -ForegroundColor Yellow
} else {
    Write-Host "`n[1/6] Deleting VM..." -ForegroundColor Yellow

    # Capture disk names before deletion
    $osDiskName = $vm.storageProfile.osDisk.name
    $dataDisks  = $vm.storageProfile.dataDisks.name

    az vm delete `
        -g $ResourceGroupName `
        -n $VmName `
        --yes | Out-Null

    Write-Host "VM deleted: $VmName" -ForegroundColor Green
}

# -----------------------------
# 2. Delete NIC
# -----------------------------
Write-Host "`n[2/6] Deleting NIC..." -ForegroundColor Yellow

$nicName = "$VmName-nic"
$nic = az network nic show -g $ResourceGroupName -n $nicName -o json 2>$null | ConvertFrom-Json

if ($nic) {
    az network nic delete -g $ResourceGroupName -n $nicName | Out-Null
    Write-Host "NIC deleted: $nicName" -ForegroundColor Green
} else {
    Write-Host "NIC not found: $nicName" -ForegroundColor DarkYellow
}

# -----------------------------
# 3. Delete Public IP (if exists)
# -----------------------------
Write-Host "`n[3/6] Deleting Public IP..." -ForegroundColor Yellow

$pipName = "$VmName-pip"
$pip = az network public-ip show -g $ResourceGroupName -n $pipName -o json 2>$null | ConvertFrom-Json

if ($pip) {
    az network public-ip delete -g $ResourceGroupName -n $pipName | Out-Null
    Write-Host "Public IP deleted: $pipName" -ForegroundColor Green
} else {
    Write-Host "Public IP not found: $pipName" -ForegroundColor DarkYellow
}

# -----------------------------
# 4. Delete NSG
# -----------------------------
Write-Host "`n[4/6] Deleting NSG..." -ForegroundColor Yellow

$nsgName = "$VmName-nsg"
$nsg = az network nsg show -g $ResourceGroupName -n $nsgName -o json 2>$null | ConvertFrom-Json

if ($nsg) {
    az network nsg delete -g $ResourceGroupName -n $nsgName | Out-Null
    Write-Host "NSG deleted: $nsgName" -ForegroundColor Green
} else {
    Write-Host "NSG not found: $nsgName" -ForegroundColor DarkYellow
}

# -----------------------------
# 5. Delete VNet + Subnet
# -----------------------------
Write-Host "`n[5/6] Deleting VNet..." -ForegroundColor Yellow

$vnetName = "$VmName-vnet"
$vnet = az network vnet show -g $ResourceGroupName -n $vnetName -o json 2>$null | ConvertFrom-Json

if ($vnet) {
    az network vnet delete -g $ResourceGroupName -n $vnetName | Out-Null
    Write-Host "VNet deleted: $vnetName" -ForegroundColor Green
} else {
    Write-Host "VNet not found: $vnetName" -ForegroundColor DarkYellow
}

# -----------------------------
# 6. Delete Disks
# -----------------------------
Write-Host "`n[6/6] Deleting Disks..." -ForegroundColor Yellow

if ($osDiskName) {
    az disk delete -g $ResourceGroupName -n $osDiskName --yes | Out-Null
    Write-Host "OS Disk deleted: $osDiskName" -ForegroundColor Green
}

foreach ($disk in $dataDisks) {
    az disk delete -g $ResourceGroupName -n $disk --yes | Out-Null
    Write-Host "Data Disk deleted: $disk" -ForegroundColor Green
}

# -----------------------------
# Optional: Delete Resource Group
# -----------------------------
if ($DeleteResourceGroup) {
    Write-Host "`nDeleting Resource Group: $ResourceGroupName" -ForegroundColor Red
    az group delete -n $ResourceGroupName --yes --no-wait
} else {
    Write-Host "`nResource Group retained: $ResourceGroupName" -ForegroundColor Green
}

# -----------------------------
# Summary
# -----------------------------
Write-Host "`nCleanup complete." -ForegroundColor Cyan
Write-Host "All VM-related resources have been removed."
