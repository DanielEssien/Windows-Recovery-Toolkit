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

Write-Host "Loading Network.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Networking\Network.ps1"

Write-Host "Loading Network Overview..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Networking\Overview.ps1"

Write-Host "Loading Adapters.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Networking\Adapters.ps1"

Write-Host "Loading Connectivity.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Networking\Connectivity.ps1"

Write-Host "Loading DNS.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Networking\DNS.ps1"

Write-Host "Loading Maintenance.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Maintenance\Maintenance.ps1"

Write-Host "Loading TempCleanup.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Maintenance\TempCleanup.ps1"

Write-Host "Loading WindowsUpdate.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Maintenance\WindowsUpdate.ps1"

Write-Host "Loading DiskCleanup.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Maintenance\DiskCleanup.ps1"

Write-Host "Loading Uptime.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Maintenance\Uptime.ps1"

Write-Host "Loading WindowsRepair.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\WindowsRepair\WindowsRepair.ps1"

Write-Host "Loading SystemFiles.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\WindowsRepair\SystemFiles.ps1"

Write-Host "Loading WindowsImage.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\WindowsRepair\WindowsImage.ps1"

Write-Host "Loading NetworkReset.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\WindowsRepair\NetworkReset.ps1"

Write-Host "Loading WindowsUpdateRepair.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\WindowsRepair\WindowsUpdateRepair.ps1"

Write-Host "Loading AdvancedRecovery.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\WindowsRepair\AdvancedRecovery.ps1"

Write-Host "Loading Security.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Security\Security.ps1"

Write-Host "Loading Security Overview..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Security\Overview.ps1"

Write-Host "Loading Defender.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Security\Defender.ps1"

Write-Host "Loading Firewall.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Security\Firewall.ps1"

Write-Host "Loading BitLocker.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Security\BitLocker.ps1"

Write-Host "Loading SecureBoot.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Security\SecureBoot.ps1"

Write-Host "Loading EncryptionProviders.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Security\EncryptionProviders.ps1"

Write-Host "Loading DiskEncryption.ps1..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Modules\Security\DiskEncryption.ps1"

Write-Host "WRTE modules loaded successfully." -ForegroundColor Green