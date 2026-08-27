###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : NetworkReset.ps1
# Purpose    : Resets Windows network stack components.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Resets the Windows network stack.

.DESCRIPTION
Resets Winsock and TCP/IP networking components.

When Windows Repair DryRun mode is enabled, WRTE simulates
the operation without executing any network reset commands.

.EXAMPLE
Start-NetworkStackReset

.OUTPUTS
None

.NOTES
Requires administrator privileges when DryRun mode is disabled.
Resets Winsock and TCP/IP configuration.
A system restart is recommended after the reset.
#>

function Start-NetworkStackReset {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Reset Network Stack"

    $Config =
        Get-Configuration

    $GlobalDryRun =
        [bool]$Config.WindowsRepair.DryRun

    $LiveFeatureEnabled =
        [bool]$Config.WindowsRepair.LiveFeatures.NetworkStackReset

    $DryRun =
        $GlobalDryRun -or
        (-not $LiveFeatureEnabled)

    Write-Info "Preparing network stack reset..."

    if ($DryRun) {

        Write-BlankLine
        Write-WRTEWarning "Network Stack Reset is running in DRY-RUN mode."
        Write-Info "Network reset commands will be simulated."
        Write-Info "No network configuration will be changed."

        if (
            -not $GlobalDryRun -and
            -not $LiveFeatureEnabled
        ) {

            Write-Info `
                "Live execution for Network Stack Reset is not enabled."
        }
    }

    if (-not $DryRun) {

        $IsAdmin = Test-IsAdministrator

        if (-not $IsAdmin) {

            Write-WRTEError "Administrator privileges are required."
            Write-WRTEWarning "Close WRTE and run it as Administrator."

            Write-Log "Network Stack Reset blocked because WRTE is not running as Administrator." `
                -Level "WARNING"

            Show-Footer
            Wait-WRTE
            return
        }

        Write-Success "Administrator privileges confirmed."
    }

    Write-BlankLine
    Write-WRTEWarning "This operation may temporarily disrupt network connectivity."

    if (-not $DryRun) {

        Write-WRTEWarning "Active network sessions may be interrupted."
        Write-WRTEWarning "A Windows restart is recommended after the reset."
    }

    Write-Info "Commands:"
    Write-Property "Winsock Reset" "netsh winsock reset"
    Write-Property "TCP/IP Reset" "netsh int ip reset"

    $Confirmation = (
        Read-Host "Proceed with Network Stack Reset? (Y/N)"
    ).Trim().ToUpper()

    if ($Confirmation -ne "Y") {

        Write-Info "Network Stack Reset cancelled."

        Write-Log "Network Stack Reset cancelled by user."

        Show-Footer
        Wait-WRTE
        return
    }

    if ($DryRun) {

        Write-BlankLine
        Show-Section "Simulation Result"

        Write-Success "Network Stack Reset simulation completed."
        Write-Info "No network reset commands were executed."

        Write-Log "Network Stack Reset simulated. Dry-run mode enabled."

        Show-Footer
        Wait-WRTE
        return
    }

    $StartTime = Get-Date

    try {

        Write-BlankLine
        Write-Info "Resetting Winsock..."

        & "$env:SystemRoot\System32\netsh.exe" `
            winsock reset

        $WinsockExitCode = $LASTEXITCODE

        Write-BlankLine
        Write-Info "Resetting TCP/IP stack..."

        & "$env:SystemRoot\System32\netsh.exe" `
            int ip reset

        $IPResetExitCode = $LASTEXITCODE

        $Elapsed = (Get-Date) - $StartTime

        Show-Section "Reset Result"

        if ($WinsockExitCode -eq 0 -and
            $IPResetExitCode -eq 0) {

            Write-Success "Network stack reset completed successfully."
            Write-WRTEWarning "Restart Windows to complete the reset."

            $Result = "Completed"

        }
        else {

            Write-WRTEWarning "One or more network reset operations did not complete successfully."

            $Result = "Partial"

        }

        Write-BlankLine
        Write-Property "Winsock Exit Code" $WinsockExitCode
        Write-Property "TCP/IP Exit Code" $IPResetExitCode
        Write-Property "Restart Recommended" "Yes"
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Network Stack Reset completed. Result: $Result. Winsock Exit Code: $WinsockExitCode. TCP/IP Exit Code: $IPResetExitCode. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to complete Network Stack Reset."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Network Stack Reset failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}