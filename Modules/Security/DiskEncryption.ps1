###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : DiskEncryption.ps1
# Purpose    : Displays detected full-disk encryption status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays detected disk encryption status.

.DESCRIPTION
Checks BitLocker status and detects supported third-party
disk encryption providers through installed applications
and related Windows services.

The function reports only providers WRTE can confidently identify.

.EXAMPLE
Show-DiskEncryptionStatus

.OUTPUTS
None

.NOTES
This function is read-only.
An unavailable result does not prove that a drive is unencrypted.
#>

function Show-DiskEncryptionStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Disk Encryption Status"

    Write-Info "Collecting disk encryption information..."

    $StartTime = Get-Date

    try {

        $SystemDrive = $env:SystemDrive

        $BitLockerDetected = $false
        $BitLockerProtected = $false

        try {

            $BitLocker = Get-BitLockerVolume `
                -MountPoint $SystemDrive `
                -ErrorAction Stop

            if ($null -ne $BitLocker) {

                $BitLockerDetected = $true

                if ($BitLocker.ProtectionStatus -eq "On") {
                    $BitLockerProtected = $true
                }
            }

        }
        catch {

            $BitLocker = $null

        }

        #
        # Third-party encryption detection
        #
        $ThirdPartyProvider = Get-ThirdPartyEncryptionProvider

        Write-BlankLine
        Show-Section "System Drive"

        Write-Property "Drive" $SystemDrive

        Show-Section "BitLocker"

        if ($BitLockerDetected) {

            Write-Property "Volume Status" $BitLocker.VolumeStatus
            Write-Property "Protection Status" $BitLocker.ProtectionStatus
            Write-Property "Encryption Method" $BitLocker.EncryptionMethod

            if ($BitLockerProtected) {

                Write-Success "BitLocker protection is active."

            }
            else {

                Write-Info "BitLocker protection is not active."

            }

        }
        else {

            Write-Property "Status" "Unavailable"

        }

        Show-Section "Third-Party Encryption"

        if ($null -ne $ThirdPartyProvider) {

            Write-Property "Detected Provider" $ThirdPartyProvider.Name

            if (-not [string]::IsNullOrWhiteSpace(
                    $ThirdPartyProvider.Version
                )) {

                Write-Property "Version" $ThirdPartyProvider.Version

            }

            Write-Property "Detection Source" `
                ($ThirdPartyProvider.DetectionSources -join ", ")

            if ($ThirdPartyProvider.ServicesDetected -gt 0) {

                Write-Property "Services Detected" `
                    $ThirdPartyProvider.ServicesDetected

                Write-Property "Services Running" `
                    $ThirdPartyProvider.ServicesRunning

            }

            Write-Success "$($ThirdPartyProvider.Name) components were detected."

        }
        else {

            Write-Property "Detected Provider" "Not detected"

        }

        Show-Section "Assessment"

        if ($BitLockerProtected) {

            Write-Success "Full-disk encryption protection is confirmed through BitLocker."

            $Assessment = "BitLocker Protected"

        }
        elseif ($null -ne $ThirdPartyProvider) {

            Write-Success "$($ThirdPartyProvider.Name) was detected."

            if ($ThirdPartyProvider.ServicesRunning -gt 0) {

                Write-Info "Encryption-related services are currently running."

            }

            Write-Info "Encryption state should be verified through the provider's management interface."

            $Assessment = "Third-Party Encryption Detected"

        }
        else {

            Write-WRTEWarning "WRTE could not confirm active full-disk encryption."
            Write-Info "This does not prove that the system drive is unencrypted."

            $Assessment = "Encryption Unconfirmed"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        $ProviderName = if ($null -ne $ThirdPartyProvider) {

            $ThirdPartyProvider.Name

        }
        else {

            "None"

        }

        Write-Log "Disk Encryption Status completed. Assessment: $Assessment. BitLocker Protected: $BitLockerProtected. Third-Party Provider: $ProviderName. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve disk encryption status."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Disk Encryption Status failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}