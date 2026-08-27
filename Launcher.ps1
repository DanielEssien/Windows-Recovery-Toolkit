###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# File       : Launcher.ps1
# Purpose    : Starts the WRTE application.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

[CmdletBinding()]
param()

Clear-Host

$MinimumPowerShellVersion =
    [version]"7.0"

if ($PSVersionTable.PSVersion -lt $MinimumPowerShellVersion) {

    Write-Host ""
    Write-Host "WRTE requires PowerShell 7.0 or later." -ForegroundColor Red
    Write-Host "Current version: $($PSVersionTable.PSVersion)" -ForegroundColor Red
    Write-Host ""

    return
}

$LoaderFile =
    Join-Path `
        -Path $PSScriptRoot `
        -ChildPath "Core\Loader.ps1"

if (-not (Test-Path -Path $LoaderFile)) {

    Write-Host ""
    Write-Host "WRTE failed to start." -ForegroundColor Red
    Write-Host "Loader not found: $LoaderFile" -ForegroundColor Red
    Write-Host ""

    return
}

try {

    . $LoaderFile

    Start-Bootstrap
}
catch {

    $ErrorMessage =
        $_.Exception.Message

    Write-Host ""
    Write-Host "WRTE launcher encountered an unexpected error." -ForegroundColor Red
    Write-Host "Reason: $ErrorMessage" -ForegroundColor Red
    Write-Host ""
}