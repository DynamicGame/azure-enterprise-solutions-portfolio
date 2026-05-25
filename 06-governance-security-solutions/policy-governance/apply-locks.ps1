<#
    Project: Governance & Compliance Solutions
    Script: apply-locks.ps1
    Purpose: Apply resource locks to protect critical resources:
             - Production resource groups
             - Storage accounts
             - Log Analytics workspaces
             - Identity resources
             - Any resource marked as critical via tag
#>

Write-Host "`nApplying resource locks..." -ForegroundColor Cyan

# -----------------------------
# Variables
# -----------------------------
$prodRgNames = @("RG-Prod", "rg-production", "prod-resources")
$criticalTag = "Critical"
$criticalTagValue = "True"

# -----------------------------
# Helper: Apply Lock
# -----------------------------
function ApplyLock {
    param(
        [string]$scope,
        [string]$lockName,
        [string]$lockType
    )

    $exists = az lock show `
        --name $lockName `
        --resource-group "" `
        --scope $scope `
        --query "name" -o tsv 2>$null

    if ($exists) {
        Write-Host "Lock already exists: $lockName on $scope" -ForegroundColor Green
    }
    else {
        Write-Host "Applying $lockType lock: $lockName → $scope" -ForegroundColor Yellow

        az lock create `
            --name $lockName `
            --lock-type $lockType `
            --scope $scope | Out-Null
    }
}

# -----------------------------
# 1. Apply Locks to Production Resource Groups
# -----------------------------
Write-Host "`nApplying locks to Production resource groups..." -ForegroundColor Cyan

foreach ($rg in $prodRgNames) {

    $exists = az group show --name $rg --query "name" -o tsv 2>$null

    if ($exists) {
        $scope = "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$rg"

        ApplyLock -scope $scope -lockName "lock-prod-delete" -lockType "CanNotDelete"
        ApplyLock -scope $scope -lockName "lock-prod-readonly" -lockType "ReadOnly"
    }
}

# -----------------------------
# 2. Apply Locks to Critical Storage Accounts
# -----------------------------
Write-Host "`nApplying locks to critical Storage Accounts..." -ForegroundColor Cyan

$storageAccounts = az storage account list -o json | ConvertFrom-Json

foreach ($sa in $storageAccounts) {

    $tags = $sa.tags

    if ($tags.$criticalTag -eq $criticalTagValue) {

        ApplyLock `
            -scope $sa.id `
            -lockName "lock-storage-critical" `
            -lockType "CanNotDelete"
    }
}

# -----------------------------
# 3. Apply Locks to Log Analytics Workspaces
# -----------------------------
Write-Host "`nApplying locks to Log Analytics Workspaces..." -ForegroundColor Cyan

$workspaces = az monitor log-analytics workspace list -o json | ConvertFrom-Json

foreach ($ws in $workspaces) {

    ApplyLock `
        -scope $ws.id `
        -lockName "lock-law" `
        -lockType "CanNotDelete"
}

# -----------------------------
# 4. Apply Locks to Identity Resources (Optional)
# -----------------------------
Write-Host "`nApplying locks to Identity resources (optional)..." -ForegroundColor Cyan

$identityRgs = @("RG-Identity", "rg-entra", "rg-iam")

foreach ($rg in $identityRgs) {

    $exists = az group show --name $rg --query "name" -o tsv 2>$null

    if ($exists) {
        $scope = "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$rg"

        ApplyLock -scope $scope -lockName "lock-identity-delete" -lockType "CanNotDelete"
    }
}

# -----------------------------
# 5. Apply Locks to Any Resource Tagged as Critical
# -----------------------------
Write-Host "`nApplying locks to any resource tagged Critical=True..." -ForegroundColor Cyan

$criticalResources = az resource list `
    --tag "$criticalTag=$criticalTagValue" `
    -o json | ConvertFrom-Json

foreach ($res in $criticalResources) {

    ApplyLock `
        -scope $res.id `
        -lockName "lock-critical-resource" `
        -lockType "CanNotDelete"
}

# -----------------------------
# Summary
# -----------------------------
Write-Host "`nResource lock application complete." -ForegroundColor Green
Write-Host "Production RGs protected."
Write-Host "Critical Storage Accounts protected."
Write-Host "Log Analytics Workspaces protected."
Write-Host "Identity resources protected."
Write-Host "Tagged critical resources protected."
