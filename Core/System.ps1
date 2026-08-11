###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Core
# File       : System.ps1
# Purpose    : Retrieves Windows system information and
#              exposes it through reusable services.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Retrieves core Windows system information.

.DESCRIPTION
Collects operating system, computer hardware, BIOS, memory,
and PowerShell information and returns the results as a
PSCustomObject for use throughout WRTE.

.OUTPUTS
PSCustomObject

.EXAMPLE
$SystemInfo = Get-SystemInformation

.EXAMPLE
Get-SystemInformation

.NOTES
Used by WRTE components such as the Dashboard, Diagnostics,
Hardware, and Reports modules.
#>

function Get-SystemInformation {

    [CmdletBinding()]
    param()

    try {

        $OperatingSystem = Get-CimInstance `
            -ClassName Win32_OperatingSystem `
            -ErrorAction Stop

        $ComputerSystem = Get-CimInstance `
            -ClassName Win32_ComputerSystem `
            -ErrorAction Stop

        $BIOS = Get-CimInstance `
            -ClassName Win32_BIOS `
            -ErrorAction Stop

        return [PSCustomObject]@{

            ComputerName   = $env:COMPUTERNAME
            CurrentUser    = $env:USERNAME

            Manufacturer   = $ComputerSystem.Manufacturer
            Model          = $ComputerSystem.Model

            Windows        = $OperatingSystem.Caption
            Version        = $OperatingSystem.Version
            Build          = $OperatingSystem.BuildNumber
            OSArchitecture = $OperatingSystem.OSArchitecture

            MemoryGB = [Math]::Round(
                $ComputerSystem.TotalPhysicalMemory / 1GB,
                2
            )

            PowerShell     = $PSVersionTable.PSVersion.ToString()
            BIOSVersion    = $BIOS.SMBIOSBIOSVersion
            LastBoot       = $OperatingSystem.LastBootUpTime

        }

    }
    catch {

        throw "Unable to retrieve system information. $($_.Exception.Message)"

    }

}