###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : OneDrive.ps1
# Purpose    : Displays OneDrive diagnostic and support tools.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays the OneDrive menu.

.DESCRIPTION
Provides access to OneDrive diagnostic and support tools,
including client status, sync information, Known Folder Backup,
account detection, repair options, and client access.

.EXAMPLE
Show-OneDrive

.OUTPUTS
None
#>

function Show-OneDrive {

    [CmdletBinding()]
    param()

    do {

        Show-Banner
        Show-Section "OneDrive"

        Write-MenuItem "1" "OneDrive Overview"
        Write-MenuItem "2" "Sync Client Status"
        Write-MenuItem "3" "Known Folder Backup Status"
        Write-MenuItem "4" "Account Information"
        Write-MenuItem "5" "Repair OneDrive"
        Write-MenuItem "6" "Open OneDrive"

        Write-BlankLine
        Write-MenuItem "B" "Back"

        Show-Footer

        $Selection = (Read-Host "Select an option").Trim().ToUpper()

        switch ($Selection) {

            "1" { Show-OneDriveOverview }

            "2" { Show-OneDriveSyncStatus }

            "3" { Show-OneDriveKnownFolderBackup }

            "4" { Show-OneDriveAccounts }

            "5" { Repair-OneDrive }

            "6" { Open-OneDriveClient }

            "B" { return }

            default {
                Write-WRTEWarning "Invalid selection."
                Wait-WRTE
            }
        }

    } while ($true)
}