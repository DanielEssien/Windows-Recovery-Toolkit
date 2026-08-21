###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Teams.ps1
# Purpose    : Displays Microsoft Teams client status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Microsoft Teams client status.

.DESCRIPTION
Detects installed Microsoft Teams clients and reports available
installation, version, and process-state information.

The function checks for the current Microsoft Teams client and
legacy Teams installations where applicable.

.EXAMPLE
Show-TeamsStatus

.OUTPUTS
None

.NOTES
This function is read-only and does not modify Microsoft Teams
configuration or sign-in state.
#>

function Show-TeamsStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Microsoft Teams Status"

    Write-Info "Collecting Microsoft Teams information..."

    $StartTime = Get-Date

    try {

        $TeamsInstallations = @()

        #------------------------------------------------------
        # New Microsoft Teams
        #------------------------------------------------------
        try {

            $NewTeamsPackages = @(
                Get-AppxPackage `
                    -Name "MSTeams" `
                    -ErrorAction SilentlyContinue
            )

            foreach ($Package in $NewTeamsPackages) {

                $TeamsInstallations += [PSCustomObject]@{
                    ClientType = "New Teams"
                    Product    = $Package.Name
                    Version    = $Package.Version.ToString()
                    Path       = $Package.InstallLocation
                    Source     = "AppX"
                }

            }

        }
        catch {

            Write-Log `
                ("Unable to query Microsoft Teams AppX packages: {0}" `
                -f $_.Exception.Message) `
                -Level WARNING

        }

        #------------------------------------------------------
        # Installed application detection
        #------------------------------------------------------
        $UninstallPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        $InstalledApps = @(
            Get-ItemProperty `
                -Path $UninstallPaths `
                -ErrorAction SilentlyContinue |
                Where-Object {
                    -not [string]::IsNullOrWhiteSpace($_.DisplayName)
                }
        )

        $TeamsApps = @(
            $InstalledApps |
                Where-Object {
                    $_.DisplayName -eq "Microsoft Teams" -or
                    $_.DisplayName -eq "Teams Machine-Wide Installer"
                }
        )

        foreach ($App in $TeamsApps) {

            $ClientType = if (
                $App.DisplayName -match "Machine-Wide"
            ) {
                "Classic Teams Installer"
            }
            else {
                "Teams"
            }

            $Version = if (
                -not [string]::IsNullOrWhiteSpace($App.DisplayVersion)
            ) {
                $App.DisplayVersion
            }
            else {
                "Unavailable"
            }

            $InstallPath = if (
                -not [string]::IsNullOrWhiteSpace($App.InstallLocation)
            ) {
                $App.InstallLocation
            }
            else {
                "Unavailable"
            }

            $TeamsInstallations += [PSCustomObject]@{
                ClientType = $ClientType
                Product    = $App.DisplayName
                Version    = $Version
                Path       = $InstallPath
                Source     = "Installed Application"
            }

        }

        #------------------------------------------------------
        # Process state
        #------------------------------------------------------
        $TeamsProcesses = @(
            Get-Process `
                -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.ProcessName -in @(
                        "ms-teams",
                        "Teams"
                    )
                }
        )

        $ProcessStatus = if ($TeamsProcesses.Count -gt 0) {
            "Running"
        }
        else {
            "Not Running"
        }

        #------------------------------------------------------
        # Display
        #------------------------------------------------------
        Write-BlankLine
        Show-Section "Installation"

        if ($TeamsInstallations.Count -gt 0) {

            Write-Property "Installations Detected" $TeamsInstallations.Count

            $InstallationNumber = 1

            foreach ($Installation in $TeamsInstallations) {

                Show-Section "Teams Installation $InstallationNumber"

                Write-Property "Client Type" $Installation.ClientType
                Write-Property "Product" $Installation.Product
                Write-Property "Version" $Installation.Version
                Write-Property "Detection Source" $Installation.Source
                Write-Property "Install Path" $Installation.Path

                $InstallationNumber++

            }

        }
        else {

            Write-Property "Installed" "Not detected"

        }

        Show-Section "Runtime"

        Write-Property "Process Status" $ProcessStatus
        Write-Property "Processes Found" $TeamsProcesses.Count

        Show-Section "Assessment"

        if ($TeamsInstallations.Count -eq 0) {

            Write-WRTEWarning "Microsoft Teams client was not detected."
            $Assessment = "Not Detected"

        }
        elseif ($ProcessStatus -eq "Running") {

            Write-Success "Microsoft Teams is installed and currently running."
            $Assessment = "Available"

        }
        else {

            Write-Info "Microsoft Teams is installed but is not currently running."
            $Assessment = "Installed"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Microsoft Teams Status completed. Assessment: $Assessment. Installations: $($TeamsInstallations.Count). Processes: $($TeamsProcesses.Count). Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve Microsoft Teams status."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Microsoft Teams Status failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}