<#
    Project: Identity & Access Solutions (RBAC Model)
    Script: assign-rbac.ps1
    Purpose: Assign RBAC roles to Entra ID groups for Dev, Test, and Prod
             subscriptions using least-privilege access.
#>

# -----------------------------
# Subscription IDs (replace with your actual IDs)
# -----------------------------
$subDev  = "<DEV-SUBSCRIPTION-ID>"
$subTest = "<TEST-SUBSCRIPTION-ID>"
$subProd = "<PROD-SUBSCRIPTION-ID>"

# -----------------------------
# Group Display Names
# -----------------------------
$groups = @{
    "Dev-Readers"        = @{ Role = "Reader";      Subscription = $subDev }
    "Dev-Contributors"   = @{ Role = "Contributor"; Subscription = $subDev }

    "Test-Readers"       = @{ Role = "Reader";      Subscription = $subTest }
    "Test-Contributors"  = @{ Role = "Contributor"; Subscription = $subTest }

    "Prod-Readers"       = @{ Role = "Reader";      Subscription = $subProd }
    "Prod-Contributors"  = @{ Role = "Contributor"; Subscription = $subProd }

    # Break-glass only
    "Prod-Owners"        = @{ Role = "Owner";       Subscription = $subProd }
}

Write-Host "`nAssigning RBAC roles to Entra ID groups..." -ForegroundColor Cyan

# -----------------------------
# Resolve Group Object IDs
# -----------------------------
foreach ($groupName in $groups.Keys) {

    Write-Host "`nProcessing group: $groupName" -ForegroundColor Yellow

    $groupId = az ad group list `
        --filter "displayName eq '$groupName'" `
        --query "[0].id" -o tsv

    if (-not $groupId) {
        Write-Host "ERROR: Group not found in Entra ID: $groupName" -ForegroundColor Red
        continue
    }

    $role = $groups[$groupName].Role
    $subscription = $groups[$groupName].Subscription
    $scope = "/subscriptions/$subscription"

    Write-Host "Group ID: $groupId"
    Write-Host "Role: $role"
    Write-Host "Scope: $scope"

    # -----------------------------
    # Check if assignment already exists
    # -----------------------------
    $existing = az role assignment list `
        --assignee $groupId `
        --scope $scope `
        --query "[?roleDefinitionName=='$role']" -o tsv

    if ($existing) {
        Write-Host "RBAC already assigned → $groupName : $role" -ForegroundColor Green
        continue
    }

    # -----------------------------
    # Assign RBAC Role
    # -----------------------------
    Write-Host "Assigning role..." -ForegroundColor Cyan

    az role assignment create `
        --assignee $groupId `
        --role $role `
        --scope $scope | Out-Null

    Write-Host "Assigned: $groupName → $role" -ForegroundColor Green
}

Write-Host "`nRBAC assignment complete for all groups." -ForegroundColor Cyan
