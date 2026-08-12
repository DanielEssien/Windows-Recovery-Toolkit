###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : MemoryTest.ps1
# Purpose    : Launches Windows Memory Diagnostic safely.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Launches Windows Memory Diagnostic.

.DESCRIPTION
Starts the Windows Memory Diagnostic utility so the user can
choose whether to restart immediately or run the test at the
next restart.

.EXAMPLE
Start-MemoryTest
#>

function Start-MemoryTest {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Memory Test"

    Write-Info "Preparing Windows Memory Diagnostic..."

    $LatestResult = Get-MemoryDiagnosticResult

    if ($null -ne $LatestResult) {

        Show-Section "Latest Memory Diagnostic Result"

        Write-Property "Date" `
            ($LatestResult.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss"))

        if ($LatestResult.Message -match "no errors") {

            Write-Success "No memory errors were detected."

        }
        elseif ($LatestResult.Message -match "hardware problems") {

            Write-WRTEError "Memory hardware problems were detected."

        }
        else {

            Write-WRTEWarning "A previous memory diagnostic result was found."
            Write-Info $LatestResult.Message

        }

    }
    else {

        Write-BlankLine
        Write-Info "No previous Windows Memory Diagnostic result was found."

    }

    $IsAdmin = Test-IsAdministrator

    if (-not $IsAdmin) {

        Write-WRTEError "Administrator privileges are required to launch the memory diagnostic."
        Write-WRTEWarning "Close WRTE and run it as Administrator."

        Write-Log "Memory Test blocked because WRTE is not running as Administrator." `
            -Level "WARNING"

        Wait-WRTE
        return
    }

    Write-Success "Administrator privileges confirmed."

    Write-BlankLine
    Write-WRTEWarning "The memory test requires a system restart to run."
    Write-Info "Windows will let you choose whether to restart now or test at the next restart."

    $Confirmation = (Read-Host "Open Windows Memory Diagnostic now? (Y/N)").Trim().ToUpper()

    if ($Confirmation -ne "Y") {

        Write-Info "Memory diagnostic cancelled."
        Write-Log "Memory Test cancelled by user."

        Wait-WRTE
        return
    }

    Write-BlankLine
    Write-Info "Opening Windows Memory Diagnostic..."

    Write-Log "Windows Memory Diagnostic launched."

    try {

        Start-Process -FilePath "$env:SystemRoot\System32\mdsched.exe" `
            -ErrorAction Stop

        Write-Success "Windows Memory Diagnostic opened successfully."
        Write-Info "Choose the restart option that suits your current work."

    }
    catch {

        Write-WRTEError "Unable to launch Windows Memory Diagnostic."
        Write-Log "Failed to launch Windows Memory Diagnostic. $($_.Exception.Message)" `
            -Level "ERROR"

    }

    Show-Footer

    Wait-WRTE
}

function Get-MemoryDiagnosticResult {

    [CmdletBinding()]
    param()

    try {

        $Event = Get-WinEvent `
            -FilterHashtable @{
                LogName      = "System"
                ProviderName = "Microsoft-Windows-MemoryDiagnostics-Results"
            } `
            -MaxEvents 1 `
            -ErrorAction Stop

        return [PSCustomObject]@{
            TimeCreated = $Event.TimeCreated
            Message     = $Event.Message
        }

    }
    catch {

        return $null

    }

}