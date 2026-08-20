###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : SyncStatus.ps1
# Purpose    : Displays OneDrive synchronization status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays OneDrive synchronization status.

.DESCRIPTION
Retrieves configured OneDrive accounts, synchronization root
paths, process state, and basic availability information for
the current user.

.EXAMPLE
Show-OneDriveSyncStatus

.OUTPUTS
None

.NOTES
This function is read-only.

OneDrive does not expose all synchronization state information
through a stable public PowerShell interface. WRTE therefore
reports observable client and synchronization-root information
without claiming that all files are fully synchronized.
#>

function Show-OneDriveSyncStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "OneDrive Sync Client Status"

    Write-Info "Collecting OneDrive synchronization information..."

    $StartTime = Get-Date

    try {

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

        $Accounts = @()

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

                    $UserFolder = $AccountData.UserFolder

                    $FolderAvailable = $false

                    if (-not [string]::IsNullOrWhiteSpace($UserFolder)) {
                        $FolderAvailable = Test-Path -Path $UserFolder
                    }

                    $IsConfigured = -not [string]::IsNullOrWhiteSpace($UserFolder)

                    $Accounts += [PSCustomObject]@{
                        Name            = $AccountKey.PSChildName
                        UserFolder      = $UserFolder
                        IsConfigured    = $IsConfigured
                        FolderAvailable = $FolderAvailable
                    }

                }
                catch {

                    continue

                }
            }
        }

        $ConfiguredAccounts = @(
            $Accounts |
                Where-Object {
                    $_.IsConfigured
                }
        )

        $UnconfiguredProfiles = @(
            $Accounts |
                Where-Object {
                    -not $_.IsConfigured
                }
        )

        #
        # Display
        #
        Write-BlankLine
        Show-Section "Sync Client"

        Write-Property "Process Status" $ProcessStatus
        Write-Property "Profiles Detected" $Accounts.Count
        Write-Property "Configured Accounts" $ConfiguredAccounts.Count

        if ($ProcessStatus -eq "Running") {

            Write-Success "OneDrive sync client is running."

        }
        else {

            Write-WRTEWarning "OneDrive sync client is not currently running."

        }

        if ($Accounts.Count -gt 0) {

            $AccountNumber = 1
            $AvailableRoots = 0

            foreach ($Account in $Accounts) {

                Show-Section "Account $AccountNumber"

                Write-Property "Account Type" $Account.Name

                if ($Account.IsConfigured) {

                    Write-Property "Sync Root" $Account.UserFolder

                    if ($Account.FolderAvailable) {

                        Write-Property "Root Status" "Available"
                        Write-Success "OneDrive synchronization root is accessible."

                        $AvailableRoots++

                    }
                    else {

                        Write-Property "Root Status" "Unavailable"
                        Write-WRTEWarning "OneDrive synchronization root could not be accessed."

                    }

                }
                else {

                    Write-Property "Sync Root" "Not configured"
                    Write-Property "Profile Status" "Inactive or Unconfigured"

                    Write-Info "This OneDrive profile does not currently have a synchronization root configured."

                }

                $AccountNumber++
            }

        }
        else {

            $AvailableRoots = 0

            Write-BlankLine
            Write-Info "No OneDrive account profiles were detected."

        }

        Show-Section "Assessment"

        if ($ConfiguredAccounts.Count -eq 0) {

            Write-WRTEWarning "No configured OneDrive synchronization account was detected."

            $Assessment = "Not Configured"

        }
        elseif ($ProcessStatus -ne "Running") {

            Write-WRTEWarning "OneDrive is configured but the sync client is not running."

            $Assessment = "Client Not Running"

        }
        elseif ($AvailableRoots -eq $ConfiguredAccounts.Count) {

            Write-Success "OneDrive is running and all configured synchronization roots are accessible."
            Write-Info "This does not confirm that every file is fully synchronized."

            if ($UnconfiguredProfiles.Count -gt 0) {

                Write-Info "$($UnconfiguredProfiles.Count) additional OneDrive profile(s) were detected without an active sync root."

            }

            $Assessment = "Operational"

        }
        else {

            Write-WRTEWarning "OneDrive is running but one or more configured synchronization roots are unavailable."

            $Assessment = "Degraded"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "OneDrive Sync Status completed. Assessment: $Assessment. Process: $ProcessStatus. Profiles: $($Accounts.Count). Configured Accounts: $($ConfiguredAccounts.Count). Available Roots: $AvailableRoots. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve OneDrive synchronization status."
        Write-Info "Error: $ErrorMessage"

        Write-Log "OneDrive Sync Status failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}