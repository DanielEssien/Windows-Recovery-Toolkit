###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Hardware.ps1
# Purpose    : Displays hardware diagnostic and information tools.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays the Hardware menu.

.DESCRIPTION
Provides access to hardware information and diagnostic tools.

.EXAMPLE
Show-Hardware

.OUTPUTS
None
#>

function Show-Hardware {

    [CmdletBinding()]
    param()

    do {

        Show-Banner
        Show-Section "Hardware"

        Write-MenuItem "1" "System Hardware Overview"
        Write-MenuItem "2" "Storage Devices"
        Write-MenuItem "3" "Battery Information"
        Write-MenuItem "4" "BIOS Information"

        Write-BlankLine
        Write-MenuItem "B" "Back"

        Show-Footer

        $Selection = (Read-Host "Select an option").Trim().ToUpper()

        switch ($Selection) {

            "1" { Show-HardwareOverview }

            "2" { Show-StorageDevices }

            "3" { Show-BatteryInformation }

            "4" { Show-BIOSInformation }

            "B" { return }

            default {
                Write-WRTEWarning "Invalid selection."
                Wait-WRTE
            }
        }

    } while ($true)
}