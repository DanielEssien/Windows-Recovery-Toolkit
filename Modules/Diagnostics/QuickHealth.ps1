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

    $StartTime = Get-Date

    Show-Banner

    Write-Info "Collecting system information..."

    Start-Sleep -Milliseconds 500   

    Write-BlankLine

    $System = Get-SystemInformation
    $IsAdmin = Test-IsAdministrator
    $Internet = Test-InternetConnection
    $FreeDisk = Get-SystemDriveFreeSpace
    $Defender = Get-DefenderStatus

    $Issues = 0

    if (-not $IsAdmin) { $Issues++ }

    if (-not $Internet) { $Issues++ }

    if ($Defender -ne "Running") { $Issues++ }

    if ($FreeDisk -lt 20) { $Issues++ }

    switch ($Issues) {

        0 {

            $Health = "Healthy"

        }

        1 {

            $Health = "Warning"

        }

        default {

            $Health = "Attention"

        }

    }

    Show-Section "System Information"

    Write-Property "Computer Name" $System.ComputerName
    Write-Property "Current User"  $System.CurrentUser
    Write-Property "Windows"       $System.Windows
    Write-Property "Version"       $System.Version
    Write-Property "Build"         $System.Build
    Write-Property "PowerShell"    $System.PowerShell

    Show-Section "Health Checks"

    Write-Property "Administrator" `
        $(if($IsAdmin){"Yes"}else{"No"})

    Write-Property "Internet" `
        $(if($Internet){"Connected"}else{"Offline"})

    Write-Property "Windows Defender" $Defender
    Write-Property "Free Disk (GB)" $FreeDisk
    
    Write-BlankLine

    Show-Section "Overall Assessment"

    switch ($Health) {

        "Healthy" {

            Write-Success "Overall Health : HEALTHY"

        }

        "Warning" {

            Write-WRTEWarning "Overall Health : WARNING"

        }

        default {

            Write-WRTEError "Overall Health : ATTENTION"

        }

    }

    Show-Section "Recommendations"

    if (-not $IsAdmin) {

        Write-WRTEWarning "• Run WRTE as Administrator."

    }

    if (-not $Internet) {

        Write-WRTEWarning "• Connect to the Internet."

    }

    if ($Defender -ne "Running") {

        Write-WRTEWarning "• Start Microsoft Defender."

    }

    if ($FreeDisk -lt 20) {

        Write-WRTEWarning "• Free at least 20 GB of disk space."

    }

    if ($IsAdmin -and
        $Internet -and
        $Defender -eq "Running" -and
        $FreeDisk -ge 20) {

        Write-Success "• No action required."

    }

    $Elapsed = (Get-Date) - $StartTime

    Write-BlankLine

    Write-Property "Execution Time" ("{0:N2} sec" -f $Elapsed.TotalSeconds)

    Show-Footer

   Write-Log @"
Quick Health Check completed.

Overall Health : $Health
Administrator  : $IsAdmin
Internet       : $Internet
Free Disk (GB) : $FreeDisk
Defender       : $Defender
"@

    Wait-WRTE

}