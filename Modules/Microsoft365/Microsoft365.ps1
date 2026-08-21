# Microsoft365.ps1

###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Microsoft365.ps1
# Purpose    : Displays the WRTE Microsoft 365 tools menu.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays the WRTE Microsoft 365 menu.

.DESCRIPTION
Provides access to Microsoft 365 diagnostics and support tools,
including installation status, activation information, Outlook,
Teams, and Office update channel details.

.EXAMPLE
Show-Microsoft365

.NOTES
Primary entry point for the Microsoft 365 module.
#>

function Show-Microsoft365 {

    [CmdletBinding()]
    param()

    while ($true) {

        Show-Banner
        Show-Section "Microsoft 365"

        Write-MenuItem "1" "Overview"
        Write-MenuItem "2" "Office Installation"
        Write-MenuItem "3" "Activation"
        Write-MenuItem "4" "Outlook"
        Write-MenuItem "5" "Teams"
        Write-MenuItem "6" "Update Channel"
        Write-MenuItem "B" "Back"

        Show-Footer

        $Selection = (Read-Host "Select an option").Trim().ToUpper()

        switch ($Selection) {

            "1" { Show-Microsoft365Overview }
            "2" { Show-OfficeInstallStatus }
            "3" { Show-OfficeActivationStatus }
            "4" { Show-OutlookStatus }
            "5" { Show-TeamsStatus }
            "6" { Show-OfficeUpdateChannel }

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
