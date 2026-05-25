<#
    Project: Monitoring & Alerting Solutions
    Script: create-dashboard.ps1
    Purpose: Create an Azure Portal dashboard showing VM performance,
             Storage metrics, and Alerts overview.
#>

# -----------------------------
# Variables
# -----------------------------
$rgName     = "rg-monitoring"
$location   = "uksouth"
$dashName   = "dash-monitoring-overview"
$subId      = az account show --query id -o tsv

Write-Host "`nCreating Azure Monitor dashboard..." -ForegroundColor Cyan

# -----------------------------
# Dashboard JSON Definition
# -----------------------------
$dashboard = @{
    "$schema" = "https://schema.management.azure.com/schemas/2019-08-01/portalDashboard.json#"
    "contentVersion" = "1.0.0.0"
    "parameters" = @{}
    "resources" = @(
        @{
            "type" = "Microsoft.Portal/dashboards"
            "name" = $dashName
            "location" = $location
            "apiVersion" = "2020-09-01-preview"
            "properties" = @{
                "lenses" = @{
                    "0" = @{
                        "order" = 0
                        "parts" = @(
                            # VM Metrics Tile
                            @{
                                "position" = @{
                                    "x" = 0; "y" = 0; "rowSpan" = 6; "colSpan" = 6
                                }
                                "metadata" = @{
                                    "type" = "Extension/HubsExtension/PartType/MonitorChartPart"
                                    "inputs" = @(
                                        @{
                                            "name" = "options"
                                            "value" = @{
                                                "chart" = @{
                                                    "title" = "VM CPU & Memory"
                                                    "metrics" = @(
                                                        @{
                                                            "resourceMetadata" = @{
                                                                "subscriptionId" = $subId
                                                            }
                                                            "name" = "Percentage CPU"
                                                            "aggregationType" = 4
                                                        }
                                                    )
                                                    "timeRange" = @{
                                                        "durationMs" = 3600000
                                                    }
                                                }
                                            }
                                        }
                                    )
                                }
                            },
                            # Storage Metrics Tile
                            @{
                                "position" = @{
                                    "x" = 6; "y" = 0; "rowSpan" = 6; "colSpan" = 6
                                }
                                "metadata" = @{
                                    "type" = "Extension/HubsExtension/PartType/MonitorChartPart"
                                    "inputs" = @(
                                        @{
                                            "name" = "options"
                                            "value" = @{
                                                "chart" = @{
                                                    "title" = "Storage Transactions & Capacity"
                                                    "metrics" = @(
                                                        @{
                                                            "resourceMetadata" = @{
                                                                "subscriptionId" = $subId
                                                            }
                                                            "name" = "Transactions"
                                                            "aggregationType" = 4
                                                        }
                                                    )
                                                    "timeRange" = @{
                                                        "durationMs" = 3600000
                                                    }
                                                }
                                            }
                                        }
                                    )
                                }
                            },
                            # Alerts Summary Tile
                            @{
                                "position" = @{
                                    "x" = 0; "y" = 6; "rowSpan" = 6; "colSpan" = 12
                                }
                                "metadata" = @{
                                    "type" = "Extension/HubsExtension/PartType/AlertsSummaryPart"
                                    "inputs" = @(
                                        @{
                                            "name" = "scope"
                                            "value" = @("/subscriptions/$subId")
                                        }
                                    )
                                }
                            }
                        )
                    }
                }
                "metadata" = @{
                    "model" = @{
                        "timeRange" = @{
                            "value" = @{
                                "relative" = @{
                                    "duration" = 3600000
                                }
                            }
                            "type" = "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
                        }
                    }
                }
            }
        }
    )
} | ConvertTo-Json -Depth 10

# -----------------------------
# Write JSON to temp file
# -----------------------------
$tempFile = New-TemporaryFile
$dashboard | Out-File -FilePath $tempFile -Encoding utf8

# -----------------------------
# Deploy Dashboard
# -----------------------------
az deployment group create `
    --resource-group $rgName `
    --template-file $tempFile | Out-Null

Remove-Item $tempFile -Force

Write-Host "`nDashboard created successfully." -ForegroundColor Green
Write-Host "Dashboard name: $dashName"
Write-Host "Resource group: $rgName"
Write-Host "Open in Portal → Dashboards → $dashName"
