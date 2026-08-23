###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : EventLogs.ps1
# Purpose    : Analyzes recent critical and error events from
#              Windows System and Application event logs.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays recent Windows event log errors.

.DESCRIPTION
Analyzes Critical and Error events recorded in the Windows
System and Application event logs during the previous 24 hours.

The function is read-only and does not modify event logs or
Windows configuration.

.EXAMPLE
Show-EventLogDiagnostics

.OUTPUTS
None

.NOTES
This function is read-only.
#>

function Show-EventLogDiagnostics {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Event Log Diagnostics"

    Write-Info "Analyzing recent Windows event log errors..."

    $StartTime = Get-Date
    $Since = (Get-Date).AddHours(-24)

    try {

        $SystemEvents = @(
            Get-WinEvent `
                -FilterHashtable @{
                    LogName   = "System"
                    Level     = 1, 2
                    StartTime = $Since
                } `
                -ErrorAction SilentlyContinue |
            Sort-Object TimeCreated -Descending
        )

        $ApplicationEvents = @(
            Get-WinEvent `
                -FilterHashtable @{
                    LogName   = "Application"
                    Level     = 1, 2
                    StartTime = $Since
                } `
                -ErrorAction SilentlyContinue |
            Sort-Object TimeCreated -Descending
        )

        $AllEvents = @(
            $SystemEvents
            $ApplicationEvents
        )

        $IssuePatterns = @(
            $AllEvents |
                Group-Object {
                    "{0}|{1}" -f $_.ProviderName, $_.Id
                } |
                Sort-Object Count -Descending
        )

        $RecurringPatterns = @(
                $IssuePatterns |
                    Where-Object {
                        $_.Count -gt 1
                    }
        )
        
        #------------------------------------------------------
        # Summary
        #------------------------------------------------------
        Show-Section "Summary"

        Write-Property `
            "Time Window" `
            "Last 24 hours"

        Write-Property `
            "System Events" `
            $SystemEvents.Count

        Write-Property `
            "Application Events" `
            $ApplicationEvents.Count

        Write-Property `
            "Total Events" `
            $AllEvents.Count
        
        #------------------------------------------------------
        # Recurring Issue Patterns
        #------------------------------------------------------
        Show-Section "Recurring Issue Patterns"

        if ($RecurringPatterns.Count -eq 0) {

            Write-Success "No recurring issue patterns were detected."

        }
        else {

            $PatternsToDisplay = @(
                $RecurringPatterns |
                    Select-Object -First 10
            )

            foreach ($Pattern in $PatternsToDisplay) {

                $SampleEvent =
                    $Pattern.Group |
                        Select-Object -First 1

                Write-Property `
                    "Provider / Event ID" `
                    ("{0} / {1}" -f
                        $SampleEvent.ProviderName,
                        $SampleEvent.Id)

                Write-Property `
                    "Occurrences" `
                    $Pattern.Count

                Write-BlankLine
            }

            if ($RecurringPatterns.Count -gt $PatternsToDisplay.Count) {

                Write-Info `
                    "$($RecurringPatterns.Count - $PatternsToDisplay.Count) additional recurring issue patterns were not displayed."
            }

        }

        #------------------------------------------------------
        # System Events
        #------------------------------------------------------

        Show-Section "Recent System Errors"

        if ($SystemEvents.Count -eq 0) {

            Write-Success `
                "No critical or error events were detected in the System log."

        }
        else {

            $SystemEventsToDisplay = @(
                $SystemEvents |
                    Select-Object -First 10
            )

            foreach ($Event in $SystemEventsToDisplay) {

                Write-Property `
                    "Time" `
                    $Event.TimeCreated

                Write-Property `
                    "Level" `
                    $Event.LevelDisplayName

                Write-Property `
                    "Event ID" `
                    $Event.Id

                Write-Property `
                    "Provider" `
                    $Event.ProviderName

                $Message =
                    if ($Event.Message) {
                        ($Event.Message -replace '\s+', ' ').Trim()
                    }
                    else {
                        "No event message available."
                    }

                if ($Message.Length -gt 180) {
                    $Message =
                        $Message.Substring(0, 180) + "..."
                }

                Write-Property `
                    "Message" `
                    $Message

                Write-BlankLine
            }

            if (
                $SystemEvents.Count -gt
                $SystemEventsToDisplay.Count
            ) {

                Write-Info `
                    "$($SystemEvents.Count - $SystemEventsToDisplay.Count) additional System events were not displayed."
            }
        }

        #------------------------------------------------------
        # Application Events
        #------------------------------------------------------

        Show-Section "Recent Application Errors"

        if ($ApplicationEvents.Count -eq 0) {

            Write-Success `
                "No critical or error events were detected in the Application log."

        }
        else {

            $ApplicationEventsToDisplay = @(
                $ApplicationEvents |
                    Select-Object -First 10
            )

            foreach ($Event in $ApplicationEventsToDisplay) {

                Write-Property `
                    "Time" `
                    $Event.TimeCreated

                Write-Property `
                    "Level" `
                    $Event.LevelDisplayName

                Write-Property `
                    "Event ID" `
                    $Event.Id

                Write-Property `
                    "Provider" `
                    $Event.ProviderName

                $Message =
                    if ($Event.Message) {
                        ($Event.Message -replace '\s+', ' ').Trim()
                    }
                    else {
                        "No event message available."
                    }

                if ($Message.Length -gt 180) {
                    $Message =
                        $Message.Substring(0, 180) + "..."
                }

                Write-Property `
                    "Message" `
                    $Message

                Write-BlankLine
            }

            if (
                $ApplicationEvents.Count -gt
                $ApplicationEventsToDisplay.Count
            ) {

                Write-Info `
                    "$($ApplicationEvents.Count - $ApplicationEventsToDisplay.Count) additional Application events were not displayed."
            }
        }

        #------------------------------------------------------
        # Assessment
        #------------------------------------------------------

        Show-Section "Assessment"

        $TotalEvents =
            $AllEvents.Count

        $UniquePatterns =
            $IssuePatterns.Count

        if ($TotalEvents -eq 0) {

            $Assessment =
                "No recent critical or error events detected."

            Write-Success $Assessment

        }
        elseif ($UniquePatterns -le 3 -and $TotalEvents -gt 5) {

            $Assessment =
                "Multiple events were detected, but they are concentrated in a small number of recurring issue patterns."

            Write-WRTEWarning $Assessment

        }
        elseif ($UniquePatterns -le 5) {

            $Assessment =
                "Several recurring Windows issue patterns were detected. Review may be required."

            Write-WRTEWarning $Assessment

        }
        else {

            $Assessment =
                "Multiple distinct Windows error patterns were detected. Further investigation is recommended."

            Write-WRTEWarning $Assessment
        }

        #------------------------------------------------------
        # Completion
        #------------------------------------------------------

        $Duration =
            (Get-Date) - $StartTime

        Write-Log `
            ("Event Log Diagnostics completed. System Events: {0}. Application Events: {1}. Unique Patterns: {2}. Assessment: {3}. Duration: {4:N2} seconds." `
            -f $SystemEvents.Count,
                $ApplicationEvents.Count,
                $UniquePatterns,
                $Assessment,
                $Duration.TotalSeconds) `
            -Level INFO
    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEWarning `
            "Unable to analyze Windows event logs."

        Write-Info "Error: $ErrorMessage"

        Write-Log `
            "Event Log Diagnostics failed. $ErrorMessage" `
            -Level ERROR
    }

    Show-Footer
    Wait-WRTE
}