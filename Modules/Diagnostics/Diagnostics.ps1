###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Diagnostics.ps1
# Purpose    : Displays the Diagnostics menu.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
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

    do {

        Show-Banner

        Show-Section "Diagnostics"

        Write-MenuItem "1" "Quick Health Check"
        Write-MenuItem "2" "System File Checker (SFC)"
        Write-MenuItem "3" "DISM Scan"
        Write-MenuItem "4" "DISM Restore"
        Write-MenuItem "5" "Disk Check"
        Write-MenuItem "6" "Memory Test"
        Write-MenuItem "7" "Recovery Information"
        Write-MenuItem "8" "Event Log Diagnostics"
        Write-MenuItem "9" "Crash & BSOD Diagnostics"
        Write-MenuItem "10" "Startup Diagnostics"
        

        Write-BlankLine

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

            "8" { Show-EventLogDiagnostics }

            "9" { Show-CrashDumpDiagnostics }

            "10" { Show-StartupDiagnostics }

            "B" { return }

            default {

                Write-WRTEWarning "Invalid selection."

                Wait-WRTE

            }

        }

    }
    while ($true)

}