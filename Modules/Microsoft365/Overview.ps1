# Overview.ps1

###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Overview.ps1
# Purpose    : Displays an overview of Microsoft 365 status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays a Microsoft 365 overview.

.DESCRIPTION
Retrieves basic Microsoft 365 and Office installation information
for the local computer, including detected Office applications
and Click-to-Run configuration.

.EXAMPLE
Show-Microsoft365Overview

.OUTPUTS
None

.NOTES
This function is read-only.
#>

function Show-Microsoft365Overview {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Microsoft 365 Overview"

    Write-Info "Collecting Microsoft 365 information..."

    try {

        $ClickToRunPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"

        if (Test-Path $ClickToRunPath) {

            $OfficeConfig = Get-ItemProperty `
                -Path $ClickToRunPath `
                -ErrorAction Stop

            Write-Property "Office Installed" "Yes"

            if ($OfficeConfig.ProductReleaseIds) {
                Write-Property "Product" $OfficeConfig.ProductReleaseIds
            }

            $OfficeVersion = if ($OfficeConfig.VersionToReport) {

                $OfficeConfig.VersionToReport

            }
            elseif ($OfficeConfig.ClientVersionToReport) {

                $OfficeConfig.ClientVersionToReport

            }
            else {

                $null

            }

            if ($OfficeVersion) {

                Write-Property "Version" $OfficeVersion

            }

            if ($OfficeConfig.Platform) {
                Write-Property "Architecture" $OfficeConfig.Platform
            }

            if ($OfficeConfig.UpdateChannel) {
                Write-Property "Update Channel" $OfficeConfig.UpdateChannel
            }

        }
        else {

            Write-Property "Office Installed" "Not detected"
        }

        #------------------------------------------------------
        # Outlook
        #------------------------------------------------------

        $OutlookPaths = @(
            "$env:ProgramFiles\Microsoft Office\root\Office16\OUTLOOK.EXE",
            "${env:ProgramFiles(x86)}\Microsoft Office\root\Office16\OUTLOOK.EXE",
            "$env:ProgramFiles\Microsoft Office\Office16\OUTLOOK.EXE",
            "${env:ProgramFiles(x86)}\Microsoft Office\Office16\OUTLOOK.EXE",
            "$env:ProgramFiles\Microsoft Office\Office15\OUTLOOK.EXE",
            "${env:ProgramFiles(x86)}\Microsoft Office\Office15\OUTLOOK.EXE"
        )

        $OutlookInstalled = $OutlookPaths |
            Where-Object { Test-Path $_ } |
            Select-Object -First 1

        if ($OutlookInstalled) {
            Write-Property "Outlook" "Installed"
        }
        else {
            Write-Property "Outlook" "Not detected"
        }

        #------------------------------------------------------
        # Teams
        #------------------------------------------------------

        $TeamsDetected = $false

        $TeamsPackages = @(
            Get-AppxPackage `
                -Name "MSTeams" `
                -ErrorAction SilentlyContinue
        )

        if ($TeamsPackages.Count -gt 0) {

            Write-Property "Microsoft Teams" "Installed"

        }
        else {

            Write-Property "Microsoft Teams" "Not detected"

        }

        if ($TeamsDetected) {
            Write-Property "Microsoft Teams" "Installed"
        }
        else {
            Write-Property "Microsoft Teams" "Not detected"
        }

        Write-Log "Microsoft 365 overview completed." -Level INFO

    }
    catch {

        Write-WRTEWarning "Unable to collect Microsoft 365 information."

        Write-Log `
            ("Microsoft 365 overview failed: {0}" -f $_.Exception.Message) `
            -Level ERROR
    }

    Show-Footer
    Wait-WRTE
}