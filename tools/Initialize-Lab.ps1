#requires -Version 7.3
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw 'Azure CLI is required. Install it, run az login, and select the lab subscription.'
}
$account = az account show --output json --only-show-errors | ConvertFrom-Json
Write-Host "Selected subscription: $($account.name) ($($account.id)); tenant: $($account.tenantId)"
function Read-LabPassword([string]$Prompt = 'Windows administrator password') {
    $secret = Read-Host $Prompt -AsSecureString
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer) }
}
