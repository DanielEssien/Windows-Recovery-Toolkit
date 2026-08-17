###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Maintenance.ps1
# Purpose    : Displays system maintenance tools.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays the Maintenance menu.

.DESCRIPTION
Provides access to system cleanup, update status,
disk maintenance, and uptime information.

.EXAMPLE
Show-Maintenance

.OUTPUTS
None
#>

function Show-Maintenance {

    [CmdletBinding()]
    param()

    do {

        Show-Banner
        Show-Section "Maintenance"

        Write-MenuItem "1" "Temporary Files Cleanup"
        Write-MenuItem "2" "Windows Update Status"
        Write-MenuItem "3" "Disk Cleanup"
        Write-MenuItem "4" "System Uptime"

        Write-BlankLine
        Write-MenuItem "B" "Back"

        Show-Footer

        $Selection = (Read-Host "Select an option").Trim().ToUpper()

        switch ($Selection) {

            "1" { Start-TempCleanup }

            "2" {
                Write-WRTEWarning "Windows Update Status is not implemented yet."
                Wait-WRTE
            }

            "3" {
                Write-WRTEWarning "Disk Cleanup is not implemented yet."
                Wait-WRTE
            }

            "4" {
                Write-WRTEWarning "System Uptime is not implemented yet."
                Wait-WRTE
            }

            "B" { return }

            default {
                Write-WRTEWarning "Invalid selection."
                Wait-WRTE
            }
        }

    } while ($true)
}