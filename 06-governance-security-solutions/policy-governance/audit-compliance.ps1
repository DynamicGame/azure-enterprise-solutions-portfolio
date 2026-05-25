<#
    Project: Governance & Compliance Solutions
    Script: audit-compliance.ps1
    Purpose: Audit Azure governance compliance:
             - Policy compliance
             - Missing tags
             - Location violations
             - SKU violations
             - Lock coverage
             - Initiative compliance
#>

Write-Host "`nRunning Governance Compliance Audit..." -ForegroundColor Cyan

# -----------------------------
# Variables
# -----------------------------
$mgId = "mg-corp"
$requiredTags = @("Environment", "Owner", "CostCenter")

# -----------------------------
# 1. Policy Compliance Summary
# -----------------------------
Write-Host "`n=== POLICY COMPLIANCE SUMMARY ===" -ForegroundColor Yellow

$policyStates = az policy state summarize `
    --management-group $mgId `
    -o json | ConvertFrom-Json

$nonCompliantCount = $policyStates.summary.nonCompliantResources
$compliantCount    = $policyStates.summary.compliantResources

Write-Host "Compliant Resources:     $compliantCount"
Write-Host "Non-Compliant Resources: $nonCompliantCount"

# -----------------------------
# 2. List Non-Compliant Resources
# -----------------------------
Write-Host "`n=== NON-COMPLIANT RESOURCES ===" -ForegroundColor Yellow

$nonCompliant = az policy state list `
    --management-group $mgId `
    --filter "complianceState eq 'NonCompliant'" `
    -o json | ConvertFrom-Json

foreach ($item in $nonCompliant) {
    Write-Host "Resource: $($item.resourceId)" -ForegroundColor Cyan
    Write-Host "Policy:   $($item.policyDefinitionName)"
    Write-Host "Reason:   $($item.complianceReason)"
    Write-Host ""
}

# -----------------------------
# 3. Missing Tag Audit
# -----------------------------
Write-Host "`n=== MISSING TAGS AUDIT ===" -ForegroundColor Yellow

$allResources = az resource list -o json | ConvertFrom-Json

foreach ($res in $allResources) {

    foreach ($tag in $requiredTags) {

        if (-not $res.tags.ContainsKey($tag)) {
            Write-Host "Missing Tag: $tag → $($res.id)" -ForegroundColor Red
        }
    }
}

# -----------------------------
# 4. Location Violations
# -----------------------------
Write-Host "`n=== LOCATION VIOLATIONS ===" -ForegroundColor Yellow

$allowedLocations = @("uksouth", "ukwest")

foreach ($res in $allResources) {

    if ($res.location -and ($allowedLocations -notcontains $res.location)) {
        Write-Host "Invalid Location: $($res.location) → $($res.id)" -ForegroundColor Red
    }
}

# -----------------------------
# 5. SKU Violations
# -----------------------------
Write-Host "`n=== SKU VIOLATIONS ===" -ForegroundColor Yellow

$allowedSkus = @(
    "Standard_B2s",
    "Standard_B4ms",
    "Standard_DS1_v2",
    "Standard_DS2_v2"
)

$vms = az vm list -o json | ConvertFrom-Json

foreach ($vm in $vms) {

    $sku = $vm.hardwareProfile.vmSize

    if ($allowedSkus -notcontains $sku) {
        Write-Host "Invalid VM SKU: $sku → $($vm.id)" -ForegroundColor Red
    }
}

# -----------------------------
# 6. Lock Coverage Audit
# -----------------------------
Write-Host "`n=== LOCK COVERAGE AUDIT ===" -ForegroundColor Yellow

$locks = az lock list -o json | ConvertFrom-Json

$criticalResources = az resource list `
    --tag "Critical=True" `
    -o json | ConvertFrom-Json

foreach ($res in $criticalResources) {

    $hasLock = $locks | Where-Object { $_.scope -eq $res.id }

    if (-not $hasLock) {
        Write-Host "Missing Lock: Critical resource not protected → $($res.id)" -ForegroundColor Red
    }
}

# -----------------------------
# 7. Initiative Compliance
# -----------------------------
Write-Host "`n=== INITIATIVE COMPLIANCE ===" -ForegroundColor Yellow

$initiativeName = "Governance-Baseline"

$initiative = az policy set-definition show `
    --name $initiativeName `
    --management-group $mgId `
    -o json | ConvertFrom-Json

if ($initiative) {
    Write-Host "Initiative Found: $initiativeName" -ForegroundColor Green
    Write-Host "Policies Included: $($initiative.policyDefinitions.count)"
} else {
    Write-Host "Initiative Missing: $initiativeName" -ForegroundColor Red
}

# -----------------------------
# Summary
# -----------------------------
Write-Host "`n=== GOVERNANCE AUDIT COMPLETE ===" -ForegroundColor Cyan
Write-Host "Review non-compliant resources and remediate as needed."
Write-Host "Use cleanup-governance.ps1 to remove governance objects if required."
