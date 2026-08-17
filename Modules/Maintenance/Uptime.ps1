###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Uptime.ps1
# Purpose    : Displays system uptime and last boot information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays system uptime information.

.DESCRIPTION
Retrieves the last system boot time and calculates how long
Windows has been running since that boot.

.EXAMPLE
Show-SystemUptime

.OUTPUTS
None
#>

function Show-SystemUptime {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "System Uptime"

    Write-Info "Collecting uptime information..."

    $StartTime = Get-Date

    try {

        $OS = Get-CimInstance `
            -ClassName Win32_OperatingSystem `
            -ErrorAction Stop

        $LastBoot = $OS.LastBootUpTime
        $CurrentTime = Get-Date
        $Uptime = $CurrentTime - $LastBoot

        Write-BlankLine

        Write-Property "Last Boot" `
            ($LastBoot.ToString("yyyy-MM-dd HH:mm:ss"))

        Write-Property "Current Time" `
            ($CurrentTime.ToString("yyyy-MM-dd HH:mm:ss"))

        Write-Property "Uptime" `
            ("{0} days, {1} hours, {2} minutes" -f `
                $Uptime.Days,
                $Uptime.Hours,
                $Uptime.Minutes)

        Write-Property "Total Hours" `
            ("{0:N2}" -f $Uptime.TotalHours)

        if ($Uptime.TotalDays -ge 14) {

            Write-WRTEWarning "The system has been running for more than 14 days."
            Write-Info "A restart may help complete pending updates and maintenance tasks."

            $UptimeStatus = "Extended"

        }
        else {

            Write-Success "System uptime is within a normal range."

            $UptimeStatus = "Normal"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "System Uptime completed. Status: $UptimeStatus. Last Boot: $LastBoot. Uptime Hours: $($Uptime.TotalHours.ToString('N2')). Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve system uptime."
        Write-Info "Error: $ErrorMessage"

        Write-Log "System Uptime failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}