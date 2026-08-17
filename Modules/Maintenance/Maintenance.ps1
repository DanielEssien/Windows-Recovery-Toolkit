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
Provides access to temporary file cleanup, Windows Update status,
Disk Cleanup, and system uptime information.

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

            "2" { Show-WindowsUpdateStatus }

            "3" { Start-DiskCleanup }

            "4" { Show-SystemUptime }

            "B" { return }

            default {
                Write-WRTEWarning "Invalid selection."
                Wait-WRTE
            }
        }

    } while ($true)
}