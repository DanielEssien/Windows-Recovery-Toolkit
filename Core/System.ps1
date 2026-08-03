###############################################################
# Windows Recovery Toolkit Enterprise
# System Information Service
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

            WindowsName    = $OperatingSystem.Caption
            WindowsVersion = $OperatingSystem.Version
            BuildNumber    = $OperatingSystem.BuildNumber

            BIOSVersion = ($BIOS.SMBIOSBIOSVersion -join ", ")

            MemoryGB = [Math]::Round(
                $ComputerSystem.TotalPhysicalMemory / 1GB,
                2
            )

            PowerShellVersion = $PSVersionTable.PSVersion.ToString()

        }

    }
    catch {

        throw "Unable to retrieve system information. $($_.Exception.Message)"

    }

}