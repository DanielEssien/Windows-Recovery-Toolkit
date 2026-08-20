###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Firewall.ps1
# Purpose    : Displays Windows Firewall profile status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Windows Firewall status.

.DESCRIPTION
Retrieves Windows Firewall profile configuration including
enabled state, default inbound and outbound actions, and
logging configuration.

.EXAMPLE
Show-FirewallStatus

.OUTPUTS
None

.NOTES
This function is read-only.
Firewall actions may display as NotConfigured when settings
are inherited from Windows defaults or policy.
#>

function Show-FirewallStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Firewall Status"

    Write-Info "Collecting Windows Firewall information..."

    $StartTime = Get-Date

    try {

        $Profiles = @(
            Get-NetFirewallProfile `
                -ErrorAction Stop |
                Sort-Object -Property Name
        )

        if ($Profiles.Count -eq 0) {

            Write-WRTEWarning "No Windows Firewall profiles were detected."

            Write-Log "Firewall Status completed. No firewall profiles detected." `
                -Level "WARNING"

            Show-Footer
            Wait-WRTE
            return
        }

        $DisabledProfiles = 0

        foreach ($Profile in $Profiles) {

            Show-Section "$($Profile.Name) Profile"

            $EnabledStatus = if ($Profile.Enabled) {
                "Enabled"
            }
            else {
                "Disabled"
            }

            Write-Property "Status" $EnabledStatus
            Write-Property "Inbound Action" $Profile.DefaultInboundAction
            Write-Property "Outbound Action" $Profile.DefaultOutboundAction

            if (-not [string]::IsNullOrWhiteSpace($Profile.LogFileName)) {
                Write-Property "Log File" $Profile.LogFileName
            }
            else {
                Write-Property "Log File" "Unavailable"
            }

            Write-Property "Log Allowed" $Profile.LogAllowed
            Write-Property "Log Blocked" $Profile.LogBlocked

            if ($Profile.Enabled) {

                Write-Success "$($Profile.Name) firewall profile is enabled."

            }
            else {

                Write-WRTEWarning "$($Profile.Name) firewall profile is disabled."
                $DisabledProfiles++

            }
        }

        Show-Section "Assessment"

        if ($DisabledProfiles -eq 0) {

            Write-Success "All Windows Firewall profiles are enabled."

            $Assessment = "Healthy"

        }
        elseif ($DisabledProfiles -eq $Profiles.Count) {

            Write-WRTEError "All Windows Firewall profiles are disabled."

            $Assessment = "Disabled"

        }
        else {

            Write-WRTEWarning "One or more Windows Firewall profiles are disabled."

            $Assessment = "Partial"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Profiles Found" $Profiles.Count
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Firewall Status completed. Assessment: $Assessment. Profiles: $($Profiles.Count). Disabled Profiles: $DisabledProfiles. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve Windows Firewall status."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Firewall Status failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}