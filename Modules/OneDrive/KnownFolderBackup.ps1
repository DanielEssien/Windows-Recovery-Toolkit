###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : KnownFolderBackup.ps1
# Purpose    : Displays OneDrive Known Folder Backup status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays OneDrive Known Folder Backup status.

.DESCRIPTION
Checks the current Windows Desktop, Documents, and Pictures
folder locations and determines whether they are located inside
a configured OneDrive synchronization root.

.EXAMPLE
Show-OneDriveKnownFolderBackup

.OUTPUTS
None

.NOTES
This function is read-only.

A folder located inside a OneDrive sync root indicates that the
known folder is redirected into OneDrive, but does not independently
confirm that every file is fully synchronized.
#>

function Show-OneDriveKnownFolderBackup {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Known Folder Backup Status"

    Write-Info "Collecting OneDrive Known Folder Backup information..."

    $StartTime = Get-Date

    try {

        #
        # Detect configured OneDrive sync roots
        #
        $AccountRoot = "HKCU:\Software\Microsoft\OneDrive\Accounts"

        $SyncRoots = @()

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

                        $SyncRoots += $AccountData.UserFolder

                    }

                }
                catch {

                    continue

                }
            }
        }

        $SyncRoots = @(
            $SyncRoots |
                Select-Object -Unique
        )

        #
        # Read current known-folder paths
        #
        $UserShellFoldersPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"

        $UserShellFolders = Get-ItemProperty `
            -Path $UserShellFoldersPath `
            -ErrorAction Stop

        $KnownFolders = @(
            [PSCustomObject]@{
                Name = "Desktop"
                Path = [Environment]::ExpandEnvironmentVariables(
                    $UserShellFolders.Desktop
                )
            },
            [PSCustomObject]@{
                Name = "Documents"
                Path = [Environment]::ExpandEnvironmentVariables(
                    $UserShellFolders.Personal
                )
            },
            [PSCustomObject]@{
                Name = "Pictures"
                Path = [Environment]::ExpandEnvironmentVariables(
                    $UserShellFolders.'My Pictures'
                )
            }
        )

        #
        # Assess each known folder
        #
        $BackedUpFolders = 0

        Write-BlankLine
        Write-Property "Configured Sync Roots" $SyncRoots.Count

        foreach ($Folder in $KnownFolders) {

            Show-Section $Folder.Name

            $FolderPath = $Folder.Path
            $FolderExists = $false
            $InsideOneDrive = $false
            $MatchedRoot = $null

            if (-not [string]::IsNullOrWhiteSpace($FolderPath)) {

                $FolderExists = Test-Path -Path $FolderPath

                foreach ($SyncRoot in $SyncRoots) {

                    if ([string]::IsNullOrWhiteSpace($SyncRoot)) {
                        continue
                    }

                    try {

                        $NormalizedFolder = [System.IO.Path]::GetFullPath(
                            $FolderPath
                        ).TrimEnd('\')

                        $NormalizedRoot = [System.IO.Path]::GetFullPath(
                            $SyncRoot
                        ).TrimEnd('\')

                        if ($NormalizedFolder -eq $NormalizedRoot -or
                            $NormalizedFolder.StartsWith(
                                "$NormalizedRoot\",
                                [System.StringComparison]::OrdinalIgnoreCase
                            )) {

                            $InsideOneDrive = $true
                            $MatchedRoot = $SyncRoot
                            break

                        }

                    }
                    catch {

                        continue

                    }
                }
            }

            if (-not [string]::IsNullOrWhiteSpace($FolderPath)) {
                Write-Property "Current Path" $FolderPath
            }
            else {
                Write-Property "Current Path" "Unavailable"
            }

            Write-Property "Folder Available" `
                $(if ($FolderExists) { "Yes" } else { "No" })

            if ($InsideOneDrive) {

                Write-Property "OneDrive Backup" "Detected"
                Write-Property "Sync Root" $MatchedRoot

                Write-Success "$($Folder.Name) is redirected into a OneDrive sync root."

                $BackedUpFolders++

            }
            else {

                Write-Property "OneDrive Backup" "Not detected"

                Write-WRTEWarning "$($Folder.Name) is not currently located inside a detected OneDrive sync root."

            }
        }

        Show-Section "Assessment"

        if ($SyncRoots.Count -eq 0) {

            Write-WRTEWarning "No configured OneDrive synchronization roots were detected."

            $Assessment = "OneDrive Not Configured"

        }
        elseif ($BackedUpFolders -eq $KnownFolders.Count) {

            Write-Success "Desktop, Documents, and Pictures are all redirected into OneDrive."
            Write-Info "This does not independently confirm that every file is fully synchronized."

            $Assessment = "Known Folder Backup Detected"

        }
        elseif ($BackedUpFolders -eq 0) {

            Write-WRTEWarning "None of the monitored known folders are redirected into OneDrive."

            $Assessment = "Known Folder Backup Not Detected"

        }
        else {

            Write-WRTEWarning "Only some monitored known folders are redirected into OneDrive."

            $Assessment = "Partial Known Folder Backup"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Folders Checked" $KnownFolders.Count
        Write-Property "Folders in OneDrive" $BackedUpFolders
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "OneDrive Known Folder Backup completed. Assessment: $Assessment. Sync Roots: $($SyncRoots.Count). Folders Checked: $($KnownFolders.Count). Folders in OneDrive: $BackedUpFolders. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve OneDrive Known Folder Backup status."
        Write-Info "Error: $ErrorMessage"

        Write-Log "OneDrive Known Folder Backup failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}