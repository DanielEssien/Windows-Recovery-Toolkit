###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Startup.ps1
# Purpose    : Analyzes Windows startup applications,
#              automatic services, and startup/logon tasks.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Windows startup diagnostics.

.DESCRIPTION
Collects startup applications, automatic services, and
scheduled tasks configured to run at startup or user logon.

The function is read-only and does not disable, remove,
or modify startup items.

.EXAMPLE
Show-StartupDiagnostics

.OUTPUTS
None

.NOTES
This function is read-only.
#>

function Show-StartupDiagnostics {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Startup Diagnostics"

    Write-Info "Collecting Windows startup information..."

    $StartTime = Get-Date

    try {

        #------------------------------------------------------
        # Startup Applications
        #------------------------------------------------------

        $StartupApplications = @()

        $RunLocations = @(
            @{
                Path  = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
                Scope = "Current User"
            },
            @{
                Path  = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
                Scope = "Local Machine"
            },
            @{
                Path  = "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
                Scope = "Local Machine (32-bit)"
            }
        )

        foreach ($Location in $RunLocations) {

            if (-not (Test-Path $Location.Path)) {
                continue
            }

            try {

                $Properties =
                    Get-ItemProperty `
                        -Path $Location.Path `
                        -ErrorAction Stop

                foreach ($Property in $Properties.PSObject.Properties) {

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
                        [PSCustomObject]@{
                            Name    = $Property.Name
                            Command = [string]$Property.Value
                            Source  = $Location.Scope
                        }
                }
            }
            catch {

                Write-Log `
                    ("Unable to inspect startup registry path {0}: {1}" `
                    -f $Location.Path, $_.Exception.Message) `
                    -Level WARNING
            }
        }

        #------------------------------------------------------
        # Startup Folders
        #------------------------------------------------------

        $StartupFolders = @(
            @{
                Path =
                    Join-Path `
                        $env:APPDATA `
                        "Microsoft\Windows\Start Menu\Programs\Startup"

                Scope = "Current User Startup Folder"
            },
            @{
                Path =
                    Join-Path `
                        $env:ProgramData `
                        "Microsoft\Windows\Start Menu\Programs\Startup"

                Scope = "All Users Startup Folder"
            }
        )

        foreach ($Folder in $StartupFolders) {

            if (-not (Test-Path $Folder.Path)) {
                continue
            }

            $Items = @(
                Get-ChildItem `
                    -Path $Folder.Path `
                    -File `
                    -ErrorAction SilentlyContinue
            )

            foreach ($Item in $Items) {

                $StartupApplications +=
                    [PSCustomObject]@{
                        Name    = $Item.Name
                        Command = $Item.FullName
                        Source  = $Folder.Scope
                    }
            }
        }

        $StartupApplications = @(
            $StartupApplications |
                Sort-Object Name, Source
        )

        #------------------------------------------------------
        # Automatic Services
        #------------------------------------------------------

        $AutomaticServices = @(
            Get-CimInstance `
                -ClassName Win32_Service `
                -ErrorAction SilentlyContinue |
            Where-Object {
                $_.StartMode -eq "Auto"
            } |
            Sort-Object DisplayName
        )

        #------------------------------------------------------
        # Startup / Logon Scheduled Tasks
        #------------------------------------------------------

        $StartupTasks = @()

        try {

            $Tasks = @(
                Get-ScheduledTask `
                    -ErrorAction Stop
            )

            foreach ($Task in $Tasks) {

                $RelevantTriggers = @(
                    $Task.Triggers |
                        Where-Object {
                            $_.CimClass.CimClassName -in
                            "MSFT_TaskBootTrigger",
                            "MSFT_TaskLogonTrigger"
                        }
                )

                if ($RelevantTriggers.Count -gt 0) {

                    $TriggerTypes = @(
                        $RelevantTriggers |
                            ForEach-Object {

                                switch (
                                    $_.CimClass.CimClassName
                                ) {

                                    "MSFT_TaskBootTrigger" {
                                        "Startup"
                                    }

                                    "MSFT_TaskLogonTrigger" {
                                        "Logon"
                                    }

                                    default {
                                        "Other"
                                    }
                                }
                            }
                    ) -join ", "

                    $StartupTasks +=
                        [PSCustomObject]@{
                            Name       = $Task.TaskName
                            Path       = $Task.TaskPath
                            State      = $Task.State
                            Trigger    = $TriggerTypes
                        }
                }
            }

            $StartupTasks = @(
                $StartupTasks |
                    Sort-Object Name
            )
        }
        catch {

            Write-Log `
                ("Unable to inspect scheduled startup tasks: {0}" `
                -f $_.Exception.Message) `
                -Level WARNING
        }

        $EnabledStartupTasks = @(
            $StartupTasks |
                Where-Object {
                    $_.State -ne "Disabled"
                }
        )

        $DisabledStartupTasks = @(
            $StartupTasks |
                Where-Object {
                    $_.State -eq "Disabled"
                }
        )

        $MicrosoftStartupTasks = @(
            $EnabledStartupTasks |
                Where-Object {
                    $_.Path -like "\Microsoft\Windows\*"
                }
        )

        $ThirdPartyStartupTasks = @(
            $EnabledStartupTasks |
                Where-Object {
                    $_.Path -notlike "\Microsoft\Windows\*"
                }
        )

        #------------------------------------------------------
        # Summary
        #------------------------------------------------------

        Show-Section "Summary"

        Write-Property `
            "Startup Applications" `
            $StartupApplications.Count

        Write-Property `
            "Automatic Services" `
            $AutomaticServices.Count

        Write-Property `
            "Windows System Tasks" `
            $MicrosoftStartupTasks.Count

        Write-Property `
            "Other Startup Tasks" `
            $ThirdPartyStartupTasks.Count

        Write-Property `
            "Disabled Startup Tasks" `
            $DisabledStartupTasks.Count

        $StartupLoadItems =
            $StartupApplications.Count +
            $ThirdPartyStartupTasks.Count

        Write-Property `
            "Startup Load Items" `
            $StartupLoadItems
        
        #------------------------------------------------------
        # Startup Applications
        #------------------------------------------------------

        Show-Section "Startup Applications"

        if ($StartupApplications.Count -eq 0) {

            Write-Success `
                "No startup applications were detected."

        }
        else {

            $ApplicationsToDisplay = @(
                $StartupApplications |
                    Select-Object -First 10
            )

            foreach ($Application in $ApplicationsToDisplay) {

                Write-Property `
                    "Name" `
                    $Application.Name

                Write-Property `
                    "Source" `
                    $Application.Source

                $Command =
                    if ($Application.Command) {
                        $Application.Command.Trim()
                    }
                    else {
                        "Unavailable"
                    }

                if ($Command.Length -gt 180) {

                    $Command =
                        $Command.Substring(0, 180) + "..."
                }

                Write-Property `
                    "Command" `
                    $Command

                Write-BlankLine
            }

            if (
                $StartupApplications.Count -gt
                $ApplicationsToDisplay.Count
            ) {

                Write-Info `
                    "$($StartupApplications.Count - $ApplicationsToDisplay.Count) additional startup applications were not displayed."
            }
        }

        #------------------------------------------------------
        # Automatic Services
        #------------------------------------------------------

        Show-Section "Automatic Services"

        if ($AutomaticServices.Count -eq 0) {

            Write-Info `
                "No automatic Windows services were detected."

        }
        else {

            $ServicesToDisplay = @(
                $AutomaticServices |
                    Select-Object -First 10
            )

            foreach ($Service in $ServicesToDisplay) {

                Write-Property `
                    "Service" `
                    $Service.DisplayName

                Write-Property `
                    "Name" `
                    $Service.Name

                Write-Property `
                    "State" `
                    $Service.State

                Write-Property `
                    "Account" `
                    $Service.StartName

                Write-BlankLine
            }

            if (
                $AutomaticServices.Count -gt
                $ServicesToDisplay.Count
            ) {

                Write-Info `
                    "$($AutomaticServices.Count - $ServicesToDisplay.Count) additional automatic services were not displayed."
            }
        }

        #------------------------------------------------------
        # Startup / Logon Tasks
        #------------------------------------------------------

        Show-Section "Startup / Logon Tasks"

        if ($StartupTasks.Count -eq 0) {

            Write-Success `
                "No scheduled startup or logon tasks were detected."

        }
        else {

            $TasksToDisplay = @(
                $StartupTasks |
                    Sort-Object `
                        @{
                            Expression = {
                                if (
                                    $_.State -ne "Disabled" -and
                                    $_.Path -notlike "\Microsoft\Windows\*"
                                ) {
                                    0
                                }
                                elseif (
                                    $_.State -ne "Disabled"
                                ) {
                                    1
                                }
                                else {
                                    2
                                }
                            }
                        },
                        Name |
                    Select-Object -First 10
            )

            foreach ($Task in $TasksToDisplay) {

                Write-Property `
                    "Task" `
                    $Task.Name

                Write-Property `
                    "Path" `
                    $Task.Path

                Write-Property `
                    "Trigger" `
                    $Task.Trigger

                Write-Property `
                    "State" `
                    $Task.State

                Write-BlankLine
            }

            if (
                $StartupTasks.Count -gt
                $TasksToDisplay.Count
            ) {

                Write-Info `
                    "$($StartupTasks.Count - $TasksToDisplay.Count) additional startup tasks were not displayed."
            }
        }

        #------------------------------------------------------
        # Assessment
        #------------------------------------------------------

        Show-Section "Assessment"

        if ($StartupLoadItems -lt 10) {

            $Assessment =
                "Startup configuration appears relatively light."

            Write-Success $Assessment

        }
        elseif ($StartupLoadItems -lt 20) {

            $Assessment =
                "A moderate number of user-impacting startup items were detected."

            Write-Info $Assessment

        }
        else {

            $Assessment =
                "A high number of user-impacting startup items were detected. Review may improve startup performance."

            Write-WRTEWarning $Assessment
        }

        #------------------------------------------------------
        # Completion
        #------------------------------------------------------

        $Duration =
            (Get-Date) - $StartTime

        Write-Log `
            ("Startup Diagnostics completed. Applications: {0}. Automatic Services: {1}. Windows System Tasks: {2}. Other Startup Tasks: {3}. Disabled Startup Tasks: {4}. Startup Load Items: {5}. Assessment: {6}. Duration: {7:N2} seconds." `
            -f $StartupApplications.Count,
                $AutomaticServices.Count,
                $MicrosoftStartupTasks.Count,
                $ThirdPartyStartupTasks.Count,
                $DisabledStartupTasks.Count,
                $StartupLoadItems,
                $Assessment,
                $Duration.TotalSeconds) `
            -Level INFO

    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEWarning `
            "Unable to collect startup diagnostics."

        Write-Info "Error: $ErrorMessage"

        Write-Log `
            "Startup Diagnostics failed. $ErrorMessage" `
            -Level ERROR
    }

    Show-Footer
    Wait-WRTE
}