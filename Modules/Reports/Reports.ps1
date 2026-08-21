###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Reports.ps1
# Purpose    : Displays the WRTE Reports tools menu.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays the WRTE Reports menu.

.DESCRIPTION
Provides access to WRTE report generation and report management
tools.

.EXAMPLE
Show-Reports

.NOTES
Primary entry point for the Reports module.
#>

function Show-Reports {

    [CmdletBinding()]
    param()

    while ($true) {

        Show-Banner
        Show-Section "Reports"

        Write-MenuItem "1" "System Report"
        Write-MenuItem "2" "Diagnostic Report"
        Write-MenuItem "3" "Export Latest Report"
        Write-MenuItem "4" "Open Reports Folder"
        Write-MenuItem "B" "Back"

        Show-Footer

        $Selection =
            (Read-Host "Select an option").Trim().ToUpper()

        switch ($Selection) {

            "1" {
                New-WRTESystemReport
            }

            "2" {
                New-WRTEDiagnosticReport
            }

            "3" {
                Export-LatestWRTEReport
            }

            "4" {

                $ReportPath = Get-WRTEReportPath

                Start-Process `
                    -FilePath $ReportPath
            }

            "B" {
                return
            }

            default {

                Write-WRTEWarning "Invalid selection."
                Wait-WRTE

            }
        }
    }
}