###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Core
# File       : Loader.ps1
# Purpose    : Loads all WRTE core and module scripts.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

Write-Host "Loading Configuration.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\Configuration.ps1"

Write-Host "Loading Logger.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\Logger.ps1"

Write-Host "Loading Console.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\Console.ps1"

Write-Host "Loading Utilities.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\Utilities.ps1"

Write-Host "Loading System.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\System.ps1"

Write-Host "Loading Application.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\Application.ps1"

Write-Host "Loading Bootstrap.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\Bootstrap.ps1"

Write-Host "Loading Dashboard.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Dashboard\Dashboard.ps1"

Write-Host "Loading Diagnostics.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Diagnostics\Diagnostics.ps1"

Write-Host "Loading QuickHealth.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Diagnostics\QuickHealth.ps1"

Write-Host "Loading SFC.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Diagnostics\SFC.ps1"

Write-Host "Loading DISM.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Diagnostics\DISM.ps1"

Write-Host "Loading DiskCheck.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Diagnostics\DiskCheck.ps1"

Write-Host "Loading MemoryTest.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Diagnostics\MemoryTest.ps1"

Write-Host "Loading Recovery.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Diagnostics\Recovery.ps1"

Write-Host "Loading Hardware.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Hardware\Hardware.ps1"

Write-Host "Loading Hardware Overview..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Hardware\Overview.ps1"

Write-Host "Loading Storage.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Hardware\Storage.ps1"

Write-Host "Loading Battery.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Hardware\Battery.ps1"

Write-Host "Loading BIOS.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Hardware\BIOS.ps1"

Write-Host "WRTE modules loaded successfully." -ForegroundColor Green