###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Network.ps1
# Purpose    : Displays network diagnostic and information tools.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays the Network menu.

.DESCRIPTION
Provides access to network information and diagnostic tools.

.EXAMPLE
Show-Network

.OUTPUTS
None
#>

function Show-Network {

    [CmdletBinding()]
    param()

    do {

        Show-Banner
        Show-Section "Network"

        Write-MenuItem "1" "Network Overview"
        Write-MenuItem "2" "Adapter Information"
        Write-MenuItem "3" "Connectivity Test"
        Write-MenuItem "4" "DNS Information"

        Write-BlankLine
        Write-MenuItem "B" "Back"

        Show-Footer

        $Selection = (Read-Host "Select an option").Trim().ToUpper()

        switch ($Selection) {

            "1" { Show-NetworkOverview }

            "2" { Show-AdapterInformation }

            "3" { Start-ConnectivityTest }

            "4" { Show-DNSInformation }

            "B" { return }

            default {
                Write-WRTEWarning "Invalid selection."
                Wait-WRTE
            }
        }

    } while ($true)
}