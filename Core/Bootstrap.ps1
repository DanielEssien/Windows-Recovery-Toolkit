###############################################################
# Bootstrap Engine
###############################################################

. "$PSScriptRoot\Configuration.ps1"
. "$PSScriptRoot\Logger.ps1"

function Start-Bootstrap {

    Clear-Host

    Write-Host ""
    Write-Host "Starting Windows Recovery Toolkit Enterprise..." -ForegroundColor Cyan
    Write-Host ""

    Initialize-Configuration
    Initialize-Logger

    Write-Log "Bootstrap completed."

    Start-Application

}