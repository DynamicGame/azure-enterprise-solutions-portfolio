<#
    Project: Secure Storage Solutions (Blob + Azure Files)
    Script: generate-sas.ps1
    Purpose: Generate secure SAS tokens (Account, Service, User Delegation)
             with time-bound and IP restrictions.
#>

# -----------------------------
# Variables
# -----------------------------
$rgName     = "rg-secure-storage"
$saName     = "<YOUR-STORAGE-ACCOUNT-NAME>"   # Replace with actual name
$container  = "secure-container"
$fileShare  = "fileshare01"

# SAS expiry settings
$startTime  = (Get-Date).ToUniversalTime().AddMinutes(-5).ToString("yyyy-MM-ddTHH:mmZ")
$expiryTime = (Get-Date).ToUniversalTime().AddHours(1).ToString("yyyy-MM-ddTHH:mmZ")

# Optional IP restriction (your public IP)
$clientIP   = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip

Write-Host "`nGenerating SAS tokens for Storage Account: $saName" -ForegroundColor Cyan

# -----------------------------
# 1. Get Storage Account Key
# -----------------------------
Write-Host "Retrieving Storage Account key..." -ForegroundColor Cyan
$key = az storage account keys list `
    --resource-group $rgName `
    --account-name $saName `
    --query "[0].value" -o tsv

# -----------------------------
# 2. Generate Account SAS
# -----------------------------
Write-Host "`nCreating Account SAS..." -ForegroundColor Yellow

$accountSas = az storage account generate-sas `
    --permissions acdlpruw `
    --resource-types sco `
    --services bfqt `
    --start $startTime `
    --expiry $expiryTime `
    --ip $clientIP `
    --https-only `
    --account-name $saName `
    --account-key $key -o tsv

Write-Host "Account SAS generated." -ForegroundColor Green

# -----------------------------
# 3. Generate Blob Service SAS
# -----------------------------
Write-Host "`nCreating Blob Service SAS..." -ForegroundColor Yellow

$blobSas = az storage container generate-sas `
    --name $container `
    --permissions rwdl `
    --start $startTime `
    --expiry $expiryTime `
    --ip $clientIP `
    --https-only `
    --account-name $saName `
    --account-key $key -o tsv

Write-Host "Blob SAS generated." -ForegroundColor Green

# -----------------------------
# 4. Generate File Share SAS
# -----------------------------
Write-Host "`nCreating File Share SAS..." -ForegroundColor Yellow

$fileSas = az storage share generate-sas `
    --name $fileShare `
    --permissions rwdl `
    --start $startTime `
    --expiry $expiryTime `
    --ip $clientIP `
    --https-only `
    --account-name $saName `
    --account-key $key -o tsv

Write-Host "File Share SAS generated." -ForegroundColor Green

# -----------------------------
# 5. Generate User Delegation SAS (Most Secure)
# -----------------------------
Write-Host "`nRequesting User Delegation Key..." -ForegroundColor Cyan

az storage account get-user-delegation-key `
    --account-name $saName `
    --resource-group $rgName `
    --start $startTime `
    --expiry $expiryTime | ConvertFrom-Json

Write-Host "Creating User Delegation SAS..." -ForegroundColor Yellow

$udSas = az storage blob generate-sas `
    --container-name $container `
    --name "example.txt" `
    --permissions r `
    --start $startTime `
    --expiry $expiryTime `
    --ip $clientIP `
    --https-only `
    --as-user `
    --account-name $saName -o tsv

Write-Host "User Delegation SAS generated." -ForegroundColor Green

# -----------------------------
# 6. Output Results
# -----------------------------
Write-Host "`n==================== SAS TOKENS ====================" -ForegroundColor Cyan

Write-Host "`n🔐 Account SAS:" -ForegroundColor Yellow
Write-Host $accountSas

Write-Host "`n📦 Blob SAS (Container):" -ForegroundColor Yellow
Write-Host $blobSas

Write-Host "`n📁 File Share SAS:" -ForegroundColor Yellow
Write-Host $fileSas

Write-Host "`n🛡️ User Delegation SAS (Most Secure):" -ForegroundColor Yellow
Write-Host $udSas

Write-Host "`n=====================================================" -ForegroundColor Cyan

# -----------------------------
# Security Warning
# -----------------------------
Write-Host "`n⚠️ SECURITY WARNING:" -ForegroundColor Red
Write-Host "Treat SAS tokens like passwords. They grant direct access to data."
Write-Host "Do NOT store SAS tokens in GitHub, Teams, email, or documentation."
Write-Host "Use User Delegation SAS whenever possible." -ForegroundColor Red
