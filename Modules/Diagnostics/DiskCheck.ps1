###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : DiskCheck.ps1
# Purpose    : Performs Windows disk health checks.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Runs an online disk scan.

.DESCRIPTION
Runs CHKDSK using the /scan option against the Windows
system drive to detect file system problems without
forcing an offline repair.

.EXAMPLE
Start-DiskCheck
#>

function Start-DiskCheck {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Disk Check"

    Write-Info "Preparing disk health scan..."

    $IsAdmin = Test-IsAdministrator

    if (-not $IsAdmin) {

        Write-WRTEError "Administrator privileges are required to run CHKDSK."
        Write-WRTEWarning "Close WRTE and run it as Administrator."

        Write-Log "Disk Check blocked because WRTE is not running as Administrator." `
            -Level "WARNING"

        Wait-WRTE
        return
    }

    $SystemDrive = $env:SystemDrive

    Write-Success "Administrator privileges confirmed."
    Write-Property "Target Drive" $SystemDrive

    Write-BlankLine
    Write-Info "CHKDSK /scan performs an online file system scan."
    Write-Info "No repair operation will be performed during this scan."

    $Confirmation = (Read-Host "Run disk scan on $SystemDrive now? (Y/N)").Trim().ToUpper()

    if ($Confirmation -ne "Y") {

        Write-Info "Disk scan cancelled."
        Write-Log "Disk Check cancelled by user."

        Wait-WRTE
        return
    }

    Write-BlankLine
    Write-Info "Starting disk scan..."

    Write-Log "Disk Check started on $SystemDrive."

    $StartTime = Get-Date

    & chkdsk.exe $SystemDrive /scan

    $ExitCode = $LASTEXITCODE
    $Elapsed  = (Get-Date) - $StartTime

    Write-BlankLine
    Show-Section "Disk Check Results"

    if ($ExitCode -eq 0) {

        Write-Success "Disk scan completed."

    }
    else {

        Write-WRTEWarning "CHKDSK completed with exit code $ExitCode."

    }

    Write-BlankLine
    Write-Property "Drive" $SystemDrive
    Write-Property "Exit Code" $ExitCode
    Write-Property "Execution Time" ("{0:N2} min" -f $Elapsed.TotalMinutes)

    Write-Log "Disk Check completed on $SystemDrive. Exit Code: $ExitCode. Duration: $($Elapsed.TotalMinutes.ToString('N2')) minutes."

    Show-Footer

    Wait-WRTE
}