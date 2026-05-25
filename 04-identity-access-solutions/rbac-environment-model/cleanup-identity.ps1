<#
    Project: Identity & Access Solutions
    Script: cleanup-identity.ps1
    Purpose: Remove all identity resources created in Project 4:
             - Entra ID groups
             - RBAC assignments
             - Placeholder resource groups (if created)
#>

# -----------------------------
# Variables
# -----------------------------
$groups = @(
    "Dev-Readers", "Dev-Contributors",
    "Test-Readers", "Test-Contributors",
    "Prod-Readers", "Prod-Contributors", "Prod-Owners"
)

$placeholderRGs = @("RG-Dev", "RG-Test", "RG-Prod")

Write-Host "`nStarting cleanup of Identity & Access Solution..." -ForegroundColor Cyan

# -----------------------------
# 1. Remove RBAC Assignments
# -----------------------------
Write-Host "`nRemoving RBAC assignments..." -ForegroundColor Yellow

foreach ($g in $groups) {

    $groupId = az ad group list `
        --filter "displayName eq '$g'" `
        --query "[0].id" -o tsv

    if (-not $groupId) { continue }

    $assignments = az role assignment list `
        --assignee $groupId -o json | ConvertFrom-Json

    foreach ($a in $assignments) {
        Write-Host "Removing RBAC: $g → $($a.roleDefinitionName)" -ForegroundColor Cyan

        az role assignment delete `
            --assignee $groupId `
            --role $a.roleDefinitionName `
            --scope $a.scope 2>$null
    }
}

# -----------------------------
# 2. Delete Entra ID Groups
# -----------------------------
Write-Host "`nDeleting Entra ID groups..." -ForegroundColor Yellow

foreach ($g in $groups) {
    Write-Host "Deleting group: $g" -ForegroundColor Cyan
    az ad group delete --group $g 2>$null
}

# -----------------------------
# 3. Delete Placeholder Resource Groups
# -----------------------------
Write-Host "`nDeleting placeholder resource groups (if they exist)..." -ForegroundColor Yellow

foreach ($rg in $placeholderRGs) {
    az group delete --name $rg --yes --no-wait 2>$null
}

Write-Host "`nIdentity cleanup complete." -ForegroundColor Green
