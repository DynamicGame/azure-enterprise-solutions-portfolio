<#
    Project: Governance & Compliance Solutions
    Script: assign-policies.ps1
    Purpose: Assign Azure Policy definitions and the Governance Initiative
             to the Corporate Management Group (mg-corp).
#>

Write-Host "`nAssigning Azure Policies to Management Groups..." -ForegroundColor Cyan

# -----------------------------
# Variables
# -----------------------------
$mgId = "mg-corp"

# Policy Names
$polTagEnv       = "Require-Tag-Environment"
$polTagOwner     = "Require-Tag-Owner"
$polTagCost      = "Require-Tag-CostCenter"
$polAllowedLoc   = "Allowed-Locations"
$polAllowedSku   = "Allowed-SKUs"

# Initiative
$initiativeName  = "Governance-Baseline"

# -----------------------------
# Helper: Assign Policy
# -----------------------------
function AssignPolicy {
    param(
        [string]$policyName,
        [string]$assignmentName,
        [hashtable]$parameters = $null
    )

    Write-Host "Assigning policy: $policyName" -ForegroundColor Yellow

    $policyId = az policy definition show `
        --name $policyName `
        --query "id" -o tsv

    if (-not $policyId) {
        Write-Host "ERROR: Policy not found: $policyName" -ForegroundColor Red
        return
    }

    $paramsJson = if ($parameters) { $parameters | ConvertTo-Json -Depth 5 } else { $null }

    az policy assignment create `
        --name $assignmentName `
        --scope "/providers/Microsoft.Management/managementGroups/$mgId" `
        --policy $policyId `
        --params "$paramsJson" `
        --location "uksouth" | Out-Null

    Write-Host "Assigned: $assignmentName" -ForegroundColor Green
}

# -----------------------------
# Helper: Assign Initiative
# -----------------------------
function AssignInitiative {
    param(
        [string]$initiativeName,
        [string]$assignmentName
    )

    Write-Host "Assigning initiative: $initiativeName" -ForegroundColor Yellow

    $initiativeId = az policy set-definition show `
        --name $initiativeName `
        --management-group $mgId `
        --query "id" -o tsv

    if (-not $initiativeId) {
        Write-Host "ERROR: Initiative not found: $initiativeName" -ForegroundColor Red
        return
    }

    az policy assignment create `
        --name $assignmentName `
        --scope "/providers/Microsoft.Management/managementGroups/$mgId" `
        --policy-set-definition $initiativeId `
        --location "uksouth" | Out-Null

    Write-Host "Assigned initiative: $assignmentName" -ForegroundColor Green
}

# -----------------------------
# 1. Assign Tag Enforcement Policies
# -----------------------------
AssignPolicy -policyName $polTagEnv   -assignmentName "asg-require-tag-environment"
AssignPolicy -policyName $polTagOwner -assignmentName "asg-require-tag-owner"
AssignPolicy -policyName $polTagCost  -assignmentName "asg-require-tag-costcenter"

# -----------------------------
# 2. Assign Allowed Locations Policy
# -----------------------------
AssignPolicy `
    -policyName $polAllowedLoc `
    -assignmentName "asg-allowed-locations" `
    -parameters @{
        listOfAllowedLocations = @{
            value = @("uksouth", "ukwest")
        }
    }

# -----------------------------
# 3. Assign Allowed SKUs Policy
# -----------------------------
AssignPolicy `
    -policyName $polAllowedSku `
    -assignmentName "asg-allowed-skus" `
    -parameters @{
        listOfAllowedSKUs = @{
            value = @(
                "Standard_B2s",
                "Standard_B4ms",
                "Standard_DS1_v2",
                "Standard_DS2_v2"
            )
        }
    }

# -----------------------------
# 4. Assign Governance Initiative
# -----------------------------
AssignInitiative `
    -initiativeName $initiativeName `
    -assignmentName "asg-governance-baseline"

# -----------------------------
# Summary
# -----------------------------
Write-Host "`nPolicy assignment complete." -ForegroundColor Cyan
Write-Host "Assigned to Management Group: $mgId"
Write-Host "Initiative: $initiativeName"
Write-Host "Tag Policies: Environment, Owner, CostCenter"
Write-Host "Allowed Locations: uksouth, ukwest"
Write-Host "Allowed SKUs: B-series + DS-series"
