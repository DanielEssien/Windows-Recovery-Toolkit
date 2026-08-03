###############################################################
# Application Controller
###############################################################

function Start-Application {

    Clear-Host

    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host " Windows Recovery Toolkit Enterprise" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Cyan

    Write-Host ""

    Write-Host "Version :" $Global:WRTE_Config.Application.Version
    Write-Host "Author  :" $Global:WRTE_Config.Application.Author

    Write-Host ""

    Write-Host "Core Engine Started Successfully." -ForegroundColor Green

}