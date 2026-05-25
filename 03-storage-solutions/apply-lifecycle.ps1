<#
    Project: Secure Storage Solutions (Blob + Azure Files)
    Script: apply-lifecycle.ps1
    Purpose: Apply lifecycle management rules from lifecycle-policy.json
             to the Storage Account.
#>

# -----------------------------
# Variables
# -----------------------------
$rgName = "rg-secure-storage"
$saName = "<YOUR-STORAGE-ACCOUNT-NAME>"   # Replace with actual name
$policyFile = "lifecycle-policy.json"

# -----------------------------
# Validate Policy File
# -----------------------------
if (-not (Test-Path $policyFile)) {
    Write-Host "ERROR: lifecycle-policy.json not found in current directory." -ForegroundColor Red
    exit
}

Write-Host "`nApplying lifecycle policy to Storage Account: $saName" -ForegroundColor Cyan

# -----------------------------
# Apply Lifecycle Policy
# -----------------------------
az storage account management-policy create `
    --account-name $saName `
    --resource-group $rgName `
    --policy (Get-Content $policyFile -Raw) | Out-Null

Write-Host "`nLifecycle policy applied successfully!" -ForegroundColor Green

# -----------------------------
# Display Policy Summary
# -----------------------------
Write-Host "`nCurrent lifecycle policy:" -ForegroundColor Yellow

az storage account management-policy show `
    --account-name $saName `
    --resource-group $rgName `
    --output table
