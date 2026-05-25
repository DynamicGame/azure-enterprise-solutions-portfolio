<#
    Project: Governance & Compliance Solutions
    Script: cleanup-governance.ps1
    Purpose: Remove all governance resources created in Project 6:
             - Policy assignments
             - Policy definitions
             - Initiatives
             - Resource locks
             - Management groups (optional)
#>

Write-Host "`nStarting Governance Cleanup..." -ForegroundColor Cyan

# -----------------------------
# Variables
# -----------------------------
$mgId = "mg-corp"

$policies = @(
    "Require-Tag-Environment",
    "Require-Tag-Owner",
    "Require-Tag-CostCenter",
    "Allowed-Locations",
    "Allowed-SKUs"
)

$initiativeName = "Governance-Baseline"

$mgChildren = @("mg-dev", "mg-test", "mg-prod")

# -----------------------------
# 1. Remove Policy Assignments
# -----------------------------
Write-Host "`nRemoving policy assignments..." -ForegroundColor Yellow

$assignments = az policy assignment list `
    --scope "/providers/Microsoft.Management/managementGroups/$mgId" `
    -o json | ConvertFrom-Json

foreach ($asg in $assignments) {
    Write-Host "Deleting assignment: $($asg.name)" -ForegroundColor Cyan
    az policy assignment delete --name $asg.name --scope $asg.scope 2>$null
}

# -----------------------------
# 2. Remove Initiative
# -----------------------------
Write-Host "`nRemoving initiative..." -ForegroundColor Yellow

$initiativeId = az policy set-definition show `
    --name $initiativeName `
    --management-group $mgId `
    --query "id" -o tsv 2>$null

if ($initiativeId) {
    az policy set-definition delete `
        --name $initiativeName `
        --management-group $mgId 2>$null

    Write-Host "Deleted initiative: $initiativeName" -ForegroundColor Green
} else {
    Write-Host "Initiative not found: $initiativeName" -ForegroundColor DarkYellow
}

# -----------------------------
# 3. Remove Policy Definitions
# -----------------------------
Write-Host "`nRemoving policy definitions..." -ForegroundColor Yellow

foreach ($pol in $policies) {

    $exists = az policy definition show `
        --name $pol `
        --query "name" -o tsv 2>$null

    if ($exists) {
        Write-Host "Deleting policy: $pol" -ForegroundColor Cyan
        az policy definition delete --name $pol 2>$null
    } else {
        Write-Host "Policy not found: $pol" -ForegroundColor DarkYellow
    }
}

# -----------------------------
# 4. Remove Resource Locks
# -----------------------------
Write-Host "`nRemoving resource locks..." -ForegroundColor Yellow

$locks = az lock list -o json | ConvertFrom-Json

foreach ($lock in $locks) {
    Write-Host "Deleting lock: $($lock.name) → $($lock.scope)" -ForegroundColor Cyan
    az lock delete --name $lock.name --scope $lock.scope 2>$null
}

# -----------------------------
# 5. Optional: Remove Management Groups
# -----------------------------
Write-Host "`nDo you want to delete the management groups? (y/n)" -ForegroundColor Cyan
$choice = Read-Host

if ($choice -eq "y") {

    Write-Host "`nRemoving child management groups..." -ForegroundColor Yellow

    foreach ($mg in $mgChildren) {
        Write-Host "Deleting MG: $mg" -ForegroundColor Cyan
        az account management-group delete --name $mg 2>$null
    }

    Write-Host "Deleting parent MG: $mgId" -ForegroundColor Cyan
    az account management-group delete --name $mgId 2>$null

    Write-Host "Management groups removed." -ForegroundColor Green
}
else {
    Write-Host "Skipping management group deletion." -ForegroundColor Green
}

# -----------------------------
# Summary
# -----------------------------
Write-Host "`nGovernance cleanup complete." -ForegroundColor Green
Write-Host "All policies, assignments, locks, and initiatives removed."
