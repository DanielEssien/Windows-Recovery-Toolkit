###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : Run-Tests.ps1
# Purpose    : Runs the WRTE automated Pester test suite.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$TestsRoot =
    $PSScriptRoot

$ProjectRoot =
    Split-Path `
        -Parent `
        $TestsRoot

Write-Host ""
Write-Host "============================================================"
Write-Host " WRTE Automated Test Suite"
Write-Host "============================================================"
Write-Host ""

Write-Host "Project Root : $ProjectRoot"
Write-Host "Tests Root   : $TestsRoot"
Write-Host ""

try {

    Import-Module `
        Pester `
        -MinimumVersion 6.0 `
        -Force `
        -ErrorAction Stop
}
catch {

    Write-Host `
        "ERROR: Pester 6.0 or later is required." `
        -ForegroundColor Red

    Write-Host `
        "Details: $($_.Exception.Message)" `
        -ForegroundColor Red

    exit 1
}

$PesterModule =
    Get-Module Pester

Write-Host `
    "Pester Version : $($PesterModule.Version)" `
    -ForegroundColor Cyan

Write-Host ""

$Configuration =
    New-PesterConfiguration

$Configuration.Run.Path =
    $TestsRoot

$Configuration.Run.PassThru =
    $true

$Configuration.Output.Verbosity =
    "Detailed"

$Configuration.TestResult.Enabled =
    $false

Write-Host "Running WRTE tests..."
Write-Host ""

$Result =
    Invoke-Pester `
        -Configuration $Configuration

Write-Host ""

if ($Result.FailedCount -eq 0) {

    Write-Host `
        "PASS: All WRTE tests passed." `
        -ForegroundColor Green

    exit 0
}
else {

    Write-Host `
        "FAIL: $($Result.FailedCount) WRTE test(s) failed." `
        -ForegroundColor Red

    exit 1
}