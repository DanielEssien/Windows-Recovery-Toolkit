###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : UpdateChannel.ps1
# Purpose    : Displays Microsoft 365 update channel information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Microsoft 365 update channel information.

.DESCRIPTION
Retrieves Microsoft Office Click-to-Run configuration including
update channel, CDN source, installed version, architecture,
and update settings.

.EXAMPLE
Show-OfficeUpdateChannel

.OUTPUTS
None

.NOTES
This function is read-only and does not modify Microsoft 365
update configuration.
#>

function Show-OfficeUpdateChannel {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Microsoft 365 Update Channel"

    Write-Info "Collecting Microsoft 365 update information..."

    $StartTime = Get-Date

    try {

        $ConfigPath =
            "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"

        if (-not (Test-Path -Path $ConfigPath)) {

            Write-WRTEWarning "Microsoft Office Click-to-Run configuration was not detected."

            Write-Log `
                "Microsoft 365 Update Channel completed. Click-to-Run configuration not detected." `
                -Level "WARNING"

            Show-Footer
            Wait-WRTE
            return
        }

        $Configuration =
            Get-ItemProperty `
                -Path $ConfigPath `
                -ErrorAction Stop

        #------------------------------------------------------
        # Installed Version
        #------------------------------------------------------
        $InstalledVersion = if (
            -not [string]::IsNullOrWhiteSpace(
                $Configuration.VersionToReport
            )
        ) {
            $Configuration.VersionToReport
        }
        elseif (
            -not [string]::IsNullOrWhiteSpace(
                $Configuration.ClientVersionToReport
            )
        ) {
            $Configuration.ClientVersionToReport
        }
        else {
            "Unavailable"
        }

        #------------------------------------------------------
        # Architecture
        #------------------------------------------------------
        $Architecture = if (
            -not [string]::IsNullOrWhiteSpace(
                $Configuration.Platform
            )
        ) {
            $Configuration.Platform
        }
        else {
            "Unavailable"
        }

        #------------------------------------------------------
        # Update channel
        #------------------------------------------------------
        $CDNBaseUrl = $Configuration.CDNBaseUrl
        $UpdateChannelUrl = $Configuration.UpdateChannel

        $ChannelName = "Unknown"

        $ChannelSource = if (
            -not [string]::IsNullOrWhiteSpace($UpdateChannelUrl)
        ) {
            $UpdateChannelUrl
        }
        else {
            $CDNBaseUrl
        }

        if (-not [string]::IsNullOrWhiteSpace($ChannelSource)) {

            switch -Regex ($ChannelSource) {

                "492350f6-3a01-4f97-b9c0-c7c6ddf67d60" {
                    $ChannelName = "Current Channel"
                    break
                }

                "55336b82-a18d-4dd6-b5f6-9e5095c314a6" {
                    $ChannelName = "Monthly Enterprise Channel"
                    break
                }

                "7ffbc6bf-bc32-4f92-8982-f9dd17fd3114" {
                    $ChannelName = "Semi-Annual Enterprise Channel"
                    break
                }

                "b8f9b850-328d-4355-9145-c59439a0c4cf" {
                    $ChannelName = "Semi-Annual Enterprise Channel (Preview)"
                    break
                }

                "64256afe-f5d9-4f86-8936-8840a6a4f5be" {
                    $ChannelName = "Current Channel (Preview)"
                    break
                }

                "5440fd1f-7ecb-4221-8110-145efaa6372f" {
                    $ChannelName = "Beta Channel"
                    break
                }

                default {
                    $ChannelName = "Configured Channel"
                }
            }
        }

        #------------------------------------------------------
        # Update state
        #------------------------------------------------------
        $UpdatesEnabled = if (
            $null -ne $Configuration.UpdatesEnabled
        ) {
            $Configuration.UpdatesEnabled
        }
        else {
            "Unavailable"
        }

        $UpdatePath = if (
            -not [string]::IsNullOrWhiteSpace(
                $Configuration.UpdatePath
            )
        ) {
            $Configuration.UpdatePath
        }
        else {
            "Microsoft CDN"
        }

        #------------------------------------------------------
        # Display
        #------------------------------------------------------
        Write-BlankLine
        Show-Section "Installation"

        Write-Property "Installed Version" $InstalledVersion
        Write-Property "Architecture" $Architecture

        Show-Section "Update Channel"

        Write-Property "Channel" $ChannelName

        if (-not [string]::IsNullOrWhiteSpace($ChannelSource)) {

            Write-Property "Channel Source" $ChannelSource

        }
        else {

            Write-Property "Channel Source" "Unavailable"

        }

        Write-Property "Update Path" $UpdatePath
        Write-Property "Updates Enabled" $UpdatesEnabled

        Show-Section "Assessment"

        if ($UpdatesEnabled -eq $false -or
            $UpdatesEnabled -eq "False") {

            Write-WRTEWarning "Microsoft 365 Click-to-Run automatic updates are disabled in the detected configuration."
            Write-Info "Updates may still be managed through organizational policy or another management service."

            $Assessment = "Updates Disabled"

        }
        elseif ($InstalledVersion -eq "Unavailable") {

            Write-WRTEWarning "Microsoft 365 update configuration was detected, but the installed version could not be determined."

            $Assessment = "Configuration Detected"

        }
        else {

            Write-Success "Microsoft 365 Click-to-Run update configuration was detected."

            $Assessment = "Configured"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log `
            "Microsoft 365 Update Channel completed. Assessment: $Assessment. Version: $InstalledVersion. Channel: $ChannelName. Updates Enabled: $UpdatesEnabled. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve Microsoft 365 update information."
        Write-Info "Error: $ErrorMessage"

        Write-Log `
            "Microsoft 365 Update Channel failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}