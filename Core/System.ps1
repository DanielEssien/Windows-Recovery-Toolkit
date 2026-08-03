###############################################################
# WRTE System Information Service
###############################################################

function Get-SystemInformation {

    $os = Get-CimInstance Win32_OperatingSystem

    $computer = Get-CimInstance Win32_ComputerSystem

    [PSCustomObject]@{

        ComputerName = $env:COMPUTERNAME

        CurrentUser  = $env:USERNAME

        Windows      = $os.Caption

        Version      = $os.Version

        Build        = $os.BuildNumber

        Manufacturer = $computer.Manufacturer

        Model        = $computer.Model

        TotalMemoryGB = [math]::Round($computer.TotalPhysicalMemory / 1GB,2)

        PowerShell   = $PSVersionTable.PSVersion.ToString()

    }

}