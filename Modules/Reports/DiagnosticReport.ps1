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
Microsoft 365, event log, crash, startup, device, and TPM status.

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
        # Event Log Health
        #------------------------------------------------------

        $EventWindowStart =
            (Get-Date).AddHours(-24)

        $SystemErrorEvents = @(
            Get-WinEvent `
                -FilterHashtable @{
                    LogName   = "System"
                    Level     = 1, 2
                    StartTime = $EventWindowStart
                } `
                -ErrorAction SilentlyContinue
        )

        $ApplicationErrorEvents = @(
            Get-WinEvent `
                -FilterHashtable @{
                    LogName   = "Application"
                    Level     = 1, 2
                    StartTime = $EventWindowStart
                } `
                -ErrorAction SilentlyContinue
        )

        $EventErrorCount =
            $SystemErrorEvents.Count +
            $ApplicationErrorEvents.Count

        $ReportContent += "Event Log Health"
        $ReportContent += "----------------"

        $ReportContent +=
            "Time Window         : Last 24 hours"

        $ReportContent +=
            "System Errors       : $($SystemErrorEvents.Count)"

        $ReportContent +=
            "Application Errors  : $($ApplicationErrorEvents.Count)"

        $ReportContent +=
            "Total Errors        : $EventErrorCount"

        $ReportContent += ""

        #------------------------------------------------------
        # Crash / BSOD Health
        #------------------------------------------------------

        $CrashWindowStart =
            (Get-Date).AddDays(-30)

        $BugCheckEvents = @(
            Get-WinEvent `
                -FilterHashtable @{
                    LogName   = "System"
                    Id        = 1001
                    StartTime = $CrashWindowStart
                } `
                -ErrorAction SilentlyContinue |
            Where-Object {
                $_.ProviderName -eq
                    "Microsoft-Windows-WER-SystemErrorReporting"
            }
        )

        $MinidumpPath =
            Join-Path `
                $env:SystemRoot `
                "Minidump"

        $MinidumpFiles =
            if (Test-Path $MinidumpPath) {
                @(
                    Get-ChildItem `
                        -Path $MinidumpPath `
                        -Filter "*.dmp" `
                        -File `
                        -ErrorAction SilentlyContinue
                )
            }
            else {
                @()
            }

        $RecentMinidumps = @(
            $MinidumpFiles |
                Where-Object {
                    $_.LastWriteTime -ge $CrashWindowStart
                }
        )

        $MemoryDumpPath =
            Join-Path `
                $env:SystemRoot `
                "MEMORY.DMP"

        $MemoryDumpPresent =
            Test-Path $MemoryDumpPath

        $ReportContent += "Crash / BSOD Health"
        $ReportContent += "-------------------"

        $ReportContent +=
            "Time Window         : Last 30 days"

        $ReportContent +=
            "BugCheck Events     : $($BugCheckEvents.Count)"

        $ReportContent +=
            "Recent Minidumps    : $($RecentMinidumps.Count)"

        $ReportContent +=
            "MEMORY.DMP Present  : $MemoryDumpPresent"

        $ReportContent += ""

        #------------------------------------------------------
        # Startup Health
        #------------------------------------------------------

        $StartupApplications = @()

        $StartupRegistryPaths = @(
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
        )

        foreach ($StartupRegistryPath in $StartupRegistryPaths) {

            if (-not (Test-Path $StartupRegistryPath)) {
                continue
            }

            try {

                $StartupProperties =
                    Get-ItemProperty `
                        -Path $StartupRegistryPath `
                        -ErrorAction Stop

                foreach (
                    $Property in
                    $StartupProperties.PSObject.Properties
                ) {

                    if (
                        $Property.Name -in
                        "(default)",
                        "PSPath",
                        "PSParentPath",
                        "PSChildName",
                        "PSDrive",
                        "PSProvider"
                    ) {
                        continue
                    }

                    $StartupApplications +=
                        $Property.Name
                }
            }
            catch {
                # Report generation continues if one startup
                # registry location cannot be read.
            }
        }

        $StartupFolders = @(
            Join-Path `
                $env:APPDATA `
                "Microsoft\Windows\Start Menu\Programs\Startup",

            Join-Path `
                $env:ProgramData `
                "Microsoft\Windows\Start Menu\Programs\Startup"
        )

        foreach ($StartupFolder in $StartupFolders) {

            if (-not (Test-Path $StartupFolder)) {
                continue
            }

            $StartupFolderItems = @(
                Get-ChildItem `
                    -Path $StartupFolder `
                    -File `
                    -ErrorAction SilentlyContinue
            )

            foreach ($StartupFolderItem in $StartupFolderItems) {
                $StartupApplications +=
                    $StartupFolderItem.Name
            }
        }

        $StartupTasks = @()

        try {

            $ScheduledTasks = @(
                Get-ScheduledTask `
                    -ErrorAction Stop
            )

            foreach ($ScheduledTask in $ScheduledTasks) {

                $StartupTriggers = @(
                    $ScheduledTask.Triggers |
                        Where-Object {
                            $_.CimClass.CimClassName -in
                            "MSFT_TaskBootTrigger",
                            "MSFT_TaskLogonTrigger"
                        }
                )

                if (
                    $StartupTriggers.Count -gt 0 -and
                    $ScheduledTask.State -ne "Disabled"
                ) {

                    $StartupTasks +=
                        $ScheduledTask
                }
            }
        }
        catch {
            $StartupTasks = @()
        }

        $WindowsSystemStartupTasks = @(
            $StartupTasks |
                Where-Object {
                    $_.TaskPath -like "\Microsoft\Windows\*"
                }
        )

        $OtherStartupTasks = @(
            $StartupTasks |
                Where-Object {
                    $_.TaskPath -notlike "\Microsoft\Windows\*"
                }
        )

        $StartupLoadItems =
            $StartupApplications.Count +
            $OtherStartupTasks.Count

        $ReportContent += "Startup Health"
        $ReportContent += "--------------"

        $ReportContent +=
            "Startup Apps        : $($StartupApplications.Count)"

        $ReportContent +=
            "Windows Tasks       : $($WindowsSystemStartupTasks.Count)"

        $ReportContent +=
            "Other Startup Tasks : $($OtherStartupTasks.Count)"

        $ReportContent +=
            "Startup Load Items  : $StartupLoadItems"

        $ReportContent += ""

        #------------------------------------------------------
        # Driver & Device Health
        #------------------------------------------------------

        $PnPDevices = @(
            Get-CimInstance `
                -ClassName Win32_PnPEntity `
                -ErrorAction SilentlyContinue
        )

        $ProblemDevices = @(
            $PnPDevices |
                Where-Object {
                    $_.ConfigManagerErrorCode -ne 0
                }
        )

        $DisabledDevices = @(
            $ProblemDevices |
                Where-Object {
                    $_.ConfigManagerErrorCode -eq 22
                }
        )

        $ActiveProblemDevices = @(
            $ProblemDevices |
                Where-Object {
                    $_.ConfigManagerErrorCode -ne 22
                }
        )

        $ReportContent += "Driver & Device Health"
        $ReportContent += "----------------------"

        $ReportContent +=
            "Devices Detected    : $($PnPDevices.Count)"

        $ReportContent +=
            "Active Problems     : $($ActiveProblemDevices.Count)"

        $ReportContent +=
            "Disabled Devices    : $($DisabledDevices.Count)"

        $ReportContent += ""

        #------------------------------------------------------
        # TPM Health
        #------------------------------------------------------

        $TPMPresent = $false
        $TPMReady = $false
        $TPMEnabled = $false
        $TPMSpecification = "Unavailable"

        $TPMCommand =
            Get-Command `
                -Name Get-Tpm `
                -ErrorAction SilentlyContinue

        if ($TPMCommand) {

            try {

                $TPM =
                    Get-Tpm `
                        -ErrorAction Stop

                if ($TPM) {

                    $TPMPresent =
                        [bool]$TPM.TpmPresent

                    $TPMReady =
                        [bool]$TPM.TpmReady

                    $TPMEnabled =
                        [bool]$TPM.TpmEnabled
                }
            }
            catch {
                # Fall through to CIM query.
            }
        }

        try {

            $TPMCim =
                Get-CimInstance `
                    -Namespace "root\CIMV2\Security\MicrosoftTpm" `
                    -ClassName Win32_Tpm `
                    -ErrorAction Stop

            if ($TPMCim) {

                $TPMPresent = $true

                if ($TPMCim.SpecVersion) {
                    $TPMSpecification =
                        $TPMCim.SpecVersion
                }
            }
        }
        catch {
            # TPM may not exist or may be inaccessible.
        }

        $ReportContent += "TPM Health"
        $ReportContent += "----------"

        $ReportContent +=
            "TPM Present         : $TPMPresent"

        $ReportContent +=
            "TPM Ready           : $TPMReady"

        $ReportContent +=
            "TPM Enabled         : $TPMEnabled"

        $ReportContent +=
            "Specification      : $TPMSpecification"

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

        # Event Log assessment

        if ($EventErrorCount -gt 50) {

            $Issues +=
                "High number of Windows errors detected in the last 24 hours"
        }

        # Crash / BSOD assessment

        if (
            $BugCheckEvents.Count -gt 0 -or
            $RecentMinidumps.Count -gt 0
        ) {

            $Issues +=
                "Recent Windows crash or BSOD activity detected"
        }

        # Startup assessment

        if ($StartupLoadItems -ge 20) {

            $Issues +=
                "High user-impacting startup load detected"
        }

        # Driver / device assessment

        if ($ActiveProblemDevices.Count -gt 0) {

            $Issues +=
                "$($ActiveProblemDevices.Count) active device or driver problem(s) detected"
        }

        # TPM assessment

        if (-not $TPMPresent) {

            $Issues +=
                "Trusted Platform Module not detected"
        }
        elseif (
            -not $TPMEnabled -or
            -not $TPMReady
        ) {

            $Issues +=
                "Trusted Platform Module is not fully ready"
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