###############################################################
# Bootstrap Engine
###############################################################

. "$PSScriptRoot\Configuration.ps1"

function Start-Bootstrap {

    Clear-Host

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host " Windows Recovery Toolkit Enterprise"
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Loading configuration..."

    Initialize-Configuration

    $config = Get-Configuration

    Write-Host "Application : $($config.Application.Name)"
    Write-Host "Version     : $($config.Application.Version)"

    Write-Host ""
    Write-Host "Bootstrap completed successfully." -ForegroundColor Green
}