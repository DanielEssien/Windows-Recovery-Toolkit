###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Overview.ps1
# Purpose    : Displays a summary of Windows security status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays a summary of Windows security status.

.DESCRIPTION
Retrieves Microsoft Defender service status, Windows Firewall
profile state, BitLocker protection status, supported third-party
disk encryption providers, and Secure Boot state.

.EXAMPLE
Show-SecurityOverview

.OUTPUTS
None

.NOTES
This function provides a high-level security summary only.
Use the dedicated Security tools for detailed status information.
#>

function Show-SecurityOverview {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Security Overview"

    Write-Info "Collecting security information..."

    $StartTime = Get-Date

    try {

        # Microsoft Defender
        $DefenderService = Get-Service `
            -Name "WinDefend" `
            -ErrorAction SilentlyContinue

        $DefenderStatus = if ($null -ne $DefenderService) {
            $DefenderService.Status
        }
        else {
            "Unavailable"
        }

        # Windows Firewall
        $FirewallProfiles = @(
            Get-NetFirewallProfile `
                -ErrorAction SilentlyContinue
        )

        # BitLocker
        $BitLocker = $null

        try {

            $BitLocker = Get-BitLockerVolume `
                -MountPoint $env:SystemDrive `
                -ErrorAction Stop

        }
        catch {

            $BitLocker = $null

        }

        # Third-Party Disk Encryption
        $ThirdPartyProvider = Get-ThirdPartyEncryptionProvider

        # Secure Boot
        $SecureBootStatus = "Unavailable"

        try {

            $SecureBootEnabled = Confirm-SecureBootUEFI `
                -ErrorAction Stop

            if ($SecureBootEnabled) {
                $SecureBootStatus = "Enabled"
            }
            else {
                $SecureBootStatus = "Disabled"
            }

        }
        catch {

            $SecureBootStatus = "Unsupported or Unavailable"

        }

        Write-BlankLine
        Show-Section "Microsoft Defender"

        Write-Property "Service Status" $DefenderStatus

        if ($DefenderStatus -eq "Running") {

            Write-Success "Microsoft Defender service is running."

        }
        elseif ($DefenderStatus -eq "Stopped") {

            Write-WRTEWarning "Microsoft Defender service is not running."
            Write-Info "A third-party antivirus product may be active."

        }
        else {

            Write-WRTEWarning "Microsoft Defender status is unavailable."

        }

        Show-Section "Windows Firewall"

        if ($FirewallProfiles.Count -gt 0) {

            foreach ($Profile in $FirewallProfiles) {

                Write-Property "$($Profile.Name) Profile" `
                    $(if ($Profile.Enabled) { "Enabled" } else { "Disabled" })

            }

        }
        else {

            Write-WRTEWarning "Windows Firewall profile information is unavailable."

        }

        Show-Section "BitLocker"

        if ($null -ne $BitLocker) {

            Write-Property "Drive" $BitLocker.MountPoint
            Write-Property "Volume Status" $BitLocker.VolumeStatus
            Write-Property "Protection Status" $BitLocker.ProtectionStatus

        }
        else {

            Write-WRTEWarning "BitLocker status could not be retrieved."

        }

        Show-Section "Disk Encryption"

        if ($null -ne $BitLocker -and
            $BitLocker.ProtectionStatus -eq "On") {

            Write-Success "BitLocker protection is active."

        }
        elseif ($null -ne $ThirdPartyProvider) {

            Write-Property "Detected Provider" $ThirdPartyProvider.Name
            Write-Success "Third-party disk encryption components were detected."

        }
        else {

            Write-WRTEWarning "Active disk encryption could not be confirmed."

        }

        Show-Section "Secure Boot"
        Write-Property "Status" $SecureBootStatus

        if ($SecureBootStatus -eq "Enabled") {

            Write-Success "Secure Boot is enabled."

        }
        elseif ($SecureBootStatus -eq "Disabled") {

            Write-WRTEWarning "Secure Boot is disabled."

        }
        else {

            Write-Info "Secure Boot is unsupported or its status could not be determined."

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Security Overview completed. Defender: $DefenderStatus. Secure Boot: $SecureBootStatus. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve security information."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Security Overview failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}