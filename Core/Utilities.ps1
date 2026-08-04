###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Core
# File       : Utilities.ps1
# Purpose    : Provides reusable helper functions shared
#              across the application.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

###############################################################
#
# Determines whether WRTE is running as Administrator.
#
###############################################################

function Test-IsAdministrator {

    [CmdletBinding()]
    param()

    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()

    $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)

    return $Principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

}

###############################################################
#
# Tests Internet Connectivity
#
###############################################################

function Test-InternetConnection {

    [CmdletBinding()]
    param()

    try {

        return (Test-Connection -ComputerName "1.1.1.1" -Count 1 -Quiet)

    }
    catch {

        return $false

    }

}

###############################################################
#
# Retrieves free space on the Windows system drive.
#
###############################################################

function Get-SystemDriveFreeSpace {

    [CmdletBinding()]
    param()

    try {

        $SystemDrive = $env:SystemDrive

        $Disk = Get-CimInstance Win32_LogicalDisk `
            -Filter "DeviceID='$SystemDrive'"

        return [Math]::Round($Disk.FreeSpace / 1GB, 2)

    }
    catch {

        return $null

    }

}

###############################################################
#
# Retrieves Windows Defender service status.
#
###############################################################

function Get-DefenderStatus {

    [CmdletBinding()]
    param()

    try {

        $Service = Get-Service -Name "WinDefend" -ErrorAction Stop

        return $Service.Status

    }
    catch {

        return "Unavailable"

    }

}