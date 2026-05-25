<#
    Project: Automation – PowerShell VM Deployment
    Script: configure-vm.ps1
    Purpose: Apply post-deployment configuration to Azure VMs:
             - Install updates
             - Install VM extensions
             - Configure WinRM/SSH
             - Apply tags
             - Install baseline tools
             - Optional domain join
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VmName,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [switch]$InstallUpdates,

    [Parameter(Mandatory = $false)]
    [switch]$InstallExtensions,

    [Parameter(Mandatory = $false)]
    [switch]$ConfigureWinRM,

    [Parameter(Mandatory = $false)]
    [switch]$ConfigureSSH,

    [Parameter(Mandatory = $false)]
    [switch]$InstallBaselineTools,

    [Parameter(Mandatory = $false)]
    [switch]$JoinDomain,

    [Parameter(Mandatory = $false)]
    [string]$DomainName,

    [Parameter(Mandatory = $false)]
    [string]$DomainUser,

    [Parameter(Mandatory = $false)]
    [securestring]$DomainPassword
)

Write-Host "`n=== VM Post-Deployment Configuration ===" -ForegroundColor Cyan

# Detect OS
$vm = az vm get-instance-view -g $ResourceGroupName -n $VmName -o json | ConvertFrom-Json
$osType = $vm.storageProfile.osDisk.osType

Write-Host "Detected OS: $osType" -ForegroundColor Yellow

# Convert domain password if provided
if ($DomainPassword) {
    $plainDomainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($DomainPassword)
    )
}

# -----------------------------
# 1. Install Updates
# -----------------------------
if ($InstallUpdates) {
    Write-Host "`n[1/6] Installing OS updates..." -ForegroundColor Yellow

    if ($osType -eq "Windows") {
        az vm run-command invoke `
            -g $ResourceGroupName `
            -n $VmName `
            --command-id RunPowerShellScript `
            --scripts "Install-WindowsUpdate -AcceptAll -AutoReboot" | Out-Null
    }
    else {
        az vm run-command invoke `
            -g $ResourceGroupName `
            -n $VmName `
            --command-id RunShellScript `
            --scripts "sudo apt update && sudo apt upgrade -y" | Out-Null
    }

    Write-Host "Updates installed." -ForegroundColor Green
}

# -----------------------------
# 2. Install VM Extensions
# -----------------------------
if ($InstallExtensions) {
    Write-Host "`n[2/6] Installing VM extensions..." -ForegroundColor Yellow

    if ($osType -eq "Windows") {
        az vm extension set `
            --publisher Microsoft.Compute `
            --name CustomScriptExtension `
            --vm-name $VmName `
            --resource-group $ResourceGroupName `
            --settings "{}" | Out-Null
    }
    else {
        az vm extension set `
            --publisher Microsoft.Azure.Extensions `
            --name CustomScript `
            --vm-name $VmName `
            --resource-group $ResourceGroupName `
            --settings "{}" | Out-Null
    }

    Write-Host "Extensions installed." -ForegroundColor Green
}

# -----------------------------
# 3. Configure WinRM (Windows)
# -----------------------------
if ($ConfigureWinRM -and $osType -eq "Windows") {
    Write-Host "`n[3/6] Configuring WinRM..." -ForegroundColor Yellow

    az vm run-command invoke `
        -g $ResourceGroupName `
        -n $VmName `
        --command-id RunPowerShellScript `
        --scripts @"
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
"@ | Out-Null

    Write-Host "WinRM configured." -ForegroundColor Green
}

# -----------------------------
# 4. Configure SSH (Linux)
# -----------------------------
if ($ConfigureSSH -and $osType -eq "Linux") {
    Write-Host "`n[4/6] Configuring SSH..." -ForegroundColor Yellow

    az vm run-command invoke `
        -g $ResourceGroupName `
        -n $VmName `
        --command-id RunShellScript `
        --scripts "sudo systemctl enable ssh && sudo systemctl start ssh" | Out-Null

    Write-Host "SSH configured." -ForegroundColor Green
}

# -----------------------------
# 5. Install Baseline Tools
# -----------------------------
if ($InstallBaselineTools) {
    Write-Host "`n[5/6] Installing baseline tools..." -ForegroundColor Yellow

    if ($osType -eq "Windows") {
        az vm run-command invoke `
            -g $ResourceGroupName `
            -n $VmName `
            --command-id RunPowerShellScript `
            --scripts @"
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force
winget install --id=Microsoft.VisualStudioCode -e
winget install --id=Git.Git -e
"@ | Out-Null
    }
    else {
        az vm run-command invoke `
            -g $ResourceGroupName `
            -n $VmName `
            --command-id RunShellScript `
            --scripts "sudo apt install -y htop git curl unzip" | Out-Null
    }

    Write-Host "Baseline tools installed." -ForegroundColor Green
}

# -----------------------------
# 6. Domain Join (Optional)
# -----------------------------
if ($JoinDomain -and $osType -eq "Windows") {
    Write-Host "`n[6/6] Joining domain..." -ForegroundColor Yellow

    az vm run-command invoke `
        -g $ResourceGroupName `
        -n $VmName `
        --command-id RunPowerShellScript `
        --scripts @"
Add-Computer -DomainName '$DomainName' -Credential (New-Object System.Management.Automation.PSCredential('$DomainUser',(ConvertTo-SecureString '$plainDomainPassword' -AsPlainText -Force))) -Force -Restart
"@ | Out-Null

    Write-Host "Domain join initiated." -ForegroundColor Green
}

Write-Host "`nVM configuration complete." -ForegroundColor Cyan
