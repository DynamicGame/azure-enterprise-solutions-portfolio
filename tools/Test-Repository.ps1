#requires -Version 7.0
[CmdletBinding()]
param([string]$RepositoryRoot = (Split-Path $PSScriptRoot))
$ErrorActionPreference = 'Stop'
$failures = [Collections.Generic.List[string]]::new()
$files = @(Get-ChildItem -LiteralPath $RepositoryRoot -Recurse -File | Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' })
$scripts = @($files | Where-Object Extension -eq '.ps1')
foreach ($file in $scripts) {
    $tokens = $null; $parseErrors = $null
    [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors) | Out-Null
    foreach ($parseError in $parseErrors) { $failures.Add("$($file.FullName): $($parseError.Message)") }
}
$jsonFiles = @($files | Where-Object Extension -eq '.json')
foreach ($file in $jsonFiles) {
    try { Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json -Depth 100 | Out-Null }
    catch { $failures.Add("$($file.FullName): invalid JSON: $_") }
}
$markdownFiles = @($files | Where-Object Extension -eq '.md')
foreach ($file in $markdownFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($match in [regex]::Matches($text, '\]\(([^)]+)\)')) {
        $target = $match.Groups[1].Value
        if ($target -match '^(https?://|mailto:|#)') { continue }
        $target = [Uri]::UnescapeDataString(($target -split '#')[0])
        if (-not (Test-Path -LiteralPath (Join-Path $file.DirectoryName $target))) {
            $failures.Add("$($file.FullName): broken local link: $target")
        }
    }
}
if ($failures.Count) { $failures | Write-Output; throw "$($failures.Count) repository check(s) failed." }
Write-Host "PASS: $($scripts.Count) PowerShell files parsed, $($jsonFiles.Count) JSON files parsed, local links checked in $($markdownFiles.Count) Markdown files."
Write-Host 'Offline checks only: no Azure command was executed and no deployment is certified.'
