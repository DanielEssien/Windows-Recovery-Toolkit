###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : SystemReport.ps1
# Purpose    : Generates a WRTE system information report.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Generates a WRTE system information report.

.DESCRIPTION
Collects key operating system, computer, processor, memory,
storage, network, and uptime information and exports the results
to a timestamped text report in the WRTE Reports directory.

.EXAMPLE
New-WRTESystemReport

.OUTPUTS
None

.NOTES
This function is read-only.
#>

function New-WRTESystemReport {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "System Report"

    Write-Info "Collecting system information..."

    $StartTime = Get-Date

    try {

        $ReportDirectory = Get-WRTEReportPath

        $ReportFileName =
            New-WRTEReportFileName `
                -ReportType "SystemReport"

        $ReportFile =
            Join-Path `
                -Path $ReportDirectory `
                -ChildPath $ReportFileName

        $ReportContent = @()

        $ReportContent +=
            New-WRTEReportHeader `
                -Title "WRTE System Report"

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
            "Computer Name      : $env:COMPUTERNAME"

        $ReportContent +=
            "OS Name            : $($OperatingSystem.Caption)"

        $ReportContent +=
            "OS Version         : $($OperatingSystem.Version)"

        $ReportContent +=
            "Build Number       : $($OperatingSystem.BuildNumber)"

        $ReportContent +=
            "Architecture       : $($OperatingSystem.OSArchitecture)"

        $ReportContent +=
            "Windows Directory  : $($OperatingSystem.WindowsDirectory)"

        $ReportContent += ""

        #------------------------------------------------------
        # Computer System
        #------------------------------------------------------

        $ComputerSystem =
            Get-CimInstance `
                -ClassName Win32_ComputerSystem `
                -ErrorAction Stop

        $ReportContent += "Computer System"
        $ReportContent += "---------------"

        $ReportContent +=
            "Manufacturer       : $($ComputerSystem.Manufacturer)"

        $ReportContent +=
            "Model              : $($ComputerSystem.Model)"

        $ReportContent +=
            "Domain             : $($ComputerSystem.Domain)"

        $ReportContent +=
            "Logged-on User     : $($ComputerSystem.UserName)"

        $TotalMemoryGB =
            [math]::Round(
                $ComputerSystem.TotalPhysicalMemory / 1GB,
                2
            )

        $ReportContent +=
            "Installed Memory   : $TotalMemoryGB GB"

        $ReportContent += ""

        #------------------------------------------------------
        # BIOS
        #------------------------------------------------------

        $BIOS =
            Get-CimInstance `
                -ClassName Win32_BIOS `
                -ErrorAction Stop

        $ReportContent += "BIOS"
        $ReportContent += "----"

        $ReportContent +=
            "Serial Number      : $($BIOS.SerialNumber)"

        $ReportContent +=
            "BIOS Version       : $($BIOS.SMBIOSBIOSVersion)"

        if ($BIOS.ReleaseDate) {

            $BIOSDate =
                Get-Date `
                    -Date $BIOS.ReleaseDate `
                    -Format "yyyy-MM-dd"

            $ReportContent +=
                "Release Date       : $BIOSDate"

        }

        $ReportContent += ""

        #------------------------------------------------------
        # Processor
        #------------------------------------------------------

        $Processors = @(
            Get-CimInstance `
                -ClassName Win32_Processor `
                -ErrorAction Stop
        )

        $ReportContent += "Processor"
        $ReportContent += "---------"

        foreach ($Processor in $Processors) {

            $ReportContent +=
                "Name               : $($Processor.Name.Trim())"

            $ReportContent +=
                "Cores              : $($Processor.NumberOfCores)"

            $ReportContent +=
                "Logical Processors : $($Processor.NumberOfLogicalProcessors)"

            $ReportContent +=
                "Max Clock Speed    : $($Processor.MaxClockSpeed) MHz"

            $ReportContent += ""

        }

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

            $ReportContent +=
                "Drive              : $($Drive.DeviceID)"

            $ReportContent +=
                "Volume Name        : $($Drive.VolumeName)"

            $ReportContent +=
                "File System        : $($Drive.FileSystem)"

            $ReportContent +=
                "Total Size         : $SizeGB GB"

            $ReportContent +=
                "Free Space         : $FreeGB GB"

            $ReportContent += ""

        }

        #------------------------------------------------------
        # Network
        #------------------------------------------------------

        $NetworkAdapters = @(
            Get-CimInstance `
                -ClassName Win32_NetworkAdapterConfiguration `
                -Filter "IPEnabled = True" `
                -ErrorAction Stop
        )

        $ReportContent += "Network"
        $ReportContent += "-------"

        foreach ($Adapter in $NetworkAdapters) {

            $IPv4Addresses = @(
                $Adapter.IPAddress |
                    Where-Object {
                        $_ -match "^\d{1,3}(\.\d{1,3}){3}$"
                    }
            )

            $ReportContent +=
                "Adapter            : $($Adapter.Description)"

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
        # Export Report
        #------------------------------------------------------

        $ReportContent |
            Set-Content `
                -Path $ReportFile `
                -Encoding UTF8 `
                -ErrorAction Stop

        Show-Section "Report Generated"

        Write-Success "System report generated successfully."
        Write-Property "Report File" $ReportFile

        $Duration =
            (Get-Date) - $StartTime

        Write-Property `
            "Execution Time" `
            ("{0:N2} sec" -f $Duration.TotalSeconds)

        Write-Log `
            ("System report generated: {0}. Duration: {1:N2} seconds." `
            -f $ReportFile, $Duration.TotalSeconds) `
            -Level INFO

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to generate the system report."
        Write-Info "Error: $ErrorMessage"

        Write-Log `
            "System report generation failed. $ErrorMessage" `
            -Level ERROR

    }

    Show-Footer
    Wait-WRTE
}