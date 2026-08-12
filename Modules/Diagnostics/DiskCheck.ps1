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

    $DiskOutput = @(
        & chkdsk.exe $SystemDrive /scan 2>&1 |
            ForEach-Object {

                $Line = $_.ToString()

                Write-Host $Line

                $Line
            }
    )

    $ExitCode = $LASTEXITCODE
    $Elapsed  = (Get-Date) - $StartTime

    $DiskText = ($DiskOutput -join "`n") -replace "`0", ""
    $DiskText = $DiskText -replace '\s+', ' '
    $DiskText = $DiskText.Trim()
    
    $DiskResult = "Unknown"

    if ($DiskText -match "Windows has scanned the file system and found no problems") {

        $DiskResult = "Healthy"

    }
    elseif ($DiskText -match "Windows found problems with the file system") {

        $DiskResult = "ProblemsFound"

    }
    elseif ($DiskText -match "errors found") {

        $DiskResult = "ProblemsFound"

    }
    elseif ($ExitCode -ne 0) {

        $DiskResult = "Failed"

    }

    Write-BlankLine
    Show-Section "Disk Check Results"

    switch ($DiskResult) {

        "Healthy" {

            Write-Success "No file system problems were detected."

        }

        "ProblemsFound" {

            Write-WRTEWarning "File system problems were detected."
            Write-Info "A repair operation may be required."

        }

        "Failed" {

            Write-WRTEError "CHKDSK failed with exit code $ExitCode."

        }

        default {

            Write-WRTEWarning "Disk scan completed, but WRTE could not determine the result automatically."

        }

    }
    
    Write-BlankLine
    Write-Property "Drive" $SystemDrive
    Write-Property "Exit Code" $ExitCode
    Write-Property "Execution Time" ("{0:N2} min" -f $Elapsed.TotalMinutes)

    Write-Log "Disk Check completed on $SystemDrive. Result: $DiskResult. Exit Code: $ExitCode. Duration: $($Elapsed.TotalMinutes.ToString('N2')) minutes."

    Show-Footer

    Wait-WRTE
}