###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Overview.ps1
# Purpose    : Displays a summary of system hardware information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays a summary of system hardware information.

.DESCRIPTION
Retrieves and displays processor, memory, motherboard,
BIOS, and storage information.

.EXAMPLE
Show-HardwareOverview

.OUTPUTS
None
#>

function Show-HardwareOverview {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "System Hardware Overview"

    Write-Info "Collecting hardware information..."

    $StartTime = Get-Date

    try {

        $ComputerSystem = Get-CimInstance `
            -ClassName Win32_ComputerSystem `
            -ErrorAction Stop

        $Processor = Get-CimInstance `
            -ClassName Win32_Processor `
            -ErrorAction Stop |
            Select-Object -First 1

        $BaseBoard = Get-CimInstance `
            -ClassName Win32_BaseBoard `
            -ErrorAction Stop |
            Select-Object -First 1

        $BIOS = Get-CimInstance `
            -ClassName Win32_BIOS `
            -ErrorAction Stop |
            Select-Object -First 1

        $Disk = Get-PhysicalDisk `
            -ErrorAction Stop |
            Select-Object -First 1

        $MemoryGB = [Math]::Round(
            $ComputerSystem.TotalPhysicalMemory / 1GB,
            2
        )

        $DiskSizeGB = if ($null -ne $Disk.Size) {
            [Math]::Round($Disk.Size / 1GB, 2)
        }
        else {
            $null
        }

        Write-BlankLine
        Show-Section "System"

        Write-Property "Manufacturer" $ComputerSystem.Manufacturer
        Write-Property "Model" $ComputerSystem.Model
        Write-Property "Total Memory" ("{0} GB" -f $MemoryGB)

        Show-Section "Processor"

        Write-Property "CPU" $Processor.Name
        Write-Property "Cores" $Processor.NumberOfCores
        Write-Property "Logical Processors" $Processor.NumberOfLogicalProcessors
        Write-Property "Current Clock Speed" ("{0} MHz" -f $Processor.CurrentClockSpeed)
        Write-Property "Reported Max Speed"  ("{0} MHz" -f $Processor.MaxClockSpeed)

        Show-Section "Motherboard"

        Write-Property "Manufacturer" $BaseBoard.Manufacturer
        Write-Property "Product" $BaseBoard.Product
        Write-Property "Serial Number" $BaseBoard.SerialNumber

        Show-Section "BIOS"

        Write-Property "Vendor" $BIOS.Manufacturer
        Write-Property "Version" $BIOS.SMBIOSBIOSVersion

        Show-Section "Primary Storage"

        Write-Property "Model" $Disk.FriendlyName
        Write-Property "Bus Type" $Disk.BusType
        Write-Property "Media Type" $Disk.MediaType
        Write-Property "Health Status" $Disk.HealthStatus
        Write-Property "Size" ("{0:N2} GB" -f ($Disk.Size / 1GB))

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Hardware Overview completed. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        Write-WRTEError "Unable to retrieve hardware information."

        Write-Log "Hardware Overview failed. $($_.Exception.Message)" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}