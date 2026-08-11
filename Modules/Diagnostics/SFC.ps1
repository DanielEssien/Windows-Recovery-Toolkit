###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : SFC.ps1
# Purpose    : Runs Windows System File Checker diagnostics
#              and repair operations.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Runs the Windows System File Checker.

.DESCRIPTION
Executes SFC /scannow to scan protected Windows system files
and repair detected corruption where possible.

.EXAMPLE
Start-SFC
#>

function Start-SFC {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "System File Checker"

    Write-Info "Preparing System File Checker..."

    $IsAdmin = Test-IsAdministrator

    if (-not $IsAdmin) {

        Write-WRTEError "Administrator privileges are required to run SFC."

        Write-WRTEWarning "Close WRTE and run it as Administrator."

        Write-Log "SFC launch blocked because WRTE is not running as Administrator." `
            -Level "WARNING"

        Wait-WRTE

        return
    }

    Write-Success "Administrator privileges confirmed."

    Write-BlankLine
    Write-WRTEWarning "System File Checker may take several minutes to complete."

    $Confirmation = (Read-Host "Run SFC /scannow now? (Y/N)").Trim().ToUpper()

    if ($Confirmation -ne "Y") {

        Write-Info "SFC operation cancelled."

        Write-Log "SFC operation cancelled by user."

        Wait-WRTE
        return
    }

    Write-BlankLine
    Write-Info "Starting System File Checker..."

    Write-Log "SFC scan started."

    $StartTime = Get-Date

    $SfcOutput = @(
        & "$env:SystemRoot\System32\sfc.exe" /scannow 2>&1 |
            ForEach-Object {

                $Line = $_.ToString()

                Write-Host $Line

                $Line
            }
    )

    $ExitCode = $LASTEXITCODE
    $Elapsed  = (Get-Date) - $StartTime

    $SfcText = ($SfcOutput -join "`n") -replace "`0", ""
    $SfcText = $SfcText -replace '\s+', ' '
    $SfcText = $SfcText.Trim()

    # Default result
    $SfcResult = "Unknown"

    if ($SfcText -match "did not find.*integrity violations") {

        $SfcResult = "Healthy"

    }
    elseif ($SfcText -match "found corrupt files.*successfully repaired") {

        $SfcResult = "Repaired"

    }
    elseif ($SfcText -match "found corrupt files.*unable to fix") {

        $SfcResult = "Unrepaired"

    }
    elseif ($SfcText -match "could not perform.*requested operation") {

        $SfcResult = "Failed"

    }
    elseif ($SfcText -match "repair.*pending") {

        $SfcResult = "RebootRequired"

    }

    Write-BlankLine
    Show-Section "SFC Results"

    switch ($SfcResult) {

        "Healthy" {

            Write-Success "No integrity violations were found."

        }

        "Repaired" {

            Write-Success "Corrupt system files were found and successfully repaired."

        }

        "Unrepaired" {

            Write-WRTEError "Corrupt files were found, but some could not be repaired."
            Write-WRTEWarning "DISM repair is recommended before running SFC again."

        }

        "RebootRequired" {

            Write-WRTEWarning "A pending repair requires Windows to be restarted."
            Write-Info "Restart Windows, then run SFC again."

        }

        "Failed" {

            Write-WRTEError "System File Checker could not complete the requested operation."

        }

        default {

            Write-WRTEWarning "SFC completed, but WRTE could not determine the result automatically."

        }

    }

    Write-BlankLine

    Write-Property "Exit Code" $ExitCode
    Write-Property "Execution Time" ("{0:N2} min" -f $Elapsed.TotalMinutes)

    Write-Log "SFC completed. Result: $SfcResult. Exit Code: $ExitCode. Duration: $($Elapsed.TotalMinutes.ToString('N2')) minutes."

    Show-Footer

    Wait-WRTE
}