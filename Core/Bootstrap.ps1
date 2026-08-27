###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Core
# File       : Bootstrap.ps1
# Purpose    : Initializes the WRTE application and starts
#              the application lifecycle.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################
function Start-Bootstrap {

    [CmdletBinding()]
    param()

    try {

        Initialize-Configuration

        Initialize-Logger

        Write-Log `
            -Message "Bootstrap completed." `
            -Level INFO

        Start-Application
    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        try {

            if ($script:LogFile) {

                Write-Log `
                    -Message "Bootstrap failed. $ErrorMessage" `
                    -Level ERROR
            }
        }
        catch {
            # Logging may not be available if initialization failed.
        }

        Write-Host ""
        Write-Host "WRTE failed to start." -ForegroundColor Red
        Write-Host "Reason: $ErrorMessage" -ForegroundColor Red
        Write-Host ""

        return
    }
}