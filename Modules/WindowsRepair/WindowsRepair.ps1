###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : WindowsRepair.ps1
# Purpose    : Displays Windows repair and recovery tools.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays the Windows Repair menu.

.DESCRIPTION
Provides access to Windows system repair, network reset,
Windows Update repair, and recovery tools.

.EXAMPLE
Show-WindowsRepair

.OUTPUTS
None

.NOTES
Supports DryRun mode for safe simulation of repair actions.
Some repair operations require administrator privileges
and may require a system restart.
#>

function Show-WindowsRepair {

    [CmdletBinding()]
    param()

    do {

        Show-Banner
        Show-Section "Windows Repair"

        $Config = Get-Configuration
        $DryRun = $Config.WindowsRepair.DryRun

        if ($DryRun) {

            Write-WRTEWarning "Windows Repair is running in DRY-RUN mode."
            Write-Info "Repair actions will be simulated and no system changes will be made."

            Write-BlankLine
        }

        Write-MenuItem "1" "Repair System Files"
        Write-MenuItem "2" "Repair Windows Image"
        Write-MenuItem "3" "Reset Network Stack"
        Write-MenuItem "4" "Repair Windows Update Components"
        Write-MenuItem "5" "Open Advanced Recovery"

        Write-BlankLine
        Write-MenuItem "B" "Back"

        Show-Footer

        $Selection = (Read-Host "Select an option").Trim().ToUpper()

        switch ($Selection) {

            "1" { Start-SystemFileRepair }

            "2" { Start-WindowsImageRepair }

            "3" { Start-NetworkStackReset }

            "4" { Start-WindowsUpdateRepair }

            "5" { Open-AdvancedRecovery }

            "B" { return }

            default {
                Write-WRTEWarning "Invalid selection."
                Wait-WRTE
            }
        }

    } while ($true)
}