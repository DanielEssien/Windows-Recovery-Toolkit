###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : CrashDump.ps1
# Purpose    : Detects recent Windows crash events and dump
#              files for BSOD troubleshooting.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Windows crash and dump information.

.DESCRIPTION
Checks for recent Windows bugcheck events, minidump files,
and the system MEMORY.DMP file.

The function performs read-only checks and does not modify
Windows crash dump configuration or dump files.

.EXAMPLE
Show-CrashDumpDiagnostics

.OUTPUTS
None

.NOTES
This function is read-only.
#>

function Show-CrashDumpDiagnostics {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Crash & BSOD Diagnostics"

    Write-Info "Collecting Windows crash and dump information..."

    $StartTime = Get-Date
    $Since = (Get-Date).AddDays(-30)

    try {

        #------------------------------------------------------
        # Paths
        #------------------------------------------------------

        $MinidumpPath =
            Join-Path $env:SystemRoot "Minidump"

        $MemoryDumpPath =
            Join-Path $env:SystemRoot "MEMORY.DMP"

        #------------------------------------------------------
        # Minidump Files
        #------------------------------------------------------

        $MinidumpFiles = @()

        if (Test-Path $MinidumpPath) {

            $MinidumpFiles = @(
                Get-ChildItem `
                    -Path $MinidumpPath `
                    -Filter "*.dmp" `
                    -File `
                    -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending
            )
        }

        #------------------------------------------------------
        # Full Memory Dump
        #------------------------------------------------------

        $MemoryDump = $null

        if (Test-Path $MemoryDumpPath) {

            try {

                $MemoryDump =
                    Get-Item `
                        -Path $MemoryDumpPath `
                        -ErrorAction Stop

            }
            catch {

                Write-Log `
                    ("Unable to inspect MEMORY.DMP: {0}" `
                    -f $_.Exception.Message) `
                    -Level WARNING
            }
        }

        #------------------------------------------------------
        # BugCheck Events
        #------------------------------------------------------

        $BugCheckEvents = @(
            Get-WinEvent `
                -FilterHashtable @{
                    LogName   = "System"
                    Id        = 1001
                    StartTime = $Since
                } `
                -ErrorAction SilentlyContinue |
            Where-Object {
                $_.ProviderName -eq
                    "Microsoft-Windows-WER-SystemErrorReporting"
            } |
            Sort-Object TimeCreated -Descending
        )

        #------------------------------------------------------
        # Summary
        #------------------------------------------------------

        Show-Section "Summary"

        Write-Property `
            "Time Window" `
            "Last 30 days"

        Write-Property `
            "BugCheck Events" `
            $BugCheckEvents.Count

        Write-Property `
            "Minidump Files" `
            $MinidumpFiles.Count

        Write-Property `
            "MEMORY.DMP" `
            $(if ($MemoryDump) {
                "Detected"
            }
            else {
                "Not detected"
            })

        #------------------------------------------------------
        # Recent BugCheck Events
        #------------------------------------------------------

        Show-Section "Recent BugCheck Events"

        if ($BugCheckEvents.Count -eq 0) {

            Write-Success `
                "No recent Windows bugcheck events were detected."

        }
        else {

            $EventsToDisplay = @(
                $BugCheckEvents |
                    Select-Object -First 5
            )

            foreach ($Event in $EventsToDisplay) {

                Write-Property `
                    "Time" `
                    $Event.TimeCreated

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

                if ($Message.Length -gt 220) {

                    $Message =
                        $Message.Substring(0, 220) + "..."
                }

                Write-Property `
                    "Details" `
                    $Message

                Write-BlankLine
            }

            if ($BugCheckEvents.Count -gt $EventsToDisplay.Count) {

                Write-Info `
                    "$($BugCheckEvents.Count - $EventsToDisplay.Count) additional BugCheck events were not displayed."
            }
        }

        #------------------------------------------------------
        # Minidump Files
        #------------------------------------------------------

        Show-Section "Minidump Files"

        if ($MinidumpFiles.Count -eq 0) {

            Write-Info "No Windows minidump files were detected."

        }
        else {

            $DumpsToDisplay = @(
                $MinidumpFiles |
                    Select-Object -First 5
            )

            foreach ($Dump in $DumpsToDisplay) {

                $SizeMB =
                    [math]::Round(
                        $Dump.Length / 1MB,
                        2
                    )

                Write-Property `
                    "File" `
                    $Dump.Name

                Write-Property `
                    "Created" `
                    $Dump.LastWriteTime

                $DumpAgeDays =
                    [math]::Floor(
                        ((Get-Date) - $Dump.LastWriteTime).TotalDays
                    )

                Write-Property `
                    "Age" `
                    ("{0} days" -f $DumpAgeDays)

                Write-Property `
                    "Size" `
                    ("{0} MB" -f $SizeMB)

                Write-BlankLine
            }

            if ($MinidumpFiles.Count -gt $DumpsToDisplay.Count) {

                Write-Info `
                    "$($MinidumpFiles.Count - $DumpsToDisplay.Count) additional minidump files were not displayed."
            }
        }

        #------------------------------------------------------
        # Full Memory Dump
        #------------------------------------------------------

        Show-Section "Full Memory Dump"

        if ($MemoryDump) {

            $MemoryDumpSizeGB =
                [math]::Round(
                    $MemoryDump.Length / 1GB,
                    2
                )

            Write-Property `
                "File" `
                $MemoryDump.FullName

            Write-Property `
                "Last Modified" `
                $MemoryDump.LastWriteTime

            Write-Property `
                "Size" `
                ("{0} GB" -f $MemoryDumpSizeGB)

        }
        else {

            Write-Info `
                "No MEMORY.DMP file was detected."
        }

        $RecentMinidumps = @(
            $MinidumpFiles |
                Where-Object {
                    $_.LastWriteTime -ge $Since
                }
        )

        #------------------------------------------------------
        # Assessment
        #------------------------------------------------------

        Show-Section "Assessment"

        if (
            $BugCheckEvents.Count -eq 0 -and
            $RecentMinidumps.Count -eq 0 -and
            -not $MemoryDump
        ) {

            if ($MinidumpFiles.Count -gt 0) {

                $Assessment =
                    "No recent BSOD activity was detected. Historical minidump files are present."

                Write-Info $Assessment

            }
            else {

                $Assessment =
                    "No recent BSOD or crash dump evidence was detected."

                Write-Success $Assessment
            }

        }
        elseif (
            $BugCheckEvents.Count -gt 0 -or
            $RecentMinidumps.Count -gt 0
        ) {

            $Assessment =
                "Recent Windows crash activity was detected. Crash dump analysis may be required."

            Write-WRTEWarning $Assessment

        }
        else {

            $Assessment =
                "Crash dump evidence was detected, but no recent BugCheck event was found."

            Write-Info $Assessment
        }

        #------------------------------------------------------
        # Completion
        #------------------------------------------------------

        $Duration =
            (Get-Date) - $StartTime

        Write-Log `
            ("Crash Diagnostics completed. BugCheck Events: {0}. Minidumps: {1}. MEMORY.DMP: {2}. Assessment: {3}. Duration: {4:N2} seconds." `
            -f $BugCheckEvents.Count,
                $MinidumpFiles.Count,
                [bool]$MemoryDump,
                $Assessment,
                $Duration.TotalSeconds) `
            -Level INFO

    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEWarning `
            "Unable to collect Windows crash information."

        Write-Info "Error: $ErrorMessage"

        Write-Log `
            "Crash Diagnostics failed. $ErrorMessage" `
            -Level ERROR
    }

    Show-Footer
    Wait-WRTE
}