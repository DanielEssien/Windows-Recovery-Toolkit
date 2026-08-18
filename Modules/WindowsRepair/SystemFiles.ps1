###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : SystemFiles.ps1
# Purpose    : Repairs Windows system files using SFC.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Repairs Windows system files.

.DESCRIPTION
Runs System File Checker in repair mode to scan protected
Windows system files and repair detected corruption.

When Windows Repair DryRun mode is enabled, WRTE simulates
the operation without executing SFC.

.EXAMPLE
Start-SystemFileRepair

.OUTPUTS
None

.NOTES
Requires administrator privileges when DryRun mode is disabled.
Uses System File Checker with the /scannow option.
A reboot may be required if Windows repairs protected system files.
#>

function Start-SystemFileRepair {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Repair System Files"

    $Config = Get-Configuration
    $DryRun = $Config.WindowsRepair.DryRun

    Write-Info "Preparing System File Checker repair..."

    if ($DryRun) {

        Write-BlankLine
        Write-WRTEWarning "DRY-RUN mode is enabled."
        Write-Info "SFC repair will be simulated."
        Write-Info "No system files will be scanned or modified."

    }

    if (-not $DryRun) {

        $IsAdmin = Test-IsAdministrator

        if (-not $IsAdmin) {

            Write-WRTEError "Administrator privileges are required."
            Write-WRTEWarning "Close WRTE and run it as Administrator."

            Write-Log "System File Repair blocked because WRTE is not running as Administrator." `
                -Level "WARNING"

            Show-Footer
            Wait-WRTE
            return
        }

        Write-Success "Administrator privileges confirmed."
    }

    Write-BlankLine
    Write-Info "This operation uses: sfc.exe /scannow"

    $Confirmation = (
        Read-Host "Proceed with System File Repair? (Y/N)"
    ).Trim().ToUpper()

    if ($Confirmation -ne "Y") {

        Write-Info "System File Repair cancelled."

        Write-Log "System File Repair cancelled by user."

        Show-Footer
        Wait-WRTE
        return
    }

    if ($DryRun) {

        Write-BlankLine
        Show-Section "Simulation Result"

        Write-Success "System File Repair simulation completed."
        Write-Info "Command that would have been executed:"
        Write-Property "Command" "sfc.exe /scannow"

        Write-Log "System File Repair simulated. Dry-run mode enabled."

        Show-Footer
        Wait-WRTE
        return
    }

    $StartTime = Get-Date

    try {

        Write-BlankLine
        Write-Info "Running System File Checker..."
        Write-WRTEWarning "This operation may take several minutes."

        $SfcOutput = @(
            & "$env:SystemRoot\System32\sfc.exe" /scannow 2>&1 |
                ForEach-Object {

                    $Line = $_.ToString()

                    Write-Host $Line

                    $Line
                }
        )

        $ExitCode = $LASTEXITCODE
        $Elapsed = (Get-Date) - $StartTime

        $SfcText = ($SfcOutput -join "`n") -replace "`0", ""
        $SfcText = $SfcText -replace '\s+', ' '
        $SfcText = $SfcText.Trim()

        $Result = switch -Regex ($SfcText) {

            "did not find.*integrity violations" {
                "Healthy"
                break
            }

            "found corrupt files.*successfully repaired" {
                "Repaired"
                break
            }

            "found corrupt files.*unable to fix" {
                "Unrepaired"
                break
            }

            "could not perform.*requested operation" {
                "Failed"
                break
            }

            "repair.*pending" {
                "RebootRequired"
                break
            }

            default {
                "Unknown"
            }
        }

        Show-Section "Repair Result"

        switch ($Result) {

            "Healthy" {
                Write-Success "No integrity violations were found."
            }

            "Repaired" {
                Write-Success "Corrupt system files were repaired successfully."
            }

            "Unrepaired" {
                Write-WRTEWarning "Some corrupt system files could not be repaired."
                Write-Info "Consider running DISM repair before retrying SFC."
            }

            "Failed" {
                Write-WRTEError "System File Checker could not complete the requested operation."
            }

            "RebootRequired" {
                Write-WRTEWarning "A system repair is pending."
                Write-Info "Restart Windows before running System File Checker again."
            }

            default {
                Write-WRTEWarning "System File Checker completed, but WRTE could not determine the final result."
            }
        }

        Write-BlankLine
        Write-Property "Exit Code" $ExitCode
        Write-Property "Execution Time" `
            ("{0:N2} min" -f $Elapsed.TotalMinutes)

        Write-Log "System File Repair completed. Result: $Result. Exit Code: $ExitCode. Duration: $($Elapsed.TotalMinutes.ToString('N2')) minutes."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to complete System File Repair."
        Write-Info "Error: $ErrorMessage"

        Write-Log "System File Repair failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}