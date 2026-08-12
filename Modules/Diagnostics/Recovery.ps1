###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Recovery.ps1
# Purpose    : Retrieves Windows recovery environment
#              information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Windows recovery information.

.DESCRIPTION
Retrieves Windows Recovery Environment (WinRE) status and
configuration information using reagentc.

.EXAMPLE
Show-RecoveryInformation
#>

function Show-RecoveryInformation {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Recovery Information"

    Write-Info "Collecting Windows recovery information..."

    $StartTime = Get-Date

    try {

        $RecoveryOutput = @(
            & reagentc.exe /info 2>&1 |
                ForEach-Object {

                    $Line = $_.ToString()

                    $Line
                }
        )

        $ExitCode = $LASTEXITCODE
        $Elapsed  = (Get-Date) - $StartTime

        $RecoveryText = ($RecoveryOutput -join "`n") -replace "`0", ""
        $RecoveryText = $RecoveryText.Trim()

        $RecoveryStatus = $null
        $RecoveryLocation = $null
        $BcdIdentifier = $null
        $RecoveryImageIndex = $null
        $CustomImageIndex = $null
        $RecoveryVersion = $null

        foreach ($Line in $RecoveryOutput) {

            $Text = $Line.ToString().Trim()

            if ($Text -match "^Windows RE status:\s*(.+)$") {
                $RecoveryStatus = $Matches[1].Trim()
            }
            elseif ($Text -match "^Windows RE location:\s*(.*)$") {
                $RecoveryLocation = $Matches[1].Trim()
            }
            elseif ($Text -match "^Boot Configuration Data \(BCD\) identifier:\s*(.+)$") {
                $BcdIdentifier = $Matches[1].Trim()
            }
            elseif ($Text -match "^Recovery image index:\s*(.+)$") {
                $RecoveryImageIndex = $Matches[1].Trim()
            }
            elseif ($Text -match "^Custom image index:\s*(.+)$") {
                $CustomImageIndex = $Matches[1].Trim()
            }
            elseif ($Text -match "^Windows RE Version:\s*(.+)$") {
                $RecoveryVersion = $Matches[1].Trim()
            }
        }

        Write-BlankLine
        Show-Section "Recovery Status"

        Write-Property "Windows RE Status" $RecoveryStatus
        Write-Property "Windows RE Location" $RecoveryLocation
        Write-Property "BCD Identifier" $BcdIdentifier
        Write-Property "Recovery Image Index" $RecoveryImageIndex
        Write-Property "Custom Image Index" $CustomImageIndex
        Write-Property "Windows RE Version" $RecoveryVersion

        Write-BlankLine

        if ($RecoveryStatus -eq "Enabled") {

            Write-Success "Windows Recovery Environment is enabled."

        }
        elseif ($RecoveryStatus -eq "Disabled") {

            Write-WRTEWarning "Windows Recovery Environment is disabled."

        }
        else {

            Write-WRTEWarning "WRTE could not determine the WinRE status automatically."

        }
        
        Write-BlankLine
        Write-Property "Exit Code" $ExitCode
        Write-Property "Execution Time" ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Recovery Information completed. Exit Code: $ExitCode."

    }
    catch {

        Write-WRTEError "Unable to retrieve Windows recovery information."

        Write-Log "Recovery Information failed. $($_.Exception.Message)" `
            -Level "ERROR"

    }

    Show-Footer

    Wait-WRTE
}