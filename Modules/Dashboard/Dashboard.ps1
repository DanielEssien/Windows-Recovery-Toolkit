###############################################################
# Dashboard Module
###############################################################

function Show-Dashboard {

    Show-Banner

    Write-Host "Computer : $env:COMPUTERNAME"
    Write-Host "User     : $env:USERNAME"
    Write-Host ""

    Write-Host "============== MAIN MENU ==============" -ForegroundColor Cyan

    Write-Host ""

    Write-Host "1. Quick Health Check"

    Write-Host ""

    Write-Host "Q. Exit"

    Write-Host ""

}