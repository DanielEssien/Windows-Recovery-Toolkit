###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : WindowsUpdateRepair.ps1
# Purpose    : Repairs common Windows Update components.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Repairs common Windows Update components.

.DESCRIPTION
Stops Windows Update-related services, refreshes the Windows
Update cache folders, and restarts the required services.

When Windows Repair DryRun mode is enabled, WRTE simulates
the operation without modifying Windows Update components.

.EXAMPLE
Start-WindowsUpdateRepair

.OUTPUTS
None

.NOTES
Requires administrator privileges when DryRun mode is disabled.
Stops Windows Update-related services temporarily and restores
services that were running before the repair.
A system restart may be recommended after the repair.
#>

function Start-WindowsUpdateRepair {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Repair Windows Update Components"

    $Config = Get-Configuration
    $DryRun = $Config.WindowsRepair.DryRun

    Write-Info "Preparing Windows Update component repair..."

    if ($DryRun) {

        Write-BlankLine
        Write-WRTEWarning "DRY-RUN mode is enabled."
        Write-Info "Windows Update repair actions will be simulated."
        Write-Info "No services or update cache folders will be modified."

    }

    if (-not $DryRun) {

        $IsAdmin = Test-IsAdministrator

        if (-not $IsAdmin) {

            Write-WRTEError "Administrator privileges are required."
            Write-WRTEWarning "Close WRTE and run it as Administrator."

            Write-Log "Windows Update Repair blocked because WRTE is not running as Administrator." `
                -Level "WARNING"

            Show-Footer
            Wait-WRTE
            return
        }

        Write-Success "Administrator privileges confirmed."
    }

    Write-BlankLine
    Write-WRTEWarning "This operation resets common Windows Update components."

    Write-Info "Services:"
    Write-Property "Windows Update" "wuauserv"
    Write-Property "BITS" "BITS"
    Write-Property "Cryptographic Services" "CryptSvc"
    Write-Property "Windows Installer" "msiserver"

    Write-BlankLine
    Write-Info "Cache folders:"
    Write-Property "SoftwareDistribution" "$env:SystemRoot\SoftwareDistribution"
    Write-Property "Catroot2" "$env:SystemRoot\System32\catroot2"

    $Confirmation = (
        Read-Host "Proceed with Windows Update Repair? (Y/N)"
    ).Trim().ToUpper()

    if ($Confirmation -ne "Y") {

        Write-Info "Windows Update Repair cancelled."

        Write-Log "Windows Update Repair cancelled by user."

        Show-Footer
        Wait-WRTE
        return
    }

    if ($DryRun) {

        Write-BlankLine
        Show-Section "Simulation Result"

        Write-Success "Windows Update Repair simulation completed."

        Write-Info "The following actions would have been performed:"
        Write-Property "Action 1" "Stop Windows Update services"
        Write-Property "Action 2" "Rename SoftwareDistribution"
        Write-Property "Action 3" "Rename catroot2"
        Write-Property "Action 4" "Restart Windows Update services"

        Write-Log "Windows Update Repair simulated. Dry-run mode enabled."

        Show-Footer
        Wait-WRTE
        return
    }

    $StartTime = Get-Date

    $Services = @(
        "wuauserv",
        "BITS",
        "CryptSvc",
        "msiserver"
    )

    $SoftwareDistributionPath = Join-Path `
        -Path $env:SystemRoot `
        -ChildPath "SoftwareDistribution"

    $Catroot2Path = Join-Path `
        -Path $env:SystemRoot `
        -ChildPath "System32\catroot2"

    $Timestamp = Get-Date -Format "yyyyMMddHHmmss"

    $SoftwareDistributionBackup = "SoftwareDistribution.WRTE.$Timestamp"
    $Catroot2Backup = "catroot2.WRTE.$Timestamp"
    $ServiceStates = @{}

    try {

        Write-BlankLine
        Write-Info "Stopping Windows Update services..."

        foreach ($ServiceName in $Services) {

            $Service = Get-Service `
                -Name $ServiceName `
                -ErrorAction SilentlyContinue

            if ($null -eq $Service) {
                continue
            }

            $ServiceStates[$ServiceName] = $Service.Status

            if ($Service.Status -ne "Stopped") {

                Stop-Service `
                    -Name $ServiceName `
                    -Force `
                    -ErrorAction Stop
            }
        }

        Write-Success "Required services stopped."

        Write-BlankLine
        Write-Info "Refreshing Windows Update cache folders..."

        if (Test-Path $SoftwareDistributionPath) {

            Rename-Item `
                -Path $SoftwareDistributionPath `
                -NewName $SoftwareDistributionBackup `
                -ErrorAction Stop
        }

        if (Test-Path $Catroot2Path) {

            Rename-Item `
                -Path $Catroot2Path `
                -NewName $Catroot2Backup `
                -ErrorAction Stop
        }

        Write-Success "Windows Update cache folders refreshed."

        Write-BlankLine
        Write-Info "Restarting Windows Update services..."

        foreach ($ServiceName in $Services) {

            if (-not $ServiceStates.ContainsKey($ServiceName)) {
                continue
            }

            if ($ServiceStates[$ServiceName] -eq "Running") {

                Start-Service `
                    -Name $ServiceName `
                    -ErrorAction SilentlyContinue
            }
        }

        $Elapsed = (Get-Date) - $StartTime

        Show-Section "Repair Result"

        Write-Success "Windows Update components were reset successfully."
        Write-WRTEWarning "A system restart is recommended."

        Write-BlankLine
        Write-Property "Restart Recommended" "Yes"
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Windows Update Repair completed successfully. SoftwareDistribution backup: $SoftwareDistributionBackup. Catroot2 backup: $Catroot2Backup. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to complete Windows Update Repair."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Windows Update Repair failed. $ErrorMessage" `
            -Level "ERROR"

        Write-BlankLine
        Write-Info "Attempting to restart Windows Update services..."

        foreach ($ServiceName in $Services) {

            if (-not $ServiceStates.ContainsKey($ServiceName)) {
                continue
            }

            if ($ServiceStates[$ServiceName] -eq "Running") {

                Start-Service `
                    -Name $ServiceName `
                    -ErrorAction SilentlyContinue
            }
        }
    }

    Show-Footer
    Wait-WRTE
}