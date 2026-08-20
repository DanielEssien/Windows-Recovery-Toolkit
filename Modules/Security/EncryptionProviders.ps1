###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : EncryptionProviders.ps1
# Purpose    : Detects supported third-party disk encryption products.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Detects supported third-party disk encryption providers.

.DESCRIPTION
Checks installed applications and Windows services for known
third-party disk encryption products.

.EXAMPLE
Get-ThirdPartyEncryptionProvider

.OUTPUTS
PSCustomObject or null

.NOTES
Provider detection does not confirm that a volume is currently encrypted.
If multiple supported providers are detected, the first matching provider
in the configured provider list is returned.
#>

function Get-ThirdPartyEncryptionProvider {

    [CmdletBinding()]
    param()

    $Providers = @(
        @{
            Name = "ESET Full Disk Encryption"
            AppPatterns = @(
                "^ESET Full Disk Encryption$"
            )
            ServicePatterns = @(
                "^efdeais$",
                "^efdesrv$",
                "ESET FDE"
            )
        },
        @{
            Name = "Sophos Device Encryption"
            AppPatterns = @(
                "Sophos.*Encryption"
            )
            ServicePatterns = @(
                "Sophos.*Encryption"
            )
        },
        @{
            Name = "McAfee / Trellix Drive Encryption"
            AppPatterns = @(
                "McAfee.*Drive Encryption",
                "Trellix.*Drive Encryption"
            )
            ServicePatterns = @(
                "McAfee.*Encryption",
                "Trellix.*Encryption"
            )
        },
        @{
            Name = "Symantec Endpoint Encryption"
            AppPatterns = @(
                "Symantec.*Encryption",
                "Broadcom.*Encryption"
            )
            ServicePatterns = @(
                "Symantec.*Encryption"
            )
        },
        @{
            Name = "Check Point Full Disk Encryption"
            AppPatterns = @(
                "Check Point.*Encryption",
                "Check Point.*Full Disk"
            )
            ServicePatterns = @(
                "Check Point.*Encryption"
            )
        },
        @{
            Name = "VeraCrypt"
            AppPatterns = @(
                "^VeraCrypt$"
            )
            ServicePatterns = @(
                "^VeraCrypt$"
            )
        }
    )

    $Services = @(
        Get-Service -ErrorAction SilentlyContinue
    )

    $UninstallPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $InstalledApps = @(
        Get-ItemProperty `
            -Path $UninstallPaths `
            -ErrorAction SilentlyContinue |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_.DisplayName)
            }
    )

    foreach ($Provider in $Providers) {

        $MatchedServices = @(
            $Services |
                Where-Object {

                    $Matched = $false

                    foreach ($Pattern in $Provider.ServicePatterns) {

                        if ($_.Name -match $Pattern -or
                            $_.DisplayName -match $Pattern) {

                            $Matched = $true
                            break
                        }
                    }

                    $Matched
                }
        )

        $MatchedApps = @(
            $InstalledApps |
                Where-Object {

                    $Matched = $false

                    foreach ($Pattern in $Provider.AppPatterns) {

                        if ($_.DisplayName -match $Pattern) {

                            $Matched = $true
                            break
                        }
                    }

                    $Matched
                }
        )

        if ($MatchedServices.Count -gt 0 -or
            $MatchedApps.Count -gt 0) {

            $DetectionSources = @()

            if ($MatchedServices.Count -gt 0) {
                $DetectionSources += "Service"
            }

            if ($MatchedApps.Count -gt 0) {
                $DetectionSources += "Installed Application"
            }

            $RunningServices = @(
                $MatchedServices |
                    Where-Object {
                        $_.Status -eq "Running"
                    }
            )

            $ProductName = $null
            $Version = $null

            if ($MatchedApps.Count -gt 0) {
                $Version = $MatchedApps[0].DisplayVersion
                $ProductName = $MatchedApps[0].DisplayName
            }

            return [PSCustomObject]@{
                Name             = $Provider.Name
                ProductName      = $ProductName
                Version          = $Version
                DetectionSources = $DetectionSources
                ServicesDetected = $MatchedServices.Count
                ServicesRunning  = $RunningServices.Count
            }
        }
    }

    return $null
}