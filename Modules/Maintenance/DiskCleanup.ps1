###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : DiskCleanup.ps1
# Purpose    : Launches Windows Disk Cleanup safely.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Launches Windows Disk Cleanup.

.DESCRIPTION
Opens the built-in Windows Disk Cleanup utility for the system
drive and allows the user to select which cleanup categories
should be removed.

.EXAMPLE
Start-DiskCleanup

.OUTPUTS
None

.NOTES
Launches the built-in Windows Disk Cleanup utility.
WRTE does not automatically select or remove cleanup categories.
The user remains in control of the cleanup process.
#>

function Start-DiskCleanup {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Disk Cleanup"

    Write-Info "Preparing Windows Disk Cleanup..."

    $StartTime = Get-Date

    $CleanMgrPath = Join-Path `
        -Path $env:SystemRoot `
        -ChildPath "System32\cleanmgr.exe"

    if (-not (Test-Path $CleanMgrPath)) {

        Write-WRTEError "Windows Disk Cleanup is not available on this system."

        Write-Log "Disk Cleanup unavailable. cleanmgr.exe was not found." `
            -Level "ERROR"

        Show-Footer
        Wait-WRTE
        return
    }

    $SystemDrive = $env:SystemDrive

    Write-BlankLine
    Write-Property "Target Drive" $SystemDrive

    Write-BlankLine
    Write-Info "Disk Cleanup will open in a separate Windows dialog."
    Write-Info "You will choose which categories should be removed."

    Write-WRTEWarning "Review the selected cleanup categories before confirming deletion."

    $Confirmation = (
        Read-Host "Open Windows Disk Cleanup now? (Y/N)"
    ).Trim().ToUpper()

    if ($Confirmation -ne "Y") {

        Write-Info "Disk Cleanup cancelled."

        Write-Log "Disk Cleanup cancelled by user."

        Show-Footer
        Wait-WRTE
        return
    }

    try {

        Write-BlankLine
        Write-Info "Opening Windows Disk Cleanup..."

        Start-Process `
            -FilePath $CleanMgrPath `
            -ArgumentList "/d $SystemDrive" `
            -ErrorAction Stop

        $Elapsed = (Get-Date) - $StartTime

        Write-Success "Windows Disk Cleanup opened successfully."

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Disk Cleanup launched successfully for $SystemDrive. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to launch Windows Disk Cleanup."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Disk Cleanup failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}