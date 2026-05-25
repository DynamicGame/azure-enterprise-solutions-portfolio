<#
    Project: Secure Storage Solutions (Blob + Azure Files)
    Script: enable-immutability.ps1
    Purpose: Enable immutability (WORM), legal hold, and time-based retention
             on a blob container for compliance and tamper protection.
#>

# -----------------------------
# Variables
# -----------------------------
$rgName     = "rg-secure-storage"
$saName     = "<YOUR-STORAGE-ACCOUNT-NAME>"   # Replace with actual name
$container  = "secure-container"
$retentionDays = 90   # Time-based retention (WORM)

# -----------------------------
# Enable Container
# -----------------------------
Write-Host "`nCreating container (if not exists)..." -ForegroundColor Cyan

az storage container create `
    --name $container `
    --account-name $saName `
    --auth-mode login | Out-Null

# -----------------------------
# 1. Enable Time-Based Retention (WORM)
# -----------------------------
Write-Host "`nEnabling time-based retention (WORM)..." -ForegroundColor Yellow

az storage container immutability-policy create `
    --account-name $saName `
    --resource-group $rgName `
    --container-name $container `
    --period $retentionDays `
    --allow-protected-append-writes true | Out-Null

Write-Host "Time-based retention enabled for $retentionDays days." -ForegroundColor Green

# -----------------------------
# 2. Enable Legal Hold
# -----------------------------
Write-Host "`nApplying legal hold..." -ForegroundColor Yellow

az storage container legal-hold create `
    --account-name $saName `
    --resource-group $rgName `
    --container-name $container `
    --tags "Compliance" "DoNotDelete" | Out-Null

Write-Host "Legal hold applied with tags: Compliance, DoNotDelete" -ForegroundColor Green

# -----------------------------
# 3. Show Immutability Status
# -----------------------------
Write-Host "`nCurrent immutability policy:" -ForegroundColor Cyan

az storage container immutability-policy show `
    --account-name $saName `
    --resource-group $rgName `
    --container-name $container `
    --output table

Write-Host "`nLegal hold status:" -ForegroundColor Cyan

az storage container legal-hold show `
    --account-name $saName `
    --resource-group $rgName `
    --container-name $container `
    --output table

# -----------------------------
# Final Message
# -----------------------------
Write-Host "`nImmutability configuration complete!" -ForegroundColor Green
Write-Host "Container: $container"
Write-Host "Storage Account: $saName"
