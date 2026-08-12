###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : DISM.ps1
# Purpose    : Performs Windows image health diagnostics
#              and repair operations.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Runs a DISM health scan.

.DESCRIPTION
Uses DISM /Online /Cleanup-Image /ScanHealth to check the
Windows component store for corruption.

.EXAMPLE
Start-DISMScan
#>

function Start-DISMScan {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "DISM Scan"

    Write-Info "Preparing DISM health scan..."

    $IsAdmin = Test-IsAdministrator

    if (-not $IsAdmin) {

        Write-WRTEError "Administrator privileges are required to run DISM."
        Write-WRTEWarning "Close WRTE and run it as Administrator."

        Write-Log "DISM Scan blocked because WRTE is not running as Administrator." `
            -Level "WARNING"

        Wait-WRTE
        return
    }

    Write-Success "Administrator privileges confirmed."

    Write-BlankLine
    Write-WRTEWarning "DISM ScanHealth may take several minutes to complete."

    $Confirmation = (Read-Host "Run DISM ScanHealth now? (Y/N)").Trim().ToUpper()

    if ($Confirmation -ne "Y") {

        Write-Info "DISM Scan cancelled."
        Write-Log "DISM Scan cancelled by user."

        Wait-WRTE
        return
    }

    Write-BlankLine
    Write-Info "Starting DISM health scan..."

    Write-Log "DISM ScanHealth started."

    $StartTime = Get-Date

    $DismOutput = @(
        & dism.exe /Online /Cleanup-Image /ScanHealth 2>&1 |
            ForEach-Object {

                $Line = $_.ToString()

                Write-Host $Line

                $Line
            }
    )

    $ExitCode = $LASTEXITCODE
    $Elapsed  = (Get-Date) - $StartTime

    $DismText = ($DismOutput -join "`n") -replace "`0", ""
    $DismText = $DismText -replace '\s+', ' '
    $DismText = $DismText.Trim()

    $DismResult = "Unknown"

    if ($DismText -match "No component store corruption detected") {

        $DismResult = "Healthy"

    }
    elseif ($DismText -match "component store is repairable") {

        $DismResult = "Repairable"

    }
    elseif ($DismText -match "component store cannot be repaired") {

        $DismResult = "Unrepairable"

    }
    elseif ($ExitCode -ne 0) {

        $DismResult = "Failed"

    }

    Write-BlankLine
    Show-Section "DISM Scan Results"

    switch ($DismResult) {

        "Healthy" {

            Write-Success "No component store corruption was detected."

        }

        "Repairable" {

            Write-WRTEWarning "Component store corruption was detected."
            Write-Info "The Windows image is repairable."
            Write-WRTEWarning "Run DISM RestoreHealth to repair the component store."

        }

        "Unrepairable" {

            Write-WRTEError "The Windows component store cannot be repaired automatically."

        }

        "Failed" {

            Write-WRTEError "DISM ScanHealth failed with exit code $ExitCode."

        }

        default {

            Write-WRTEWarning "DISM completed, but WRTE could not determine the image health."

        }

    }

    Write-BlankLine
    Write-Property "Exit Code" $ExitCode
    Write-Property "Execution Time" ("{0:N2} min" -f $Elapsed.TotalMinutes)

    Write-Log "DISM ScanHealth completed. Result: $DismResult. Exit Code: $ExitCode. Duration: $($Elapsed.TotalMinutes.ToString('N2')) minutes."

    Show-Footer

    Wait-WRTE
}

<#
.SYNOPSIS
Repairs the Windows component store.

.DESCRIPTION
Uses DISM /Online /Cleanup-Image /RestoreHealth to detect
and repair Windows component store corruption.

.OUTPUTS
None

.EXAMPLE
Start-DISMRestore

.NOTES
Requires administrator privileges.
May use Windows Update as a repair source.
#>

function Start-DISMRestore {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "DISM RestoreHealth"

    Write-Info "Preparing DISM repair operation..."

    $IsAdmin = Test-IsAdministrator

    if (-not $IsAdmin) {

        Write-WRTEError "Administrator privileges are required to run DISM RestoreHealth."
        Write-WRTEWarning "Close WRTE and run it as Administrator."

        Write-Log "DISM RestoreHealth blocked because WRTE is not running as Administrator." `
            -Level "WARNING"

        Wait-WRTE
        return
    }

    Write-Success "Administrator privileges confirmed."

    Write-BlankLine
    Write-WRTEWarning "DISM RestoreHealth will attempt to repair the Windows component store."
    Write-Info "The operation may take several minutes and may use Windows Update as a repair source."

    $Confirmation = (Read-Host "Run DISM RestoreHealth now? (Y/N)").Trim().ToUpper()

    if ($Confirmation -ne "Y") {

        Write-Info "DISM RestoreHealth cancelled."
        Write-Log "DISM RestoreHealth cancelled by user."

        Wait-WRTE
        return
    }

    Write-BlankLine
    Write-Info "Starting DISM RestoreHealth..."

    Write-Log "DISM RestoreHealth started."

    $StartTime = Get-Date

    $DismOutput = @(
        & dism.exe /Online /Cleanup-Image /RestoreHealth 2>&1 |
            ForEach-Object {

                $Line = $_.ToString()

                Write-Host $Line

                $Line
            }
    )

    $ExitCode = $LASTEXITCODE
    $Elapsed  = (Get-Date) - $StartTime

    $DismText = ($DismOutput -join "`n") -replace "`0", ""
    $DismText = $DismText -replace '\s+', ' '
    $DismText = $DismText.Trim()

    $DismResult = "Unknown"

    if ($DismText -match "restore operation completed successfully") {

        $DismResult = "Repaired"

    }
    elseif ($DismText -match "source files could not be found") {

        $DismResult = "SourceMissing"

    }
    elseif ($DismText -match "component store corruption was repaired") {

        $DismResult = "Repaired"

    }
    elseif ($ExitCode -ne 0) {

        $DismResult = "Failed"

    }

    Write-BlankLine
    Show-Section "DISM Restore Results"

    switch ($DismResult) {

        "Repaired" {

            Write-Success "DISM RestoreHealth completed successfully."
            Write-Info "The Windows component store repair operation completed."
            Write-Info "Run System File Checker (SFC) to verify system file integrity."

        }

        "SourceMissing" {

            Write-WRTEError "DISM could not find the required repair source."
            Write-WRTEWarning "A Windows installation source may be required."

        }

        "Failed" {

            Write-WRTEError "DISM RestoreHealth failed with exit code $ExitCode."

        }

        default {

            Write-WRTEWarning "DISM completed, but WRTE could not determine the repair result automatically."

        }

    }

    Write-BlankLine
    Write-Property "Exit Code" $ExitCode
    Write-Property "Execution Time" ("{0:N2} min" -f $Elapsed.TotalMinutes)

    Write-Log "DISM RestoreHealth completed. Result: $DismResult. Exit Code: $ExitCode. Duration: $($Elapsed.TotalMinutes.ToString('N2')) minutes."

    Show-Footer

    Wait-WRTE
}