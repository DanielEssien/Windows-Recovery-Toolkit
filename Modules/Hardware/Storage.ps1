###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Storage.ps1
# Purpose    : Displays physical storage device information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays physical storage device information.

.DESCRIPTION
Retrieves physical disk information including model, bus type,
media type, health status, operational status, and capacity.

.EXAMPLE
Show-StorageDevices

.OUTPUTS
None
#>

function Show-StorageDevices {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Storage Devices"

    Write-Info "Collecting physical storage information..."

    $StartTime = Get-Date

    try {

        $Disks = @(Get-PhysicalDisk -ErrorAction Stop)

        if (-not $Disks) {

            Write-WRTEWarning "No physical storage devices were detected."

            Show-Footer
            Wait-WRTE
            return
        }

        $DiskNumber = 1

        foreach ($Disk in $Disks) {

            Show-Section "Disk $DiskNumber"

            Write-Property "Model" $Disk.FriendlyName
            Write-Property "Serial Number" $Disk.SerialNumber
            Write-Property "Bus Type" $Disk.BusType
            Write-Property "Media Type" $Disk.MediaType
            Write-Property "Health Status" $Disk.HealthStatus
            Write-Property "Operational Status" ($Disk.OperationalStatus -join ", ")
            Write-Property "Size" ("{0:N2} GB" -f ($Disk.Size / 1GB))

            $DiskNumber++
        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Devices Found" $Disks.Count
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Storage Devices completed. Devices Found: $($Disks.Count). Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        Write-WRTEError "Unable to retrieve storage device information."

        Write-Log "Storage Devices failed. $($_.Exception.Message)" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}