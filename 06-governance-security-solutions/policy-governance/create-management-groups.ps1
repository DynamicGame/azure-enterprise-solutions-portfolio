<#
    Project: Governance & Compliance Solutions
    Script: create-management-groups.ps1
    Purpose: Create a CAF-aligned management group hierarchy:
             - Root
             - Corp (governance baseline)
             - Dev / Test / Prod
             Assign subscriptions to the correct groups.
#>

Write-Host "`nCreating Management Group hierarchy..." -ForegroundColor Cyan

# -----------------------------
# Variables
# -----------------------------
$rootMg = "Tenant Root Group"
$corpMg = "mg-corp"
$devMg  = "mg-dev"
$testMg = "mg-test"
$prodMg = "mg-prod"

# Replace with your actual subscription names
$subDevName  = "Subscription-Dev"
$subTestName = "Subscription-Test"
$subProdName = "Subscription-Prod"

# -----------------------------
# Helper: Create MG if missing
# -----------------------------
function EnsureMG {
    param(
        [string]$mgId,
        [string]$displayName,
        [string]$parentId
    )

    $exists = az account management-group show `
        --name $mgId `
        --query "name" -o tsv 2>$null

    if ($exists) {
        Write-Host "Management Group already exists: $mgId" -ForegroundColor Green
    }
    else {
        Write-Host "Creating Management Group: $mgId" -ForegroundColor Yellow
        az account management-group create `
            --name $mgId `
            --display-name $displayName `
            --parent $parentId | Out-Null
    }
}

# -----------------------------
# 1. Create Corp MG under Root
# -----------------------------
EnsureMG -mgId $corpMg -displayName "Corporate Governance" -parentId $rootMg

# -----------------------------
# 2. Create Dev/Test/Prod MGs
# -----------------------------
EnsureMG -mgId $devMg  -displayName "Development" -parentId $corpMg
EnsureMG -mgId $testMg -displayName "Testing"     -parentId $corpMg
EnsureMG -mgId $prodMg -displayName "Production"  -parentId $corpMg

# -----------------------------
# 3. Assign Subscriptions
# -----------------------------
Write-Host "`nAssigning subscriptions to Management Groups..." -ForegroundColor Cyan

function AssignSubscription {
    param(
        [string]$subName,
        [string]$mgId
    )

    $subId = az account list --query "[?name=='$subName'].id" -o tsv

    if (-not $subId) {
        Write-Host "Subscription not found: $subName" -ForegroundColor Red
        return
    }

    Write-Host "Assigning $subName → $mgId" -ForegroundColor Yellow

    az account management-group subscription add `
        --name $mgId `
        --subscription $subId 2>$null
}

AssignSubscription -subName $subDevName  -mgId $devMg
AssignSubscription -subName $subTestName -mgId $testMg
AssignSubscription -subName $subProdName -mgId $prodMg

# -----------------------------
# 4. Output Hierarchy
# -----------------------------
Write-Host "`nManagement Group hierarchy:" -ForegroundColor Cyan

az account management-group list `
    --query "[].{Name:name, DisplayName:displayName, Parent:parentName}" `
    -o table

Write-Host "`nManagement Group setup complete." -ForegroundColor Green
