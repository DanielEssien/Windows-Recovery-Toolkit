###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Utilities.ps1
# Purpose    : Displays the WRTE Utilities tools menu.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays the WRTE Utilities menu.

.DESCRIPTION
Provides access to general-purpose Windows support utilities,
including environment information, process and service lookup,
and common administrative tools.

.EXAMPLE
Show-Utilities

.NOTES
Primary entry point for the Utilities module.
#>

function Show-Utilities {

    [CmdletBinding()]
    param()

    while ($true) {

        Show-Banner
        Show-Section "Utilities"

        Write-MenuItem "1" "Environment Information"
        Write-MenuItem "2" "Process Lookup"
        Write-MenuItem "3" "Service Lookup"
        Write-MenuItem "4" "Administrative Tools"
        Write-MenuItem "5" "Device Manager"
        Write-MenuItem "6" "Event Viewer"
        Write-MenuItem "B" "Back"

        Show-Footer

        $Selection =
            (Read-Host "Select an option").Trim().ToUpper()

        switch ($Selection) {

            "1" { Show-EnvironmentInformation }
            "2" { Find-WRTEProcess }
            "3" { Find-WRTEService }
            "4" { Open-WRTEAdministrativeTools }
            "5" { Open-WRTEDeviceManager }
            "6" { Open-WRTEEventViewer }

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