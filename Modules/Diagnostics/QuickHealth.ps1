###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : QuickHealth.ps1
# Purpose    : Performs a quick health assessment.
#
###############################################################

<#
.SYNOPSIS
Displays a quick health summary.

.DESCRIPTION
Collects and displays basic system information.

.EXAMPLE
Start-QuickHealth
#>

function Start-QuickHealth {

    [CmdletBinding()]
    param()

    Show-Banner

    Show-Section "Quick Health Check"

    Write-Info "Collecting system information..."

    Write-BlankLine

    $System = Get-SystemInformation
    $IsAdmin = Test-IsAdministrator
    $Internet = Test-InternetConnection
    $FreeDisk = Get-SystemDriveFreeSpace
    $Defender = Get-DefenderStatus

    $Health = "Healthy"

    if (-not $Internet -or
        -not $IsAdmin -or
        $Defender -ne "Running" -or
        $FreeDisk -lt 20) {

        $Health = "Attention"

    }

    Write-Property "Computer Name" $System.ComputerName
    Write-Property "Current User"  $System.CurrentUser
    Write-Property "Windows"       $System.Windows
    Write-Property "Version"       $System.Version
    Write-Property "Build"         $System.Build
    Write-Property "PowerShell"    $System.PowerShell

    Write-Property "Administrator" `
        $(if($IsAdmin){"Yes"}else{"No"})

    Write-Property "Internet" `
        $(if($Internet){"Connected"}else{"Offline"})

    Write-Property "Windows Defender" $Defender
    Write-Property "Free Disk (GB)" $FreeDisk
    
    Write-BlankLine

    Write-Property "Overall Health" $Health

    Show-Footer

    Write-Log "Quick Health Check completed."

    Wait-WRTE

}