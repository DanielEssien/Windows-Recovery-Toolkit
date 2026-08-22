###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : ProcessLookup.ps1
# Purpose    : Searches for and displays Windows process details.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Searches for a Windows process.

.DESCRIPTION
Prompts for a process name and displays matching running
processes including process ID, CPU time, memory usage,
start time, and executable path where available.

.EXAMPLE
Find-WRTEProcess

.OUTPUTS
None

.NOTES
This function is read-only and does not stop or modify processes.
#>

function Find-WRTEProcess {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Process Lookup"

    $ProcessName =
        (Read-Host "Enter process name").Trim()

    if ([string]::IsNullOrWhiteSpace($ProcessName)) {

        Write-WRTEWarning "A process name is required."

        Show-Footer
        Wait-WRTE
        return

    }

    Write-Info "Searching for matching processes..."

    $StartTime = Get-Date

    try {

        #------------------------------------------------------
        # Process Search
        #------------------------------------------------------

        $Processes = @(
            Get-Process `
                -ErrorAction SilentlyContinue |
            Where-Object {
                $_.ProcessName -like "*$ProcessName*"
            } |
            Sort-Object `
                -Property ProcessName, Id
        )

        #------------------------------------------------------
        # No Matches
        #------------------------------------------------------

        if ($Processes.Count -eq 0) {

            Write-BlankLine

            Write-WRTEWarning `
                "No running process matching '$ProcessName' was found."

            Write-Log `
                "Process lookup completed. Query: $ProcessName. Matches: 0." `
                -Level INFO

        }
        else {

            #--------------------------------------------------
            # Results
            #--------------------------------------------------

            Write-BlankLine
            Show-Section "Results"

            Write-Property `
                "Processes Found" `
                $Processes.Count

            $ProcessNumber = 1

            $ProcessesToDisplay = @(
                $Processes |
                    Select-Object -First 10
            )

            foreach ($Process in $ProcessesToDisplay) {

                Show-Section `
                    "Process $ProcessNumber"

                Write-Property `
                    "Name" `
                    $Process.ProcessName

                Write-Property `
                    "Process ID" `
                    $Process.Id

                $MemoryMB =
                    [math]::Round(
                        $Process.WorkingSet64 / 1MB,
                        2
                    )

                Write-Property `
                    "Memory Usage" `
                    ("{0} MB" -f $MemoryMB)

                $CpuTime =
                    if ($null -ne $Process.CPU) {
                        [math]::Round(
                            $Process.CPU,
                            2
                        )
                    }
                    else {
                        "Unavailable"
                    }

                Write-Property `
                    "CPU Time" `
                    $(if ($CpuTime -eq "Unavailable") {
                        $CpuTime
                    }
                    else {
                        "$CpuTime sec"
                    })

                try {

                    $ProcessStartTime =
                        $Process.StartTime

                    Write-Property `
                        "Start Time" `
                        $ProcessStartTime.ToString(
                            "yyyy-MM-dd HH:mm:ss"
                        )

                }
                catch {

                    Write-Property `
                        "Start Time" `
                        "Unavailable"

                }

                try {

                    $ExecutablePath =
                        $Process.Path

                    if (
                        [string]::IsNullOrWhiteSpace(
                            $ExecutablePath
                        )
                    ) {

                        Write-Property `
                            "Executable Path" `
                            "Unavailable"

                    }
                    else {

                        Write-Property `
                            "Executable Path" `
                            $ExecutablePath

                    }

                }
                catch {

                    Write-Property `
                        "Executable Path" `
                        "Access denied or unavailable"

                }

                $ProcessNumber++

            }

            if ($Processes.Count -gt $ProcessesToDisplay.Count) {

                Write-Info `
                    "$($Processes.Count - $ProcessesToDisplay.Count) additional matching processes were not displayed."

            }

            #--------------------------------------------------
            # Assessment
            #--------------------------------------------------

            Show-Section "Assessment"

            if ($Processes.Count -eq 1) {

                Write-Success `
                    "One matching running process was found."

            }
            else {

                Write-Info `
                    "$($Processes.Count) matching running processes were found."

            }

            $Duration =
                (Get-Date) - $StartTime

            Write-BlankLine

            Write-Property `
                "Execution Time" `
                ("{0:N2} sec" -f $Duration.TotalSeconds)

            Write-Log `
                ("Process lookup completed. Query: {0}. Matches: {1}. Duration: {2:N2} seconds." `
                -f $ProcessName,
                   $Processes.Count,
                   $Duration.TotalSeconds) `
                -Level INFO

        }

    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEError `
            "Unable to complete the process lookup."

        Write-Info `
            "Error: $ErrorMessage"

        Write-Log `
            "Process lookup failed. Query: $ProcessName. $ErrorMessage" `
            -Level ERROR

    }

    Show-Footer
    Wait-WRTE
}