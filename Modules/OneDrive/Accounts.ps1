###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Accounts.ps1
# Purpose    : Displays configured OneDrive account information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays configured OneDrive account information.

.DESCRIPTION
Retrieves OneDrive account profiles for the current user and
displays available account, tenant, and synchronization-root
information.

.EXAMPLE
Show-OneDriveAccounts

.OUTPUTS
None

.NOTES
This function is read-only.
Some account properties may be unavailable depending on the
OneDrive client version and account type.
#>

function Show-OneDriveAccounts {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "OneDrive Account Information"

    Write-Info "Collecting OneDrive account information..."

    $StartTime = Get-Date

    try {

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

                    $IsConfigured = -not [string]::IsNullOrWhiteSpace($UserFolder)

                    $FolderAvailable = $false

                    if ($IsConfigured) {
                        $FolderAvailable = Test-Path -Path $UserFolder
                    }

                    $Accounts += [PSCustomObject]@{
                        ProfileName     = $AccountKey.PSChildName
                        DisplayName     = $AccountData.DisplayName
                        UserEmail       = $AccountData.UserEmail
                        TenantName      = $AccountData.TenantName
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

        $ConfiguredAccounts = 0

        Write-BlankLine

        if ($Accounts.Count -eq 0) {

            Write-WRTEWarning "No OneDrive account profiles were detected."

            $Assessment = "No Accounts Detected"

        }
        else {

            $AccountNumber = 1

            foreach ($Account in $Accounts) {

                Show-Section "Account $AccountNumber"

                Write-Property "Profile" $Account.ProfileName

                if (-not [string]::IsNullOrWhiteSpace(
                        $Account.DisplayName
                    )) {

                    Write-Property "Display Name" $Account.DisplayName

                }

                if (-not [string]::IsNullOrWhiteSpace(
                        $Account.UserEmail
                    )) {

                    Write-Property "User" $Account.UserEmail

                }

                if (-not [string]::IsNullOrWhiteSpace(
                        $Account.TenantName
                    )) {

                    Write-Property "Organization" $Account.TenantName

                }

                if ($Account.IsConfigured) {

                    Write-Property "Sync Root" $Account.UserFolder

                    Write-Property "Root Status" `
                        $(if ($Account.FolderAvailable) {
                            "Available"
                        }
                        else {
                            "Unavailable"
                        })

                    Write-Success "OneDrive account is configured."

                    $ConfiguredAccounts++

                }
                else {

                    Write-Property "Sync Root" "Not configured"
                    Write-Property "Profile Status" "Inactive or Unconfigured"

                    Write-Info "This profile does not currently have a synchronization root configured."

                }

                $AccountNumber++
            }

            Show-Section "Assessment"

            if ($ConfiguredAccounts -eq $Accounts.Count) {

                Write-Success "All detected OneDrive account profiles are configured."

                $Assessment = "Configured"

            }
            elseif ($ConfiguredAccounts -gt 0) {

                Write-Success "$ConfiguredAccounts configured OneDrive account(s) were detected."
                Write-Info "One or more additional profiles are inactive or unconfigured."

                $Assessment = "Partially Configured"

            }
            else {

                Write-WRTEWarning "No active OneDrive account configuration was detected."

                $Assessment = "Not Configured"

            }

            Write-BlankLine
            Write-Property "Profiles Detected" $Accounts.Count
            Write-Property "Configured Accounts" $ConfiguredAccounts
        }

        $Elapsed = (Get-Date) - $StartTime

        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "OneDrive Account Information completed. Assessment: $Assessment. Profiles: $($Accounts.Count). Configured Accounts: $ConfiguredAccounts. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve OneDrive account information."
        Write-Info "Error: $ErrorMessage"

        Write-Log "OneDrive Account Information failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}