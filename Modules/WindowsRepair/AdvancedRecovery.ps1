###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : AdvancedRecovery.ps1
# Purpose    : Opens Windows advanced recovery options safely.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Opens Windows recovery settings.

.DESCRIPTION
Opens the Windows Recovery settings page so the user can access
advanced startup and recovery options.

When Windows Repair DryRun mode is enabled, WRTE simulates
the action without opening Windows Settings.

.EXAMPLE
Open-AdvancedRecovery

.OUTPUTS
None

.NOTES
WRTE does not restart the system automatically or force entry
into Windows Recovery Environment. The user remains in control.
#>

function Open-AdvancedRecovery {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Advanced Recovery"

    $Config = Get-Configuration
    $DryRun = $Config.WindowsRepair.DryRun

    Write-Info "Preparing Windows recovery options..."

    if ($DryRun) {

        Write-BlankLine
        Write-WRTEWarning "DRY-RUN mode is enabled."
        Write-Info "Windows Recovery settings will not be opened."

    }

    Write-BlankLine
    Write-Info "This action opens the Windows Recovery settings page."
    Write-Info "WRTE will not restart the computer automatically."

    $Confirmation = (
        Read-Host "Open Advanced Recovery options? (Y/N)"
    ).Trim().ToUpper()

    if ($Confirmation -ne "Y") {

        Write-Info "Advanced Recovery cancelled."

        Write-Log "Advanced Recovery cancelled by user."

        Show-Footer
        Wait-WRTE
        return
    }

    if ($DryRun) {

        Write-BlankLine
        Show-Section "Simulation Result"

        Write-Success "Advanced Recovery simulation completed."
        Write-Info "The following Windows Settings page would have been opened:"
        Write-Property "URI" "ms-settings:recovery"

        Write-Log "Advanced Recovery simulated. Dry-run mode enabled."

        Show-Footer
        Wait-WRTE
        return
    }

    $StartTime = Get-Date

    try {

        Write-BlankLine
        Write-Info "Opening Windows Recovery settings..."

        Start-Process `
            -FilePath "ms-settings:recovery" `
            -ErrorAction Stop

        $Elapsed = (Get-Date) - $StartTime

        Write-Success "Windows Recovery settings opened successfully."
        Write-Info "Use Advanced startup only when you are ready to restart the system."

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Advanced Recovery settings opened successfully. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to open Windows Recovery settings."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Advanced Recovery failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}