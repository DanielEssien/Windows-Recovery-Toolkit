###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Core
# File       : Application.ps1
# Purpose    : Controls the WRTE application lifecycle.
#
###############################################################

function Start-Application {

    [CmdletBinding()]
    param()

    Write-Log "Application started."

    $ExitApplication = $false

    do {

        Show-Dashboard

        $Selection = (Read-Host "Select an option").Trim().ToUpper()

        switch ($Selection) {

            "1" { Show-Diagnostics }

            "2" { Show-WindowsRepair }

            "3" { Show-Hardware }

            "4" { Show-Network }

            "5" { Show-Security }

            "6" { Show-Maintenance }

            "Q" {

                Write-Log "Application closed."

                $ExitApplication = $true

            }

            default {

                Write-WRTEWarning "Invalid selection."

                Wait-WRTE

            }

        }

    } while (-not $ExitApplication)

}