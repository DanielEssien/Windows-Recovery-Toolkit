###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Dashboard.ps1
# Purpose    : Displays the WRTE dashboard and main menu.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays the WRTE Dashboard.

.DESCRIPTION
Displays the main dashboard using information provided
by the System Information Service.

.EXAMPLE
Show-Dashboard

.NOTES
Primary entry point of the WRTE user interface.
#>

function Show-Dashboard {

    [CmdletBinding()]
    param()

    $SystemInfo = Get-SystemInformation

    Show-Banner

    #----------------------------------------------------------
    # System Information
    #----------------------------------------------------------

    Show-Section "System Information"

    Write-Property "Computer Name" $SystemInfo.ComputerName
    Write-Property "Current User"  $SystemInfo.CurrentUser
    Write-Property "Windows"       $SystemInfo.WindowsName
    Write-Property "Version"       $SystemInfo.WindowsVersion
    Write-Property "Build"         $SystemInfo.BuildNumber
    Write-Property "Manufacturer"  $SystemInfo.Manufacturer
    Write-Property "Model"         $SystemInfo.Model
    Write-Property "Memory"        "$($SystemInfo.MemoryGB) GB"
    Write-Property "PowerShell"    $SystemInfo.PowerShellVersion

    #----------------------------------------------------------
    # Main Menu
    #----------------------------------------------------------

    Show-Section "Main Menu"

    Write-MenuItem "1" "Diagnostics"
    Write-MenuItem "2" "Windows Repair"
    Write-MenuItem "3" "Hardware"
    Write-MenuItem "4" "Network"
    Write-MenuItem "5" "Security"
    Write-MenuItem "6" "Maintenance"
    Write-MenuItem "7" "Microsoft 365"
    Write-MenuItem "8" "OneDrive"
    Write-MenuItem "9" "Reports"
    Write-MenuItem "0" "Tools"
    Write-MenuItem "Q" "Exit"

    Show-Footer

}