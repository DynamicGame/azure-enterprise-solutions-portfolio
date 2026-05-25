<#
    Project: Governance & Compliance Solutions
    Script: deploy-policies.ps1
    Purpose: Deploy Azure Policy definitions for:
             - Tag enforcement
             - Allowed locations
             - Allowed SKUs
             Create a Governance Initiative (Policy Set)
#>

Write-Host "`nDeploying Azure Policy definitions..." -ForegroundColor Cyan

# -----------------------------
# Variables
# -----------------------------
$mgId = "mg-corp"   # Corporate governance management group

# Policy Names
$polTagEnv       = "Require-Tag-Environment"
$polTagOwner     = "Require-Tag-Owner"
$polTagCost      = "Require-Tag-CostCenter"
$polAllowedLoc   = "Allowed-Locations"
$polAllowedSku   = "Allowed-SKUs"

# Initiative Name
$initiativeName  = "Governance-Baseline"

# -----------------------------
# Helper: Create Policy Definition
# -----------------------------
function EnsurePolicy {
    param(
        [string]$name,
        [string]$displayName,
        [string]$policyRuleFile
    )

    $exists = az policy definition show `
        --name $name `
        --query "name" -o tsv 2>$null

    if ($exists) {
        Write-Host "Policy already exists: $name" -ForegroundColor Green
    }
    else {
        Write-Host "Creating policy: $name" -ForegroundColor Yellow

        az policy definition create `
            --name $name `
            --display-name $displayName `
            --rules $policyRuleFile `
            --mode All `
            --management-group $mgId | Out-Null
    }
}

# -----------------------------
# 1. Deploy Tag Enforcement Policies
# -----------------------------
EnsurePolicy -name $polTagEnv   -displayName "Require tag: Environment" -policyRuleFile "./policies/require-tag-environment.json"
EnsurePolicy -name $polTagOwner -displayName "Require tag: Owner"       -policyRuleFile "./policies/require-tag-owner.json"
EnsurePolicy -name $polTagCost  -displayName "Require tag: CostCenter"  -policyRuleFile "./policies/require-tag-costcenter.json"

# -----------------------------
# 2. Deploy Allowed Locations Policy
# -----------------------------
EnsurePolicy -name $polAllowedLoc -displayName "Allowed Locations" -policyRuleFile "./policies/allowed-locations.json"

# -----------------------------
# 3. Deploy Allowed SKUs Policy
# -----------------------------
EnsurePolicy -name $polAllowedSku -displayName "Allowed SKUs" -policyRuleFile "./policies/allowed-skus.json"

# -----------------------------
# 4. Create Governance Initiative
# -----------------------------
Write-Host "`nCreating Governance Initiative..." -ForegroundColor Cyan

$initiativeExists = az policy set-definition show `
    --name $initiativeName `
    --management-group $mgId `
    --query "name" -o tsv 2>$null

if ($initiativeExists) {
    Write-Host "Initiative already exists: $initiativeName" -ForegroundColor Green
}
else {
    az policy set-definition create `
        --name $initiativeName `
        --display-name "Governance Baseline" `
        --management-group $mgId `
        --definitions @(
            "{ 'policyDefinitionId': '/providers/Microsoft.Management/managementGroups/$mgId/providers/Microsoft.Authorization/policyDefinitions/$polTagEnv' }",
            "{ 'policyDefinitionId': '/providers/Microsoft.Management/managementGroups/$mgId/providers/Microsoft.Authorization/policyDefinitions/$polTagOwner' }",
            "{ 'policyDefinitionId': '/providers/Microsoft.Management/managementGroups/$mgId/providers/Microsoft.Authorization/policyDefinitions/$polTagCost' }",
            "{ 'policyDefinitionId': '/providers/Microsoft.Management/managementGroups/$mgId/providers/Microsoft.Authorization/policyDefinitions/$polAllowedLoc' }",
            "{ 'policyDefinitionId': '/providers/Microsoft.Management/managementGroups/$mgId/providers/Microsoft.Authorization/policyDefinitions/$polAllowedSku' }"
        ) | Out-Null

    Write-Host "Governance Initiative created: $initiativeName" -ForegroundColor Green
}

# -----------------------------
# Summary
# -----------------------------
Write-Host "`nPolicy deployment complete." -ForegroundColor Cyan
Write-Host "Policies deployed:"
Write-Host " - $polTagEnv"
Write-Host " - $polTagOwner"
Write-Host " - $polTagCost"
Write-Host " - $polAllowedLoc"
Write-Host " - $polAllowedSku"
Write-Host "`nInitiative:"
Write-Host " - $initiativeName"
