###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Security.ps1
# Purpose    : Displays Windows security diagnostic tools.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays the Security menu.

.DESCRIPTION
Provides access to Windows security status information,
including Microsoft Defender, Windows Firewall, BitLocker,
Secure Boot, and supported disk encryption providers.

.EXAMPLE
Show-Security

.OUTPUTS
None
#>

function Show-Security {

    [CmdletBinding()]
    param()

    do {

        Show-Banner
        Show-Section "Security"

        Write-MenuItem "1" "Security Overview"
        Write-MenuItem "2" "Microsoft Defender Status"
        Write-MenuItem "3" "Firewall Status"
        Write-MenuItem "4" "BitLocker Status"
        Write-MenuItem "5" "Secure Boot Status"
        Write-MenuItem "6" "Disk Encryption Status"
        Write-MenuItem "7" "TPM Status"

        Write-BlankLine
        Write-MenuItem "B" "Back"

        Show-Footer

        $Selection = (Read-Host "Select an option").Trim().ToUpper()

        switch ($Selection) {

            "1" { Show-SecurityOverview }

            "2" { Show-DefenderStatus }

            "3" { Show-FirewallStatus }

            "4" { Show-BitLockerStatus }

            "5" { Show-SecureBootStatus }

            "6" { Show-DiskEncryptionStatus }

            "7" { Show-TPMStatus }

            "B" { return }

            default {
                Write-WRTEWarning "Invalid selection."
                Wait-WRTE
            }
        }

    } while ($true)
}