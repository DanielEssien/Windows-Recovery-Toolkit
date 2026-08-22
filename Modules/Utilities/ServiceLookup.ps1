###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : ServiceLookup.ps1
# Purpose    : Searches for and displays Windows service details.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Searches for Windows services.

.DESCRIPTION
Prompts for a service name or display name and displays matching
Windows services including service name, display name, status,
startup type, service account, description, and process ID where
available.

.EXAMPLE
Find-WRTEService

.OUTPUTS
None

.NOTES
This function is read-only and does not start, stop, or modify
Windows services.
#>

function Find-WRTEService {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Service Lookup"

    $ServiceQuery =
        (Read-Host "Enter service name or display name").Trim()

    if ([string]::IsNullOrWhiteSpace($ServiceQuery)) {

        Write-WRTEWarning "A service name or display name is required."

        Show-Footer
        Wait-WRTE
        return

    }

    Write-Info "Searching for matching services..."

    $StartTime = Get-Date

    try {

        #------------------------------------------------------
        # Service Search
        #------------------------------------------------------

        $Services = @(
            Get-CimInstance `
                -ClassName Win32_Service `
                -ErrorAction Stop |
            Where-Object {
                $_.Name -like "*$ServiceQuery*" -or
                $_.DisplayName -like "*$ServiceQuery*"
            } |
            Sort-Object `
                -Property DisplayName, Name
        )

        #------------------------------------------------------
        # No Matches
        #------------------------------------------------------

        if ($Services.Count -eq 0) {

            Write-BlankLine

            Write-WRTEWarning `
                "No service matching '$ServiceQuery' was found."

            Write-Log `
                "Service lookup completed. Query: $ServiceQuery. Matches: 0." `
                -Level INFO

        }
        else {

            #--------------------------------------------------
            # Results
            #--------------------------------------------------

            Write-BlankLine
            Show-Section "Results"

            Write-Property `
                "Services Found" `
                $Services.Count

            $ServicesToDisplay = @(
                $Services |
                    Select-Object -First 10
            )

            $ServiceNumber = 1

            foreach ($Service in $ServicesToDisplay) {

                Show-Section `
                    "Service $ServiceNumber"

                Write-Property `
                    "Service Name" `
                    $Service.Name

                Write-Property `
                    "Display Name" `
                    $Service.DisplayName

                Write-Property `
                    "Status" `
                    $Service.State

                Write-Property `
                    "Startup Type" `
                    $Service.StartMode

                if (
                    [string]::IsNullOrWhiteSpace(
                        $Service.StartName
                    )
                ) {

                    Write-Property `
                        "Service Account" `
                        "Unavailable"

                }
                else {

                    Write-Property `
                        "Service Account" `
                        $Service.StartName

                }

                if (
                    [string]::IsNullOrWhiteSpace(
                        $Service.Description
                    )
                ) {

                    Write-Property `
                        "Description" `
                        "Unavailable"

                }
                else {

                    Write-Property `
                        "Description" `
                        $Service.Description

                }

                if ($Service.ProcessId -gt 0) {

                    Write-Property `
                        "Process ID" `
                        $Service.ProcessId

                }
                else {

                    Write-Property `
                        "Process ID" `
                        "Not running"

                }

                $ServiceNumber++

            }

            if ($Services.Count -gt $ServicesToDisplay.Count) {

                Write-Info `
                    "$($Services.Count - $ServicesToDisplay.Count) additional matching services were not displayed."

            }

            #--------------------------------------------------
            # Assessment
            #--------------------------------------------------

            Show-Section "Assessment"

            $RunningServices = @(
                $Services |
                    Where-Object {
                        $_.State -eq "Running"
                    }
            )

            $StoppedServices = @(
                $Services |
                    Where-Object {
                        $_.State -eq "Stopped"
                    }
            )

            Write-Property `
                "Running" `
                $RunningServices.Count

            Write-Property `
                "Stopped" `
                $StoppedServices.Count

            if ($Services.Count -eq 1) {

                Write-Success `
                    "One matching service was found."

            }
            else {

                Write-Info `
                    "$($Services.Count) matching services were found."

            }

            #--------------------------------------------------
            # Completion
            #--------------------------------------------------

            $Duration =
                (Get-Date) - $StartTime

            Write-BlankLine

            Write-Property `
                "Execution Time" `
                ("{0:N2} sec" -f $Duration.TotalSeconds)

            Write-Log `
                ("Service lookup completed. Query: {0}. Matches: {1}. Running: {2}. Stopped: {3}. Duration: {4:N2} seconds." `
                -f $ServiceQuery,
                   $Services.Count,
                   $RunningServices.Count,
                   $StoppedServices.Count,
                   $Duration.TotalSeconds) `
                -Level INFO

        }

    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEError `
            "Unable to complete the service lookup."

        Write-Info `
            "Error: $ErrorMessage"

        Write-Log `
            "Service lookup failed. Query: $ServiceQuery. $ErrorMessage" `
            -Level ERROR

    }

    Show-Footer
    Wait-WRTE
}