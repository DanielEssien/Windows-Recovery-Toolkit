###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : DiagnosticReport.ps1
# Purpose    : Generates a WRTE diagnostic health report.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Generates a WRTE diagnostic health report.

.DESCRIPTION
Collects a read-only health snapshot of the local computer,
including operating system, storage, memory, network, security,
and Microsoft 365 status.

The report is exported as a timestamped text file to the WRTE
Reports directory.

.EXAMPLE
New-WRTEDiagnosticReport

.OUTPUTS
None

.NOTES
This function is read-only.
#>

function New-WRTEDiagnosticReport {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Diagnostic Report"

    Write-Info "Collecting diagnostic information..."

    $StartTime = Get-Date

    try {

        $ReportDirectory = Get-WRTEReportPath

        $ReportFileName =
            New-WRTEReportFileName `
                -ReportType "DiagnosticReport"

        $ReportFile =
            Join-Path `
                -Path $ReportDirectory `
                -ChildPath $ReportFileName

        $ReportContent = @()

        $ReportContent +=
            New-WRTEReportHeader `
                -Title "WRTE Diagnostic Report"

        #------------------------------------------------------
        # Operating System
        #------------------------------------------------------

        $OperatingSystem =
            Get-CimInstance `
                -ClassName Win32_OperatingSystem `
                -ErrorAction Stop

        $ReportContent += "Operating System"
        $ReportContent += "----------------"

        $ReportContent +=
            "OS Name            : $($OperatingSystem.Caption)"

        $ReportContent +=
            "Version            : $($OperatingSystem.Version)"

        $ReportContent +=
            "Build Number       : $($OperatingSystem.BuildNumber)"

        $ReportContent += ""

        #------------------------------------------------------
        # Uptime
        #------------------------------------------------------

        $LastBoot =
            $OperatingSystem.LastBootUpTime

        $Uptime =
            (Get-Date) - $LastBoot

        $ReportContent += "System Uptime"
        $ReportContent += "-------------"

        $ReportContent +=
            ("Last Boot          : {0}" `
            -f $LastBoot.ToString("yyyy-MM-dd HH:mm:ss"))

        $ReportContent +=
            ("Uptime             : {0} days, {1} hours, {2} minutes" `
            -f $Uptime.Days, $Uptime.Hours, $Uptime.Minutes)

        $ReportContent += ""

        #------------------------------------------------------
        # Memory
        #------------------------------------------------------

        $ComputerSystem =
            Get-CimInstance `
                -ClassName Win32_ComputerSystem `
                -ErrorAction Stop

        $TotalMemoryGB =
            [math]::Round(
                $ComputerSystem.TotalPhysicalMemory / 1GB,
                2
            )

        $FreeMemoryGB =
            [math]::Round(
                $OperatingSystem.FreePhysicalMemory / 1MB,
                2
            )

        $UsedMemoryGB =
            [math]::Round(
                $TotalMemoryGB - $FreeMemoryGB,
                2
            )

        $MemoryUsagePercent =
            if ($TotalMemoryGB -gt 0) {
                [math]::Round(
                    ($UsedMemoryGB / $TotalMemoryGB) * 100,
                    1
                )
            }
            else {
                0
            }

        $ReportContent += "Memory"
        $ReportContent += "------"

        $ReportContent +=
            "Installed Memory   : $TotalMemoryGB GB"

        $ReportContent +=
            "Used Memory        : $UsedMemoryGB GB"

        $ReportContent +=
            "Free Memory        : $FreeMemoryGB GB"

        $ReportContent +=
            "Memory Usage       : $MemoryUsagePercent%"

        $ReportContent += ""

        #------------------------------------------------------
        # Storage
        #------------------------------------------------------

        $Drives = @(
            Get-CimInstance `
                -ClassName Win32_LogicalDisk `
                -Filter "DriveType = 3" `
                -ErrorAction Stop
        )

        $ReportContent += "Storage"
        $ReportContent += "-------"

        foreach ($Drive in $Drives) {

            $SizeGB =
                if ($Drive.Size) {
                    [math]::Round(
                        $Drive.Size / 1GB,
                        2
                    )
                }
                else {
                    0
                }

            $FreeGB =
                if ($Drive.FreeSpace) {
                    [math]::Round(
                        $Drive.FreeSpace / 1GB,
                        2
                    )
                }
                else {
                    0
                }

            $FreePercent =
                if ($Drive.Size -gt 0) {
                    [math]::Round(
                        ($Drive.FreeSpace / $Drive.Size) * 100,
                        1
                    )
                }
                else {
                    0
                }

            $DriveAssessment =
                if ($FreePercent -lt 10) {
                    "Low Free Space"
                }
                elseif ($FreePercent -lt 20) {
                    "Monitor"
                }
                else {
                    "Healthy"
                }

            $ReportContent +=
                "Drive              : $($Drive.DeviceID)"

            $ReportContent +=
                "Total Size         : $SizeGB GB"

            $ReportContent +=
                "Free Space         : $FreeGB GB"

            $ReportContent +=
                "Free Space %       : $FreePercent%"

            $ReportContent +=
                "Assessment         : $DriveAssessment"

            $ReportContent += ""

        }

        #------------------------------------------------------
        # Network
        #------------------------------------------------------

        $NetworkAdapters = @(
            Get-CimInstance `
                -ClassName Win32_NetworkAdapterConfiguration `
                -Filter "IPEnabled = True" `
                -ErrorAction SilentlyContinue
        )

        $ReportContent += "Network"
        $ReportContent += "-------"

        if ($NetworkAdapters.Count -gt 0) {

            foreach ($Adapter in $NetworkAdapters) {

                $IPv4Addresses = @(
                    $Adapter.IPAddress |
                        Where-Object {
                            $_ -match "^\d{1,3}(\.\d{1,3}){3}$"
                        }
                )

                $ReportContent +=
                    "Adapter            : $($Adapter.Description)"

                $ReportContent +=
                    "DHCP Enabled       : $($Adapter.DHCPEnabled)"

                if ($IPv4Addresses.Count -gt 0) {

                    $ReportContent +=
                        "IPv4 Address       : $($IPv4Addresses -join ', ')"

                }
                else {

                    $ReportContent +=
                        "IPv4 Address       : Not detected"

                }

                if ($Adapter.DefaultIPGateway) {

                    $ReportContent +=
                        "Default Gateway    : $($Adapter.DefaultIPGateway -join ', ')"

                }

                if ($Adapter.DNSServerSearchOrder) {

                    $ReportContent +=
                        "DNS Servers        : $($Adapter.DNSServerSearchOrder -join ', ')"

                }

                $ReportContent += ""

            }

        }
        else {

            $ReportContent +=
                "Status             : No active IP-enabled adapter detected"

            $ReportContent += ""

        }

        #------------------------------------------------------
        # Windows Security
        #------------------------------------------------------

        $ReportContent += "Windows Security"
        $ReportContent += "----------------"

        $FirewallProfiles = @(
            Get-NetFirewallProfile `
                -ErrorAction SilentlyContinue
        )

        if ($FirewallProfiles.Count -gt 0) {

            foreach ($Profile in $FirewallProfiles) {

                $ReportContent +=
                    "$($Profile.Name) Firewall   : $($Profile.Enabled)"

            }

        }
        else {

            $ReportContent +=
                "Firewall Status    : Unable to determine"

        }

        try {

            $DefenderStatus =
                Get-MpComputerStatus `
                    -ErrorAction Stop

            $ReportContent +=
                "Defender Service   : $($DefenderStatus.AMServiceEnabled)"

            $ReportContent +=
                "Antivirus Enabled  : $($DefenderStatus.AntivirusEnabled)"

            $ReportContent +=
                "Real-Time Protect. : $($DefenderStatus.RealTimeProtectionEnabled)"

        }
        catch {

            $ReportContent +=
                "Defender Status    : Unable to determine"

        }

        $ReportContent += ""

        #------------------------------------------------------
        # Microsoft 365
        #------------------------------------------------------

        $ReportContent += "Microsoft 365"
        $ReportContent += "-------------"

        $ClickToRunPath =
            "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"

        if (Test-Path -Path $ClickToRunPath) {

            try {

                $OfficeConfiguration =
                    Get-ItemProperty `
                        -Path $ClickToRunPath `
                        -ErrorAction Stop

                $OfficeVersion =
                    if ($OfficeConfiguration.VersionToReport) {
                        $OfficeConfiguration.VersionToReport
                    }
                    elseif ($OfficeConfiguration.ClientVersionToReport) {
                        $OfficeConfiguration.ClientVersionToReport
                    }
                    else {
                        "Unavailable"
                    }

                $ReportContent +=
                    "Office Installed   : Yes"

                $ReportContent +=
                    "Office Version     : $OfficeVersion"

                if ($OfficeConfiguration.Platform) {

                    $ReportContent +=
                        "Architecture       : $($OfficeConfiguration.Platform)"

                }

            }
            catch {

                $ReportContent +=
                    "Office Status      : Configuration detected but unreadable"

            }

        }
        else {

            $ReportContent +=
                "Office Installed   : Not detected"

        }

        $TeamsPackages = @(
            Get-AppxPackage `
                -Name "MSTeams" `
                -ErrorAction SilentlyContinue
        )

        if ($TeamsPackages.Count -gt 0) {

            $ReportContent +=
                "Microsoft Teams    : Installed"

        }
        else {

            $ReportContent +=
                "Microsoft Teams    : Not detected"

        }

        $ReportContent += ""

        #------------------------------------------------------
        # Overall Assessment
        #------------------------------------------------------

        $Issues = @()

       foreach ($Drive in $Drives) {

            if ($Drive.Size -le 0) {
                continue
            }

            $DriveFreePercent =
                ($Drive.FreeSpace / $Drive.Size) * 100

            if ($DriveFreePercent -lt 10) {

                $Issues +=
                    "Low disk space on $($Drive.DeviceID)"

            }
            elseif ($DriveFreePercent -lt 20) {

                $Issues +=
                    "Disk space should be monitored on $($Drive.DeviceID)"

            }

        }

        if ($MemoryUsagePercent -ge 90) {

            $Issues +=
                "High memory usage"

        }

        if ($NetworkAdapters.Count -eq 0) {

            $Issues +=
                "No active network adapter detected"

        }

        $ReportContent += "Overall Assessment"
        $ReportContent += "------------------"

        if ($Issues.Count -eq 0) {

            $ReportContent +=
                "Status             : No immediate issues detected"

        }
        else {

            $ReportContent +=
                "Status             : Attention recommended"

            foreach ($Issue in $Issues) {

                $ReportContent +=
                    "Issue              : $Issue"

            }

        }

        $ReportContent += ""

        #------------------------------------------------------
        # Export Report
        #------------------------------------------------------

        $ReportContent |
            Set-Content `
                -Path $ReportFile `
                -Encoding UTF8 `
                -ErrorAction Stop

        Show-Section "Report Generated"

        Write-Success "Diagnostic report generated successfully."
        Write-Property "Report File" $ReportFile

        $Duration =
            (Get-Date) - $StartTime

        Write-Property `
            "Execution Time" `
            ("{0:N2} sec" -f $Duration.TotalSeconds)

        Write-Log `
            ("Diagnostic report generated: {0}. Issues: {1}. Duration: {2:N2} seconds." `
            -f $ReportFile, $Issues.Count, $Duration.TotalSeconds) `
            -Level INFO

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to generate the diagnostic report."
        Write-Info "Error: $ErrorMessage"

        Write-Log `
            "Diagnostic report generation failed. $ErrorMessage" `
            -Level ERROR

    }

    Show-Footer
    Wait-WRTE
}