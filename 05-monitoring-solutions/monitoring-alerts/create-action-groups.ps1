<#
    Project: Monitoring & Alerting Solutions
    Script: create-action-groups.ps1
    Purpose: Create Azure Monitor Action Groups for email, SMS,
             and webhook notifications.
#>

# -----------------------------
# Variables
# -----------------------------
$rgName        = "rg-monitoring"
$location      = "uksouth"

# Action Group Names
$agEmail       = "ag-email-alerts"
$agOps         = "ag-ops-webhook"

# Receivers
$emailAddress  = "alerts@example.com"      # Replace with your email
$phoneNumber   = "+447000000000"           # Optional SMS
$webhookUrl    = ""                        # Optional Teams/Slack webhook

Write-Host "`nCreating Azure Monitor Action Groups..." -ForegroundColor Cyan

# -----------------------------
# Helper: Check if Action Group Exists
# -----------------------------
function ActionGroupExists($name) {
    $exists = az monitor action-group show `
        --name $name `
        --resource-group $rgName `
        --query "name" -o tsv 2>$null
    return [bool]$exists
}

# -----------------------------
# 1. Create Email Action Group
# -----------------------------
Write-Host "`nProcessing Email Action Group: $agEmail" -ForegroundColor Yellow

if (ActionGroupExists $agEmail) {
    Write-Host "Action Group already exists: $agEmail" -ForegroundColor Green
} else {
    Write-Host "Creating Action Group: $agEmail" -ForegroundColor Cyan

    az monitor action-group create `
        --name $agEmail `
        --resource-group $rgName `
        --short-name "emailAG" `
        --location $location `
        --action email adminAlerts $emailAddress | Out-Null

    Write-Host "Created: $agEmail" -ForegroundColor Green
}

# -----------------------------
# 2. Create Webhook / Ops Action Group
# -----------------------------
Write-Host "`nProcessing Ops/Webhook Action Group: $agOps" -ForegroundColor Yellow

if (ActionGroupExists $agOps) {
    Write-Host "Action Group already exists: $agOps" -ForegroundColor Green
} else {
    Write-Host "Creating Action Group: $agOps" -ForegroundColor Cyan

    $params = @(
        "--name", $agOps,
        "--resource-group", $rgName,
        "--short-name", "opsAG",
        "--location", $location
    )

    if ($webhookUrl -ne "") {
        $params += @("--action", "webhook", "opsWebhook", $webhookUrl)
    }

    if ($phoneNumber -ne "") {
        $params += @("--action", "sms", "opsSMS", "UK", $phoneNumber)
    }

    az monitor action-group create @params | Out-Null

    Write-Host "Created: $agOps" -ForegroundColor Green
}

# -----------------------------
# Summary
# -----------------------------
Write-Host "`nAction Groups created successfully." -ForegroundColor Cyan

Write-Host "`nUse these Action Groups in create-alerts.ps1:" -ForegroundColor Yellow
Write-Host " - $agEmail"
Write-Host " - $agOps"
