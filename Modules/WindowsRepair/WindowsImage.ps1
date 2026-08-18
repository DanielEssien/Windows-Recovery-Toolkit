###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : WindowsImage.ps1
# Purpose    : Repairs the Windows component store using DISM.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Repairs the Windows component store.

.DESCRIPTION
Runs DISM RestoreHealth to repair Windows image corruption.

When Windows Repair DryRun mode is enabled, WRTE simulates
the operation without executing DISM.

.EXAMPLE
Start-WindowsImageRepair

.OUTPUTS
None

.NOTES
Requires administrator privileges when DryRun mode is disabled.
Uses DISM RestoreHealth to repair the Windows component store.
The operation may take several minutes and may require internet access.
#>

function Start-WindowsImageRepair {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Repair Windows Image"

    $Config = Get-Configuration
    $DryRun = $Config.WindowsRepair.DryRun

    Write-Info "Preparing Windows image repair..."

    if ($DryRun) {

        Write-BlankLine
        Write-WRTEWarning "DRY-RUN mode is enabled."
        Write-Info "DISM RestoreHealth will be simulated."
        Write-Info "No changes will be made to the Windows image."

    }

    if (-not $DryRun) {

        $IsAdmin = Test-IsAdministrator

        if (-not $IsAdmin) {

            Write-WRTEError "Administrator privileges are required."
            Write-WRTEWarning "Close WRTE and run it as Administrator."

            Write-Log "Windows Image Repair blocked because WRTE is not running as Administrator." `
                -Level "WARNING"

            Show-Footer
            Wait-WRTE
            return
        }

        Write-Success "Administrator privileges confirmed."
    }

    Write-BlankLine
    Write-Info "This operation uses:"
    Write-Property "Command" "dism.exe /Online /Cleanup-Image /RestoreHealth"

    $Confirmation = (
        Read-Host "Proceed with Windows Image Repair? (Y/N)"
    ).Trim().ToUpper()

    if ($Confirmation -ne "Y") {

        Write-Info "Windows Image Repair cancelled."

        Write-Log "Windows Image Repair cancelled by user."

        Show-Footer
        Wait-WRTE
        return
    }

    if ($DryRun) {

        Write-BlankLine
        Show-Section "Simulation Result"

        Write-Success "Windows Image Repair simulation completed."
        Write-Info "No DISM command was executed."

        Write-Log "Windows Image Repair simulated. Dry-run mode enabled."

        Show-Footer
        Wait-WRTE
        return
    }

    $StartTime = Get-Date

    try {

        Write-BlankLine
        Write-Info "Running DISM RestoreHealth..."
        Write-WRTEWarning "This operation may take several minutes."

        $DismOutput = @(
            & "$env:SystemRoot\System32\dism.exe" `
                /Online `
                /Cleanup-Image `
                /RestoreHealth 2>&1 |
                ForEach-Object {

                    $Line = $_.ToString()

                    Write-Host $Line

                    $Line
                }
        )

        $ExitCode = $LASTEXITCODE
        $Elapsed = (Get-Date) - $StartTime

        $DismText = ($DismOutput -join "`n") -replace "`0", ""
        $DismText = $DismText -replace '\s+', ' '
        $DismText = $DismText.Trim()

        $Result = switch -Regex ($DismText) {

            "restore operation completed successfully" {
                "Repaired"
                break
            }

            "component store corruption was repaired" {
                "Repaired"
                break
            }

            "source files could not be found" {
                "SourceMissing"
                break
            }

            "no component store corruption detected" {
                "Healthy"
                break
            }

            default {

                if ($ExitCode -ne 0) {
                    "Failed"
                }
                else {
                    "Unknown"
                }
            }
        }

        Show-Section "Repair Result"

        switch ($Result) {

            "Repaired" {

                Write-Success "Windows image repair completed successfully."
                Write-Info "Consider running System File Checker afterward."

            }
            
            "Healthy" {

                Write-Success "No component store corruption was detected."
                Write-Info "No Windows image repair was required."

            }

            "SourceMissing" {

                Write-WRTEWarning "DISM could not locate the required repair source."
                Write-Info "A Windows installation source may be required."

            }

            "Failed" {

                Write-WRTEError "Windows image repair failed."

            }

            default {

                Write-WRTEWarning "DISM completed, but WRTE could not determine the final result."

            }
        }

        Write-BlankLine
        Write-Property "Exit Code" $ExitCode
        Write-Property "Execution Time" `
            ("{0:N2} min" -f $Elapsed.TotalMinutes)

        Write-Log "Windows Image Repair completed. Result: $Result. Exit Code: $ExitCode. Duration: $($Elapsed.TotalMinutes.ToString('N2')) minutes."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to complete Windows Image Repair."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Windows Image Repair failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}