###############################################################
# Bootstrap Engine
###############################################################

. "$PSScriptRoot\Configuration.ps1"
. "$PSScriptRoot\Logger.ps1"

function Start-Bootstrap {

    Clear-Host

    Write-Host "Starting WRTE..." -ForegroundColor Cyan
    Write-Host ""

    Initialize-Configuration

    Initialize-Logger

    Write-Log "Bootstrap started"

    $config = Get-Configuration

    Write-Host "Application : $($config.Application.Name)"
    Write-Host "Version     : $($config.Application.Version)"

    Write-Log "Configuration loaded"

    Write-Host ""
    Write-Host "Bootstrap completed." -ForegroundColor Green

    Write-Log "Bootstrap completed"

}