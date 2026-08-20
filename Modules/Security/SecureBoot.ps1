###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : SecureBoot.ps1
# Purpose    : Displays Secure Boot and firmware mode status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Secure Boot status.

.DESCRIPTION
Checks whether the system supports UEFI Secure Boot and reports
whether Secure Boot is currently enabled or disabled.

.EXAMPLE
Show-SecureBootStatus

.OUTPUTS
None

.NOTES
This function is read-only and does not modify firmware settings.
Secure Boot status may be unavailable on unsupported or legacy BIOS systems.
#>

function Show-SecureBootStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Secure Boot Status"

    Write-Info "Collecting Secure Boot information..."

    $StartTime = Get-Date

    try {

        $SecureBootStatus = "Unavailable"
        $FirmwareMode = "Unknown"

        try {

            $SecureBootEnabled = Confirm-SecureBootUEFI `
                -ErrorAction Stop

            $FirmwareMode = "UEFI"

            if ($SecureBootEnabled) {
                $SecureBootStatus = "Enabled"
            }
            else {
                $SecureBootStatus = "Disabled"
            }

        }
        catch {

            $FirmwareMode = "Unknown or Unsupported"
            $SecureBootStatus = "Unsupported"

        }

        Write-BlankLine

        Write-Property "Firmware Mode" $FirmwareMode
        Write-Property "Secure Boot" $SecureBootStatus

        Show-Section "Assessment"

        switch ($SecureBootStatus) {

            "Enabled" {

                Write-Success "Secure Boot is enabled."

                $Assessment = "Enabled"

            }

            "Disabled" {

                Write-WRTEWarning "Secure Boot is supported but disabled."
                Write-Info "Secure Boot can help protect the Windows boot process from unauthorized firmware and bootloader changes."

                $Assessment = "Disabled"

            }

            "Unsupported" {

                Write-WRTEWarning "Secure Boot status is unsupported or could not be queried."
                Write-Info "The system may be using Legacy BIOS mode or firmware that does not expose Secure Boot status."

                $Assessment = "Unsupported"

            }

            default {

                Write-WRTEWarning "Secure Boot status could not be determined."

                $Assessment = "Unavailable"

            }
        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Secure Boot Status completed. Firmware Mode: $FirmwareMode. Secure Boot: $SecureBootStatus. Assessment: $Assessment. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve Secure Boot status."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Secure Boot Status failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}