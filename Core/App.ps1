###############################################################
# Application Engine
###############################################################

function Start-Application {

    while ($true) {

        Show-Dashboard

        $Selection = Read-Host "Select an option"

        switch ($Selection.ToUpper()) {

            "1" {

                Invoke-QuickHealthCheck

            }

            "Q" {

                Write-Log "Application Closed"

                break

            }

            default {

                Write-WarningMessage "Invalid menu selection."

                Wait-Toolkit

            }

        }

    }

}