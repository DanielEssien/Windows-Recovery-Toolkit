###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Diagnostics.ps1
# Purpose    : Displays the Diagnostics menu.
#
###############################################################

<#
.SYNOPSIS
Displays the Diagnostics menu.

.DESCRIPTION
Provides access to diagnostic tools.

.EXAMPLE
Show-Diagnostics
#>

function Show-Diagnostics {

    [CmdletBinding()]
    param()

    do  {

        Show-Banner

        Show-Section "Diagnostics"

        Write-MenuItem "1" "Quick Health Check"
        Write-MenuItem "2" "System File Checker (SFC)"
        Write-MenuItem "3" "DISM Scan"
        Write-MenuItem "4" "DISM Restore"
        Write-MenuItem "5" "Disk Check"
        Write-MenuItem "6" "Memory Test"
        Write-MenuItem "7" "Recovery Information"

        Write-Host ""

        Write-MenuItem "B" "Back"

        Show-Footer

        $Selection = (Read-Host "Select an option").Trim().ToUpper()

        switch ($Selection) {

            "1" { Start-QuickHealth }

            "2" { Start-SFC }

            "3" { Start-DISMScan }

            "4" { Start-DISMRestore }

            "5" { Start-DiskCheck }

            "6" { Start-MemoryTest }

            "7" { Show-RecoveryInformation }

            "B" { return }

            default {

                Write-WRTEWarning "Invalid selection."

                Wait-WRTE

            }

        }

    }
    while ($true)

}