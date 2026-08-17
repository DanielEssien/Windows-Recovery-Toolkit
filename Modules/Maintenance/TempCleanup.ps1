###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : TempCleanup.ps1
# Purpose    : Safely removes temporary files.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Removes temporary files from safe Windows temp locations.

.DESCRIPTION
Calculates temporary file usage, asks for confirmation,
removes accessible files from user and Windows temp folders,
and reports the amount of space recovered.

.EXAMPLE
Start-TempCleanup

.OUTPUTS
None

.NOTES
Administrator privileges improve cleanup coverage.
Locked or inaccessible files are skipped.
#>

function Start-TempCleanup {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Temporary Files Cleanup"

    Write-Info "Scanning temporary file locations..."

    $StartTime = Get-Date

    $TempPaths = @(
        $env:TEMP,
        "$env:SystemRoot\Temp"
    ) |
    Where-Object {
        -not [string]::IsNullOrWhiteSpace($_)
    } |
    Select-Object -Unique

    try {

        $FilesBefore = @(
            foreach ($Path in $TempPaths) {

                if (Test-Path $Path) {

                    Get-ChildItem `
                        -Path $Path `
                        -File `
                        -Recurse `
                        -Force `
                        -ErrorAction SilentlyContinue
                }
            }
        )

        $SizeBefore = (
            $FilesBefore |
                Measure-Object -Property Length -Sum
        ).Sum

        if ($null -eq $SizeBefore) {
            $SizeBefore = 0
        }

        Write-BlankLine
        Write-Property "Files Detected" $FilesBefore.Count
        Write-Property "Potential Cleanup" `
            ("{0:N2} MB" -f ($SizeBefore / 1MB))

        Write-BlankLine
        Write-WRTEWarning "Temporary files currently in use will be skipped."

        $Confirmation = (
            Read-Host "Proceed with temporary file cleanup? (Y/N)"
        ).Trim().ToUpper()

        if ($Confirmation -ne "Y") {

            Write-Info "Temporary file cleanup cancelled."

            Write-Log "Temporary Files Cleanup cancelled by user."

            Show-Footer
            Wait-WRTE
            return
        }

        Write-BlankLine
        Write-Info "Removing temporary files..."

        foreach ($Path in $TempPaths) {

            if (-not (Test-Path $Path)) {
                continue
            }

            Get-ChildItem `
                -Path $Path `
                -Force `
                -ErrorAction SilentlyContinue |
                Remove-Item `
                    -Recurse `
                    -Force `
                    -ErrorAction SilentlyContinue
        }

        $FilesAfter = @(
            foreach ($Path in $TempPaths) {

                if (Test-Path $Path) {

                    Get-ChildItem `
                        -Path $Path `
                        -File `
                        -Recurse `
                        -Force `
                        -ErrorAction SilentlyContinue
                }
            }
        )

        $SizeAfter = (
            $FilesAfter |
                Measure-Object -Property Length -Sum
        ).Sum

        if ($null -eq $SizeAfter) {
            $SizeAfter = 0
        }

        $FreedBytes = $SizeBefore - $SizeAfter

        if ($FreedBytes -lt 0) {
            $FreedBytes = 0
        }

        $RemovedFiles = $FilesBefore.Count - $FilesAfter.Count

        if ($RemovedFiles -lt 0) {
            $RemovedFiles = 0
        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Show-Section "Cleanup Result"

        Write-Success "Temporary file cleanup completed."

        Write-Property "Files Removed" $RemovedFiles
        Write-Property "Files Remaining" $FilesAfter.Count
        Write-Property "Space Recovered" `
            ("{0:N2} MB" -f ($FreedBytes / 1MB))

        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)
        Write-Log "Temporary Files Cleanup completed. Files Removed: $RemovedFiles. Space Recovered: $([Math]::Round($FreedBytes / 1MB, 2)) MB. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        Write-WRTEError "Unable to complete temporary file cleanup."
        Write-WRTEError $_.Exception.Message

        Write-Log "Temporary Files Cleanup failed. $($_.Exception.Message)" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}