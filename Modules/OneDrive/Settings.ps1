###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Settings.ps1
# Purpose    : Opens Microsoft OneDrive and provides access guidance.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Opens Microsoft OneDrive.

.DESCRIPTION
Detects and opens the installed OneDrive client and provides
guidance for accessing OneDrive settings from the notification area.

.EXAMPLE
Open-OneDriveClient

.OUTPUTS
None

.NOTES
This function does not modify OneDrive configuration directly.
#>

function Open-OneDriveClient {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Open OneDrive"

    Write-Info "Locating Microsoft OneDrive..."

    $StartTime = Get-Date

    try {

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

        if ($null -eq $OneDrivePath) {

            Write-WRTEError "OneDrive client could not be detected."

            Write-Log "Open OneDrive failed. OneDrive executable not detected." `
                -Level "ERROR"

            Show-Footer
            Wait-WRTE
            return
        }

        Write-BlankLine
        Write-Property "Executable" $OneDrivePath

        Show-Section "OneDrive"

        Write-Info "Opening Microsoft OneDrive..."

        Start-Process `
            -FilePath $OneDrivePath `
            -ErrorAction Stop

        Write-Success "OneDrive client opened."
        Write-Info "To access settings, select the OneDrive cloud icon in the notification area, then choose Settings."

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "OneDrive client opened. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to open OneDrive."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Open OneDrive failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}