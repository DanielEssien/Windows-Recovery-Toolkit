# Outlook.ps1

###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Outlook.ps1
# Purpose    : Displays Microsoft Outlook installation,
#              profile, process, and local data file status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Microsoft Outlook status.

.DESCRIPTION
Detects Microsoft Outlook installation information, executable
version, running process state, configured Outlook profiles,
default profile, and locally stored Outlook data files.

The function performs read-only checks and does not modify
Outlook profiles, mail data, or application settings.

.EXAMPLE
Show-OutlookStatus

.OUTPUTS
None

.NOTES
This function is read-only.

Outlook profile information is retrieved from the current user's
registry hive. PST and OST file discovery is limited to commonly
used Outlook storage locations.
#>

function Show-OutlookStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Outlook"

    Write-Info "Collecting Microsoft Outlook information..."

    $StartTime = Get-Date

    try {

        #------------------------------------------------------
        # Outlook Executable Detection
        #------------------------------------------------------

        $OutlookPaths = @(

            "$env:ProgramFiles\Microsoft Office\root\Office16\OUTLOOK.EXE",

            "${env:ProgramFiles(x86)}\Microsoft Office\root\Office16\OUTLOOK.EXE",

            "$env:ProgramFiles\Microsoft Office\Office16\OUTLOOK.EXE",

            "${env:ProgramFiles(x86)}\Microsoft Office\Office16\OUTLOOK.EXE",

            "$env:ProgramFiles\Microsoft Office\Office15\OUTLOOK.EXE",

            "${env:ProgramFiles(x86)}\Microsoft Office\Office15\OUTLOOK.EXE"
        )

        $OutlookPath =
            $OutlookPaths |
            Where-Object {
                $_ -and (Test-Path $_)
            } |
            Select-Object -First 1

        #------------------------------------------------------
        # Installation Information
        #------------------------------------------------------

        Show-Section "Installation"

        if ($OutlookPath) {

            Write-Property "Outlook Installed" "Yes"
            Write-Property "Executable Path" $OutlookPath

            try {

                $FileInfo =
                    Get-Item `
                        -Path $OutlookPath `
                        -ErrorAction Stop

                if ($FileInfo.VersionInfo.FileVersion) {

                    Write-Property `
                        "File Version" `
                        $FileInfo.VersionInfo.FileVersion
                }

                if ($FileInfo.VersionInfo.ProductVersion) {

                    Write-Property `
                        "Product Version" `
                        $FileInfo.VersionInfo.ProductVersion
                }
            }
            catch {

                Write-Log `
                    ("Unable to read Outlook executable information: {0}" `
                    -f $_.Exception.Message) `
                    -Level WARNING
            }
        }
        else {

            Write-Property "Outlook Installed" "Not detected"
        }

        #------------------------------------------------------
        # Outlook Process
        #------------------------------------------------------

        Show-Section "Process Status"

        $OutlookProcess = @(
            Get-Process `
                -Name OUTLOOK `
                -ErrorAction SilentlyContinue
        )

        if ($OutlookProcess) {

            Write-Property "Outlook Running" "Yes"

            $ProcessIds =
                $OutlookProcess.Id -join ", "

            Write-Property "Process ID" $ProcessIds
        }
        else {

            Write-Property "Outlook Running" "No"
        }

        #------------------------------------------------------
        # Outlook Profile Detection
        #------------------------------------------------------

        Show-Section "Profiles"

        $ProfileRootPaths = @(

            "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles",

            "HKCU:\Software\Microsoft\Office\15.0\Outlook\Profiles"
        )

        $ProfileRoot = $null

        foreach ($Path in $ProfileRootPaths) {

            if (Test-Path $Path) {

                $ProfileRoot = $Path
                break
            }
        }

        $ProfileNames = @()

        if ($ProfileRoot) {

            try {

                $ProfileNames = @(
                    Get-ChildItem `
                        -Path $ProfileRoot `
                        -ErrorAction Stop |
                    Select-Object -ExpandProperty PSChildName
                )

                Write-Property `
                    "Profiles Detected" `
                    $ProfileNames.Count

                if ($ProfileNames.Count -gt 0) {

                    Write-Property `
                        "Profile Names" `
                        ($ProfileNames -join ", ")

                }
                elseif ($OutlookPath) {

                    Write-Info `
                        "Outlook is installed, but no mail profile is configured for the current user."

                }
            }
            catch {

                Write-WRTEWarning `
                    "Unable to enumerate Outlook profiles."

                Write-Log `
                    ("Outlook profile enumeration failed: {0}" `
                    -f $_.Exception.Message) `
                    -Level WARNING
            }
        }
        else {

            Write-Property "Profiles Detected" "0"

            if ($OutlookPath) {

                Write-Info `
                    "Outlook is installed, but no mail profile is configured for the current user."

            }
            else {

                Write-Info `
                    "No Outlook profile registry key was detected for the current user."

            }
        }

        #------------------------------------------------------
        # Default Profile
        #------------------------------------------------------

        $OutlookPreferencePaths = @(

            "HKCU:\Software\Microsoft\Office\16.0\Outlook",

            "HKCU:\Software\Microsoft\Office\15.0\Outlook"
        )

        $DefaultProfile = $null

        foreach ($PreferencePath in $OutlookPreferencePaths) {

            if (-not (Test-Path $PreferencePath)) {
                continue
            }

            try {

                $OutlookSettings =
                    Get-ItemProperty `
                        -Path $PreferencePath `
                        -ErrorAction Stop

                if ($OutlookSettings.DefaultProfile) {

                    $DefaultProfile =
                        $OutlookSettings.DefaultProfile

                    break
                }
            }
            catch {

                Write-Log `
                    ("Unable to read Outlook settings from {0}: {1}" `
                    -f $PreferencePath, $_.Exception.Message) `
                    -Level WARNING
            }
        }

        if ($DefaultProfile) {

            Write-Property `
                "Default Profile" `
                $DefaultProfile
        }
        elseif ($ProfileNames.Count -eq 1) {

            Write-Property `
                "Default Profile" `
                $ProfileNames[0]
        }
        else {

            Write-Property `
                "Default Profile" `
                "Unable to determine"
        }

        #------------------------------------------------------
        # Local Outlook Data Files
        #------------------------------------------------------

        Show-Section "Local Data Files"

        $OutlookDataPaths = @(

            "$env:LOCALAPPDATA\Microsoft\Outlook",

            "$env:USERPROFILE\Documents\Outlook Files"
        )

        $OutlookDataFiles = @()

        foreach ($DataPath in $OutlookDataPaths) {

            if (-not (Test-Path $DataPath)) {
                continue
            }

            try {

                $Files =
                    Get-ChildItem `
                        -Path $DataPath `
                        -File `
                        -ErrorAction Stop |
                    Where-Object {
                        $_.Extension -in ".ost", ".pst"
                    }

                if ($Files) {

                    $OutlookDataFiles += $Files
                }
            }
            catch {

                Write-Log `
                    ("Unable to inspect Outlook data path {0}: {1}" `
                    -f $DataPath, $_.Exception.Message) `
                    -Level WARNING
            }
        }

        if ($OutlookDataFiles.Count -gt 0) {

            $PSTFiles = @(
                $OutlookDataFiles |
                    Where-Object {
                        $_.Extension -eq ".pst"
                    }
            )

            $OSTFiles = @(
                $OutlookDataFiles |
                    Where-Object {
                        $_.Extension -eq ".ost"
                    }
            )

            Write-Property `
                "PST Files" `
                $PSTFiles.Count

            Write-Property `
                "OST Files" `
                $OSTFiles.Count

            Write-Property `
                "Total Data Files" `
                $OutlookDataFiles.Count

            $TotalSize =
                ($OutlookDataFiles |
                    Measure-Object `
                        -Property Length `
                        -Sum).Sum

            if ($TotalSize) {

                $TotalSizeGB =
                    [math]::Round(
                        $TotalSize / 1GB,
                        2
                    )

                Write-Property `
                    "Total Data Size" `
                    ("{0} GB" -f $TotalSizeGB)
            }

            foreach ($DataFile in $OutlookDataFiles) {

                $SizeMB =
                    [math]::Round(
                        $DataFile.Length / 1MB,
                        2
                    )

                Write-Property `
                    $DataFile.Name `
                    ("{0} MB" -f $SizeMB)
            }
        }
        else {

            Write-Property "PST Files" "0"
            Write-Property "OST Files" "0"
            Write-Property "Total Data Files" "0"
        }

        #------------------------------------------------------
        # Summary
        #------------------------------------------------------

        Show-Section "Outlook Summary"

        if ($OutlookPath) {

            Write-Property "Installation State" "Installed"
        }
        else {

            Write-Property "Installation State" "Not detected"
        }

        if ($ProfileNames.Count -gt 0) {

            Write-Property "Profile State" "Configured"
        }
        else {

            Write-Property "Profile State" "No profile detected"
        }

        #------------------------------------------------------
        # Completion
        #------------------------------------------------------

        $Duration =
            (Get-Date) - $StartTime

        Write-Log `
            ("Outlook status check completed in {0:N2} seconds." `
            -f $Duration.TotalSeconds) `
            -Level INFO
    }
    catch {

        Write-WRTEWarning `
            "Unable to collect Microsoft Outlook information."

        Write-Log `
            ("Outlook status check failed: {0}" `
            -f $_.Exception.Message) `
            -Level ERROR
    }

    Show-Footer
    Wait-WRTE
}