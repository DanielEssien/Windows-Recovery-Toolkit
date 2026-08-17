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

            "1" {

                Show-Diagnostics

            }

            "2" {

                Write-WRTEWarning "Windows Repair module not implemented yet."
                Wait-WRTE

            }

            "3" { 
    
                Show-Hardware 
                
            }

            "4" {

                Show-Network

            }

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