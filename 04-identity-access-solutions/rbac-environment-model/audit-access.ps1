<#
    Project: Identity & Access Solutions (RBAC Model)
    Script: audit-access.ps1
    Purpose: Audit RBAC assignments across Dev/Test/Prod subscriptions,
             detect violations, and produce a compliance report.
#>

# -----------------------------
# Subscription IDs (replace with your actual IDs)
# -----------------------------
$subDev  = "<DEV-SUBSCRIPTION-ID>"
$subTest = "<TEST-SUBSCRIPTION-ID>"
$subProd = "<PROD-SUBSCRIPTION-ID>"

$subscriptions = @(
    @{ Name = "Dev";  Id = $subDev }
    @{ Name = "Test"; Id = $subTest }
    @{ Name = "Prod"; Id = $subProd }
)

Write-Host "`nStarting RBAC audit..." -ForegroundColor Cyan

# -----------------------------
# Helper: Check if principal is a user
# -----------------------------
function IsUser($principalId) {
    $type = az ad user show --id $principalId --query "id" -o tsv 2>$null
    return [bool]$type
}

# -----------------------------
# Helper: Check if principal is a group
# -----------------------------
function IsGroup($principalId) {
    $type = az ad group show --group $principalId --query "id" -o tsv 2>$null
    return [bool]$type
}

# -----------------------------
# Results Arrays
# -----------------------------
$directUserAssignments = @()
$overPrivilegedProd = @()
$unknownPrincipals = @()

# -----------------------------
# Audit Each Subscription
# -----------------------------
foreach ($sub in $subscriptions) {

    Write-Host "`nAuditing subscription: $($sub.Name)" -ForegroundColor Yellow

    $assignments = az role assignment list `
        --scope "/subscriptions/$($sub.Id)" `
        --query "[].{PrincipalId:principalId, Role:roleDefinitionName, Scope:scope}" `
        -o json | ConvertFrom-Json

    foreach ($a in $assignments) {

        $principalId = $a.PrincipalId
        $role        = $a.Role
        $scope       = $a.Scope

        # -----------------------------
        # Detect direct user assignments (violation)
        # -----------------------------
        if (IsUser $principalId) {
            $directUserAssignments += [pscustomobject]@{
                Subscription = $sub.Name
                PrincipalId  = $principalId
                Role         = $role
                Scope        = $scope
            }
            continue
        }

        # -----------------------------
        # Detect unknown principals
        # -----------------------------
        if (-not (IsGroup $principalId)) {
            $unknownPrincipals += [pscustomobject]@{
                Subscription = $sub.Name
                PrincipalId  = $principalId
                Role         = $role
                Scope        = $scope
            }
            continue
        }

        # -----------------------------
        # Detect over-privileged roles in Prod
        # -----------------------------
        if ($sub.Name -eq "Prod" -and ($role -eq "Contributor" -or $role -eq "Owner")) {
            $overPrivilegedProd += [pscustomobject]@{
                PrincipalId = $principalId
                Role        = $role
                Scope       = $scope
            }
        }
    }
}

# -----------------------------
# Output Results
# -----------------------------
Write-Host "`n==================== RBAC AUDIT REPORT ====================" -ForegroundColor Cyan

Write-Host "`n🔴 Direct User Assignments (Violations):" -ForegroundColor Red
if ($directUserAssignments.Count -eq 0) {
    Write-Host "None detected."
} else {
    $directUserAssignments | Format-Table -AutoSize
}

Write-Host "`n🟠 Over-Privileged Roles in PROD:" -ForegroundColor DarkYellow
if ($overPrivilegedProd.Count -eq 0) {
    Write-Host "None detected."
} else {
    $overPrivilegedProd | Format-Table -AutoSize
}

Write-Host "`n⚠️ Unknown Principals (Service Principals or Orphaned IDs):" -ForegroundColor Yellow
if ($unknownPrincipals.Count -eq 0) {
    Write-Host "None detected."
} else {
    $unknownPrincipals | Format-Table -AutoSize
}

Write-Host "`n============================================================" -ForegroundColor Cyan

Write-Host "`nRBAC audit complete." -ForegroundColor Green
