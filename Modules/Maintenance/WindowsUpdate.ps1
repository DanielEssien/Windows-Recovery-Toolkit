###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : WindowsUpdate.ps1
# Purpose    : Displays Windows Update status information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Windows Update status information.

.DESCRIPTION
Retrieves Windows Update service status, pending reboot state,
and recent installed update information.

.EXAMPLE
Show-WindowsUpdateStatus

.OUTPUTS
None

.NOTES
Reports Windows Update and BITS service status, checks common
pending-restart registry locations, and displays the most recent
installed hotfix available through Get-HotFix.
#>

function Show-WindowsUpdateStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Windows Update Status"

    Write-Info "Collecting Windows Update information..."

    $StartTime = Get-Date

    try {

        $WindowsUpdateService = Get-Service `
            -Name "wuauserv" `
            -ErrorAction Stop

        $BITSService = Get-Service `
            -Name "BITS" `
            -ErrorAction SilentlyContinue

        $RecentUpdate = Get-HotFix `
            -ErrorAction SilentlyContinue |
            Where-Object {
                $null -ne $_.InstalledOn
            } |
            Sort-Object -Property InstalledOn -Descending |
            Select-Object -First 1

        $PendingReboot = $false

        $RebootPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
        )

        foreach ($Path in $RebootPaths) {

            if (Test-Path $Path) {
                $PendingReboot = $true
                break
            }
        }

        Write-BlankLine
        Show-Section "Update Services"

        Write-Property "Windows Update" $WindowsUpdateService.Status

        if ($WindowsUpdateService.Status -eq "Stopped") {
            Write-Info "Windows Update service may remain stopped until Windows requires it."
        }

        if ($null -ne $BITSService) {
            Write-Property "BITS" $BITSService.Status
        }
        else {
            Write-Property "BITS" "Unavailable"
        }

        Show-Section "Update State"

        if ($PendingReboot) {

            Write-WRTEWarning "A system restart is pending."
            Write-Property "Pending Restart" "Yes"

        }
        else {

            Write-Success "No pending restart was detected."
            Write-Property "Pending Restart" "No"

        }

        Show-Section "Recent Update"

        if ($null -ne $RecentUpdate) {

            Write-Property "HotFix ID" $RecentUpdate.HotFixID
            Write-Property "Description" $RecentUpdate.Description
            Write-Property "Installed On" `
                ($RecentUpdate.InstalledOn.ToString("yyyy-MM-dd"))

        }
        else {

            Write-WRTEWarning "No recent installed update information was found."

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Windows Update Status completed. Windows Update Service: $($WindowsUpdateService.Status). Pending Restart: $PendingReboot. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve Windows Update status."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Windows Update Status failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}