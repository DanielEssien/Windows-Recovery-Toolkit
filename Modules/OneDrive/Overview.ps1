###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Overview.ps1
# Purpose    : Displays a summary of OneDrive client status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays a summary of Microsoft OneDrive status.

.DESCRIPTION
Retrieves OneDrive installation information, client version,
process state, and basic account configuration information.

.EXAMPLE
Show-OneDriveOverview

.OUTPUTS
None

.NOTES
This function is read-only and does not modify OneDrive
configuration or synchronization settings.
#>

function Show-OneDriveOverview {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "OneDrive Overview"

    Write-Info "Collecting OneDrive information..."

    $StartTime = Get-Date

    try {

        #
        # Detect OneDrive executable
        #
        $OneDrivePaths = @(
            "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe",
            "$env:ProgramFiles\Microsoft OneDrive\OneDrive.exe",
            "${env:ProgramFiles(x86)}\Microsoft OneDrive\OneDrive.exe"
        )

        $OneDrivePath = $null

        foreach ($Path in $OneDrivePaths) {

            if (-not [string]::IsNullOrWhiteSpace($Path) -and
                (Test-Path -Path $Path)) {

                $OneDrivePath = $Path
                break
            }
        }

        #
        # Client version
        #
        $OneDriveVersion = "Unavailable"

        if ($null -ne $OneDrivePath) {

            try {

                $VersionInfo = Get-Item `
                    -Path $OneDrivePath `
                    -ErrorAction Stop

                if (-not [string]::IsNullOrWhiteSpace(
                        $VersionInfo.VersionInfo.FileVersion
                    )) {

                    $OneDriveVersion = $VersionInfo.VersionInfo.FileVersion

                }

            }
            catch {

                $OneDriveVersion = "Unavailable"

            }
        }

        #
        # Process state
        #
        $OneDriveProcesses = @(
            Get-Process `
                -Name "OneDrive" `
                -ErrorAction SilentlyContinue
        )

        $ProcessStatus = if ($OneDriveProcesses.Count -gt 0) {
            "Running"
        }
        else {
            "Not Running"
        }

        #
        # Account configuration
        #
        $AccountRoot = "HKCU:\Software\Microsoft\OneDrive\Accounts"

        $AccountKeys = @()
        $ConfiguredAccounts = 0

        if (Test-Path -Path $AccountRoot) {

            $AccountKeys = @(
                Get-ChildItem `
                    -Path $AccountRoot `
                    -ErrorAction SilentlyContinue
            )

            foreach ($AccountKey in $AccountKeys) {

                try {

                    $AccountData = Get-ItemProperty `
                        -Path $AccountKey.PSPath `
                        -ErrorAction Stop

                    if (-not [string]::IsNullOrWhiteSpace(
                            $AccountData.UserFolder
                        )) {

                        $ConfiguredAccounts++

                    }

                }
                catch {

                    continue

                }
            }
        }

        #
        # Display
        #
        Write-BlankLine
        Show-Section "Client"

        if ($null -ne $OneDrivePath) {

            Write-Property "Installed" "Yes"
            Write-Property "Executable" $OneDrivePath
            Write-Property "Version" $OneDriveVersion

        }
        else {

            Write-Property "Installed" "Not detected"
            Write-Property "Version" "Unavailable"

        }

        Show-Section "Runtime"

        Write-Property "Process Status" $ProcessStatus

        if ($ProcessStatus -eq "Running") {

            Write-Success "OneDrive client is currently running."

        }
        elseif ($null -ne $OneDrivePath) {

            Write-WRTEWarning "OneDrive is installed but is not currently running."

        }
        else {

            Write-Info "OneDrive client installation was not detected."

        }

        Show-Section "Accounts"

        Write-Property "Profiles Detected" $AccountKeys.Count
        Write-Property "Configured Accounts" $ConfiguredAccounts

        if ($ConfiguredAccounts -gt 0) {

            Write-Success "OneDrive account configuration was detected."

        }
        else {

            Write-Info "No OneDrive account configuration was detected for the current user."

        }

        Show-Section "Assessment"

        if ($null -eq $OneDrivePath) {

            Write-WRTEWarning "OneDrive client was not detected."

            $Assessment = "Not Detected"

        }
        elseif ($ProcessStatus -eq "Running" -and
                $ConfiguredAccounts -gt 0) {

            Write-Success "OneDrive appears to be installed, running, and configured."

            $Assessment = "Available"

        }
        elseif ($ConfiguredAccounts -eq 0) {

            Write-WRTEWarning "OneDrive is installed but no configured account was detected."

            $Assessment = "Not Configured"

        }
        else {

            Write-WRTEWarning "OneDrive is installed but is not currently running."

            $Assessment = "Not Running"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "OneDrive Overview completed. Assessment: $Assessment. Process: $ProcessStatus. Profiles: $($AccountKeys.Count). Configured Accounts: $ConfiguredAccounts. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve OneDrive information."
        Write-Info "Error: $ErrorMessage"

        Write-Log "OneDrive Overview failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}