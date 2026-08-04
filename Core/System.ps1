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

function Get-SystemInformation {

    [CmdletBinding()]
    param()

    try {

        $OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
        $ComputerSystem  = Get-CimInstance -ClassName Win32_ComputerSystem
        $BIOS            = Get-CimInstance -ClassName Win32_BIOS

        return [PSCustomObject]@{

            ComputerName = $env:COMPUTERNAME
            CurrentUser  = $env:USERNAME
            Manufacturer = $ComputerSystem.Manufacturer
            Model        = $ComputerSystem.Model
            Windows = $OperatingSystem.Caption
            Version = $OperatingSystem.Version
            Build   = $OperatingSystem.BuildNumber
            OSArchitecture = $OperatingSystem.OSArchitecture

            MemoryGB = [Math]::Round(
                $ComputerSystem.TotalPhysicalMemory / 1GB,
                2
            )
            PowerShell = $PSVersionTable.PSVersion.ToString()
            BIOSVersion = ($BIOS.SMBIOSBIOSVersion -join ", ")
            LastBoot = $OperatingSystem.LastBootUpTime
            
        }

    }
    catch {

        throw "Unable to retrieve system information. $($_.Exception.Message)"

    }

}