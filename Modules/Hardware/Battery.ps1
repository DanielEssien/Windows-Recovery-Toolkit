###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Battery.ps1
# Purpose    : Displays battery information and status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays battery information.

.DESCRIPTION
Retrieves battery charge, status, and estimated runtime
information from Windows.

.EXAMPLE
Show-BatteryInformation

.OUTPUTS
None
#>

function Show-BatteryInformation {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Battery Information"

    Write-Info "Collecting battery information..."

    $StartTime = Get-Date

    try {

        $Batteries = @(
            Get-CimInstance `
                -ClassName Win32_Battery `
                -ErrorAction Stop
        )

        if ($Batteries.Count -eq 0) {

            Write-BlankLine
            Write-WRTEWarning "No battery was detected on this system."

            Write-Log "Battery Information completed. No battery detected."

            Show-Footer
            Wait-WRTE
            return
        }

        $BatteryNumber = 1

        foreach ($Battery in $Batteries) {

            Show-Section "Battery $BatteryNumber"

            Write-Property "Name" $Battery.Name
            Write-Property "Device ID" $Battery.DeviceID
            Write-Property "Charge" ("{0}%" -f $Battery.EstimatedChargeRemaining)

            $Status = switch ($Battery.BatteryStatus) {

                1 { "Discharging" }
                2 { "AC Power" }
                3 { "Fully Charged" }
                4 { "Low" }
                5 { "Critical" }
                6 { "Charging" }
                7 { "Charging - High" }
                8 { "Charging - Low" }
                9 { "Charging - Critical" }
                10 { "Undefined" }
                11 { "Partially Charged" }

                default { "Unknown" }
            }

            Write-Property "Status" $Status

            if ($Battery.EstimatedRunTime -and
                $Battery.EstimatedRunTime -ne 71582788) {

                Write-Property "Estimated Runtime" `
                    ("{0} min" -f $Battery.EstimatedRunTime)

            }
            else {

                Write-Property "Estimated Runtime" "Unavailable"

            }

            $BatteryNumber++
        }

        $BatteryHealth = Get-BatteryHealth

        if ($null -ne $BatteryHealth) {

            Show-Section "Battery Health"

            Write-Property "Manufacturer" $BatteryHealth.Manufacturer
            Write-Property "Serial Number" $BatteryHealth.SerialNumber
            Write-Property "Chemistry" $BatteryHealth.Chemistry

            Write-Property "Design Capacity" `
                ("{0:N0} mWh" -f $BatteryHealth.DesignCapacity)

            Write-Property "Full Charge Capacity" `
                ("{0:N0} mWh" -f $BatteryHealth.FullChargeCapacity)

            if ($null -ne $BatteryHealth.CycleCount -and
                $BatteryHealth.CycleCount -gt 0) {

                Write-Property "Cycle Count" $BatteryHealth.CycleCount

            }
            else {

                Write-Property "Cycle Count" "Unavailable"

            }

            if ($null -ne $BatteryHealth.HealthPercent) {

                Write-Property "Battery Health" `
                    ("{0:N2}%" -f $BatteryHealth.HealthPercent)

                if ($BatteryHealth.HealthPercent -ge 80) {

                    Write-Success "Battery health is good."

                }
                elseif ($BatteryHealth.HealthPercent -ge 60) {

                    Write-WRTEWarning "Battery capacity has noticeably degraded."

                }
                else {

                    Write-WRTEWarning "Battery health is poor. Replacement may be advisable."

                }
            }
        }
        else {

            Write-BlankLine
            Write-WRTEWarning "Detailed battery health information is unavailable."

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Batteries Found" $Batteries.Count
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Battery Information completed. Batteries Found: $($Batteries.Count). Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        Write-WRTEError "Unable to retrieve battery information."

        Write-Log "Battery Information failed. $($_.Exception.Message)" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}

<#
.SYNOPSIS
Retrieves battery health information.

.DESCRIPTION
Generates a temporary Windows battery report in XML format
and retrieves design capacity, full-charge capacity, cycle
count, and calculated battery health.

.OUTPUTS
PSCustomObject or null

.EXAMPLE
Get-BatteryHealth

.NOTES
Uses the Windows powercfg battery report.
Temporary report files are removed after processing.
#>

function Get-BatteryHealth {

    [CmdletBinding()]
    param()

    $ReportPath = Join-Path `
        -Path $env:TEMP `
        -ChildPath "WRTE-BatteryReport.xml"

    try {

        & "$env:SystemRoot\System32\powercfg.exe" `
            /batteryreport `
            /output $ReportPath `
            /xml |
            Out-Null

        if ($LASTEXITCODE -ne 0) {
            return $null
        }

        if (-not (Test-Path $ReportPath)) {
            return $null
        }

        [xml]$Report = Get-Content `
            -Path $ReportPath `
            -Raw `
            -ErrorAction Stop

        $Battery = $Report.BatteryReport.Batteries.Battery |
            Select-Object -First 1

        if ($null -eq $Battery) {
            return $null
        }

        $DesignCapacity = [int64]$Battery.DesignCapacity
        $FullChargeCapacity = [int64]$Battery.FullChargeCapacity

        $HealthPercent = if ($DesignCapacity -gt 0) {

            [Math]::Round(
                ($FullChargeCapacity / $DesignCapacity) * 100,
                2
            )

        }
        else {

            $null

        }

        return [PSCustomObject]@{
            Manufacturer       = $Battery.Manufacturer
            SerialNumber       = $Battery.SerialNumber
            Chemistry          = $Battery.Chemistry
            DesignCapacity     = $DesignCapacity
            FullChargeCapacity = $FullChargeCapacity
            CycleCount         = $Battery.CycleCount
            HealthPercent      = $HealthPercent
        }

    }
    catch {

        Write-Log "Unable to retrieve battery health information. $($_.Exception.Message)" `
            -Level "WARNING"

        return $null

    }
    finally {

        if (Test-Path $ReportPath) {

            Remove-Item `
                -Path $ReportPath `
                -Force `
                -ErrorAction SilentlyContinue

        }
    }
}