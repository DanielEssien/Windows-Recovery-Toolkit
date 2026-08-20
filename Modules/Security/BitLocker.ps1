###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : BitLocker.ps1
# Purpose    : Displays BitLocker encryption and protection status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays BitLocker status.

.DESCRIPTION
Retrieves BitLocker-specific encryption status, protection state,
encryption method, encryption percentage, and key protector
types for available volumes.

.EXAMPLE
Show-BitLockerStatus

.OUTPUTS
None

.NOTES
This function is read-only and does not change BitLocker
configuration or encryption state.
#>

function Show-BitLockerStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "BitLocker Status"

    Write-Info "Collecting BitLocker information..."

    $StartTime = Get-Date

    try {

        $Volumes = @(
            Get-BitLockerVolume `
                -ErrorAction Stop
        )

        if ($Volumes.Count -eq 0) {

            Write-WRTEWarning "No BitLocker-compatible volumes were detected."

            Write-Log "BitLocker Status completed. No volumes detected." `
                -Level "WARNING"

            Show-Footer
            Wait-WRTE
            return
        }

        $ProtectedVolumes = 0
        $VolumeNumber = 1

        foreach ($Volume in $Volumes) {

            Show-Section "Volume $VolumeNumber"

            $MountPoint = if (
                -not [string]::IsNullOrWhiteSpace($Volume.MountPoint)
            ) {
                $Volume.MountPoint
            }
            else {
                "Unavailable"
            }

            Write-Property "Drive" $MountPoint
            Write-Property "Volume Type" $Volume.VolumeType
            Write-Property "Volume Status" $Volume.VolumeStatus
            Write-Property "Protection Status" $Volume.ProtectionStatus
            Write-Property "Encryption Method" $Volume.EncryptionMethod
            Write-Property "Encrypted Percentage" `
                ("{0}%" -f $Volume.EncryptionPercentage)

            $ProtectorTypes = @(
                $Volume.KeyProtector |
                    ForEach-Object {
                        $_.KeyProtectorType
                    } |
                    Where-Object {
                        $null -ne $_
                    } |
                    Select-Object -Unique
            )

            if ($ProtectorTypes.Count -gt 0) {

                Write-Property "Key Protectors" `
                    ($ProtectorTypes -join ", ")

            }
            else {

                Write-Property "Key Protectors" "None"

            }

            if ($Volume.ProtectionStatus -eq "On") {

                Write-Success "BitLocker protection is enabled on $MountPoint."

                $ProtectedVolumes++

            }
            else {

                Write-WRTEWarning "BitLocker protection is not enabled on $MountPoint."
                Write-Info "This does not confirm that the volume is unencrypted."

            }

            $VolumeNumber++
        }

        Show-Section "Assessment"

        if ($ProtectedVolumes -eq $Volumes.Count) {

            Write-Success "BitLocker protection is enabled on all detected volumes."

            $Assessment = "BitLocker Protected"

        }
        elseif ($ProtectedVolumes -eq 0) {

            Write-WRTEWarning "BitLocker protection is not enabled on any detected volume."
            Write-Info "Another full-disk encryption product may be protecting the system."

            $Assessment = "BitLocker Off"

        }
        else {

            Write-WRTEWarning "BitLocker protection is enabled on some volumes only."

            $Assessment = "BitLocker Partial"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Volumes Found" $Volumes.Count
        Write-Property "Protected Volumes" $ProtectedVolumes
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "BitLocker Status completed. Assessment: $Assessment. Volumes: $($Volumes.Count). Protected: $ProtectedVolumes. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve BitLocker status."
        Write-Info "Error: $ErrorMessage"

        Write-Log "BitLocker Status failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}