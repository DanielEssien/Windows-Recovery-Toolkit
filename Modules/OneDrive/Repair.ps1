###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Repair.ps1
# Purpose    : Provides safe OneDrive repair and reset actions.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Provides OneDrive repair options.

.DESCRIPTION
Detects the installed OneDrive client and allows the user to
reset the OneDrive synchronization client after confirmation.

The reset operation reinitializes the OneDrive sync client and
causes synchronization state to be rebuilt. It is not intended
to delete files stored locally or in OneDrive.

.EXAMPLE
Repair-OneDrive

.OUTPUTS
None

.NOTES
This function performs a OneDrive client reset only after
explicit user confirmation.
#>

function Repair-OneDrive {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Repair OneDrive"

    Write-Info "Preparing OneDrive repair options..."

    $StartTime = Get-Date

    try {

        #
        # Detect OneDrive executable
        #
        $OneDrivePaths = @(
            "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe",
            "$env:ProgramFiles\Microsoft OneDrive\OneDrive.exe",
            "${env:ProgramFiles(x86)}\Microsoft OneDrive\OneDrive.exe"
        )

        $OneDrivePath = $null

        foreach ($Path in $OneDrivePaths) {

            if (-not [string]::IsNullOrWhiteSpace($Path) -and
                (Test-Path -Path $Path)) {

                $OneDrivePath = $Path
                break

            }
        }

        if ($null -eq $OneDrivePath) {

            Write-WRTEError "OneDrive client could not be detected."

            Write-Log "OneDrive Repair stopped. OneDrive executable not detected." `
                -Level "ERROR"

            Show-Footer
            Wait-WRTE
            return
        }

        Write-BlankLine
        Show-Section "Detected Client"

        Write-Property "Executable" $OneDrivePath

        $OneDriveProcesses = @(
            Get-Process `
                -Name "OneDrive" `
                -ErrorAction SilentlyContinue
        )

        $ProcessStatus = if ($OneDriveProcesses.Count -gt 0) {
            "Running"
        }
        else {
            "Not Running"
        }

        Write-Property "Process Status" $ProcessStatus

        Show-Section "Reset Information"

        Write-Info "Resetting OneDrive can help resolve synchronization and client-state problems."
        Write-Info "The operation does not intentionally delete files stored in your OneDrive folders."

        Write-BlankLine
        Write-WRTEWarning "OneDrive synchronization may pause temporarily while the client resets."

        $Confirmation = Read-Host "Reset OneDrive now? (Y/N)"

        if ($Confirmation.Trim().ToUpper() -ne "Y") {

            Write-BlankLine
            Write-Info "OneDrive reset was cancelled."

            Write-Log "OneDrive Repair cancelled by user."

            Show-Footer
            Wait-WRTE
            return
        }

        Show-Section "Reset"

        Write-Info "Resetting OneDrive client..."

        $ResetProcess = Start-Process `
            -FilePath $OneDrivePath `
            -ArgumentList "/reset" `
            -PassThru `
            -Wait `
            -ErrorAction Stop

        if ($ResetProcess.ExitCode -eq 0) {

            Write-Success "OneDrive reset command completed."

        }
        else {

            Write-WRTEWarning "OneDrive reset command returned exit code $($ResetProcess.ExitCode)."

        }

        #
        # Give OneDrive a moment to restart automatically
        #
        Start-Sleep -Seconds 5

        $RunningAfterReset = @(
            Get-Process `
                -Name "OneDrive" `
                -ErrorAction SilentlyContinue
        )

        if ($RunningAfterReset.Count -eq 0) {

            Write-Info "OneDrive has not restarted automatically."
            Write-Info "Attempting to start the client..."

            Start-Process `
                -FilePath $OneDrivePath `
                -ErrorAction Stop

            Start-Sleep -Seconds 2

        }

        $FinalProcesses = @(
            Get-Process `
                -Name "OneDrive" `
                -ErrorAction SilentlyContinue
        )

        Show-Section "Assessment"

        if ($FinalProcesses.Count -gt 0) {

            Write-Success "OneDrive is running after the reset operation."

            $Assessment = "Reset Completed"

        }
        else {

            Write-WRTEWarning "OneDrive reset completed, but the client is not currently running."
            Write-Info "The client may require manual startup or user sign-in."

            $Assessment = "Reset Completed - Client Not Running"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "OneDrive Repair completed. Assessment: $Assessment. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to complete OneDrive repair."
        Write-Info "Error: $ErrorMessage"

        Write-Log "OneDrive Repair failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}