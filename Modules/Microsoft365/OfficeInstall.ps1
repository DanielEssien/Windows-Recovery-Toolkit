# OfficeInstall.ps1

###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : OfficeInstall.ps1
# Purpose    : Displays Microsoft Office installation details.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Microsoft Office installation information.

.DESCRIPTION
Detects locally installed Microsoft Office or Microsoft 365 Apps
and displays available installation details including deployment
type, product identifiers, version, architecture, installation
path, and Click-to-Run configuration.

The function checks Click-to-Run configuration first and performs
additional registry checks for legacy MSI-based Office installations.

.EXAMPLE
Show-OfficeInstallStatus

.OUTPUTS
None

.NOTES
This function is read-only.
#>

function Show-OfficeInstallStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Office Installation"

    Write-Info "Detecting Microsoft Office installation..."

    $StartTime = Get-Date

    try {

        #------------------------------------------------------
        # Variables
        #------------------------------------------------------

        $OfficeDetected = $false
        $DeploymentType = $null

        $ClickToRunPath =
            "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"

        $OfficeConfig = $null

        #------------------------------------------------------
        # Click-to-Run Detection
        #------------------------------------------------------

        if (Test-Path $ClickToRunPath) {

            try {

                $OfficeConfig = Get-ItemProperty `
                    -Path $ClickToRunPath `
                    -ErrorAction Stop

                $OfficeDetected = $true
                $DeploymentType = "Click-to-Run"
            }
            catch {

                Write-Log `
                    ("Unable to read Office Click-to-Run configuration: {0}" `
                    -f $_.Exception.Message) `
                    -Level WARNING
            }
        }

        #------------------------------------------------------
        # Click-to-Run Information
        #------------------------------------------------------

        if ($OfficeConfig) {

            Write-Property "Office Installed" "Yes"
            Write-Property "Deployment Type" $DeploymentType

            if ($OfficeConfig.ProductReleaseIds) {

                $Products =
                    $OfficeConfig.ProductReleaseIds `
                    -replace ",", ", "

                Write-Property "Product ID" $Products
            }

            $OfficeVersion = if ($OfficeConfig.VersionToReport) {

                $OfficeConfig.VersionToReport

            }
            elseif ($OfficeConfig.ClientVersionToReport) {

                $OfficeConfig.ClientVersionToReport

            }
            else {

                $null

            }

            if ($OfficeVersion) {

                Write-Property `
                    "Version" `
                    $OfficeVersion

            }

            if ($OfficeConfig.Platform) {

                Write-Property `
                    "Architecture" `
                    $OfficeConfig.Platform
            }

            if ($OfficeConfig.InstallPath) {

                Write-Property `
                    "Install Path" `
                    $OfficeConfig.InstallPath
            }

            if ($OfficeConfig.UpdateChannel) {

                Write-Property `
                    "Update Channel" `
                    $OfficeConfig.UpdateChannel
            }

            if ($OfficeConfig.CDNBaseUrl) {

                Write-Property `
                    "CDN Source" `
                    $OfficeConfig.CDNBaseUrl
            }

            if ($OfficeConfig.AudienceId) {

                Write-Property `
                    "Audience ID" `
                    $OfficeConfig.AudienceId
            }

            if ($null -ne $OfficeConfig.UpdatesEnabled) {

                Write-Property `
                    "Updates Enabled" `
                    $OfficeConfig.UpdatesEnabled
            }

            if ($OfficeConfig.UpdateDeadline) {

                Write-Property `
                    "Update Deadline" `
                    $OfficeConfig.UpdateDeadline
            }
        }

        #------------------------------------------------------
        # Legacy MSI Detection
        #------------------------------------------------------

        if (-not $OfficeDetected) {

            Write-Info "Click-to-Run installation not detected."
            Write-Info "Checking for legacy MSI installations..."

            $OfficeRegistryPaths = @(

                "HKLM:\SOFTWARE\Microsoft\Office\16.0\Common\InstallRoot",
                "HKLM:\SOFTWARE\Microsoft\Office\15.0\Common\InstallRoot",
                "HKLM:\SOFTWARE\Microsoft\Office\14.0\Common\InstallRoot",

                "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\16.0\Common\InstallRoot",
                "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\15.0\Common\InstallRoot",
                "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\14.0\Common\InstallRoot"
            )

            foreach ($RegistryPath in $OfficeRegistryPaths) {

                if (Test-Path $RegistryPath) {

                    try {

                        $LegacyOffice =
                            Get-ItemProperty `
                                -Path $RegistryPath `
                                -ErrorAction Stop

                        $OfficeDetected = $true
                        $DeploymentType = "MSI"

                        Write-Property "Office Installed" "Yes"
                        Write-Property "Deployment Type" $DeploymentType

                        if ($LegacyOffice.Path) {

                            Write-Property `
                                "Install Path" `
                                $LegacyOffice.Path
                        }

                        break
                    }
                    catch {

                        Write-Log `
                            ("Unable to read Office MSI registry path {0}: {1}" `
                            -f $RegistryPath, $_.Exception.Message) `
                            -Level WARNING
                    }
                }
            }
        }

        #------------------------------------------------------
        # Executable Detection
        #------------------------------------------------------

        if ($OfficeDetected) {

            Show-Section "Detected Applications"

            $OfficeApplications = @(

                @{
                    Name = "Microsoft Word"
                    File = "WINWORD.EXE"
                },

                @{
                    Name = "Microsoft Excel"
                    File = "EXCEL.EXE"
                },

                @{
                    Name = "Microsoft PowerPoint"
                    File = "POWERPNT.EXE"
                },

                @{
                    Name = "Microsoft Outlook"
                    File = "OUTLOOK.EXE"
                },

                @{
                    Name = "Microsoft Access"
                    File = "MSACCESS.EXE"
                },

                @{
                    Name = "Microsoft Publisher"
                    File = "MSPUB.EXE"
                },

                @{
                    Name = "Microsoft OneNote"
                    File = "ONENOTE.EXE"
                }
            )

            $PossibleOfficePaths = @(

                "$env:ProgramFiles\Microsoft Office\root\Office16",

                "${env:ProgramFiles(x86)}\Microsoft Office\root\Office16",

                "$env:ProgramFiles\Microsoft Office\Office16",

                "${env:ProgramFiles(x86)}\Microsoft Office\Office16",

                "$env:ProgramFiles\Microsoft Office\Office15",

                "${env:ProgramFiles(x86)}\Microsoft Office\Office15"
            )

            foreach ($Application in $OfficeApplications) {

                $DetectedApplication = $false

                foreach ($OfficePath in $PossibleOfficePaths) {

                    if ([string]::IsNullOrWhiteSpace($OfficePath)) {
                        continue
                    }

                    $ExecutablePath =
                        Join-Path `
                            -Path $OfficePath `
                            -ChildPath $Application.File

                    if (Test-Path $ExecutablePath) {

                        $DetectedApplication = $true
                        break
                    }
                }

                if ($DetectedApplication) {

                    Write-Property `
                        $Application.Name `
                        "Installed"
                }
                else {

                    Write-Property `
                        $Application.Name `
                        "Not detected"
                }
            }
        }

        #------------------------------------------------------
        # No Office Detected
        #------------------------------------------------------

        if (-not $OfficeDetected) {

            Write-Property "Office Installed" "Not detected"

            Write-WRTEWarning `
                "Microsoft Office or Microsoft 365 Apps was not detected."
        }

        #------------------------------------------------------
        # Completion
        #------------------------------------------------------

        $Duration =
            (Get-Date) - $StartTime

        Write-Log `
            ("Office installation check completed in {0:N2} seconds." `
            -f $Duration.TotalSeconds) `
            -Level INFO
    }
    catch {

        Write-WRTEWarning `
            "Unable to determine Microsoft Office installation status."

        Write-Log `
            ("Office installation check failed: {0}" `
            -f $_.Exception.Message) `
            -Level ERROR
    }

    Show-Footer
    Wait-WRTE
}