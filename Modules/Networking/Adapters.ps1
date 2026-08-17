###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Adapters.ps1
# Purpose    : Displays physical network adapter information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays physical network adapter information.

.DESCRIPTION
Retrieves physical network adapters and displays their status,
MAC address, link speed, media type, and driver information.

.EXAMPLE
Show-AdapterInformation

.OUTPUTS
None
#>

function Show-AdapterInformation {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Adapter Information"

    Write-Info "Collecting network adapter information..."

    $StartTime = Get-Date

    try {

        $Adapters = @(
            Get-NetAdapter `
                -Physical `
                -ErrorAction Stop |
                Sort-Object -Property Name
        )

        if ($Adapters.Count -eq 0) {

            Write-WRTEWarning "No physical network adapters were detected."

            Write-Log "Adapter Information completed. No physical adapters detected." `
                -Level "WARNING"

            Show-Footer
            Wait-WRTE
            return
        }

        $AdapterNumber = 1

        foreach ($Adapter in $Adapters) {

            Show-Section "Adapter $AdapterNumber"

            Write-Property "Name" $Adapter.Name
            Write-Property "Description" $Adapter.InterfaceDescription
            Write-Property "Status" $Adapter.Status
            Write-Property "MAC Address" $Adapter.MacAddress
            Write-Property "Link Speed" $Adapter.LinkSpeed
            Write-Property "Media Type" $Adapter.MediaType

            $Driver = Get-CimInstance `
                -ClassName Win32_PnPSignedDriver `
                -Filter "DeviceName='$($Adapter.InterfaceDescription.Replace("'", "''"))'" `
                -ErrorAction SilentlyContinue |
                Select-Object -First 1

            if ($null -ne $Driver) {

                Write-Property "Driver Provider" $Driver.DriverProviderName
                Write-Property "Driver Version" $Driver.DriverVersion

                if ($null -ne $Driver.DriverDate) {

                    Write-Property "Driver Date" `
                        ($Driver.DriverDate.ToString("yyyy-MM-dd"))

                }
            }
            else {

                Write-Property "Driver Provider" "Unavailable"
                Write-Property "Driver Version" "Unavailable"

            }

            $AdapterNumber++
        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Adapters Found" $Adapters.Count
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Adapter Information completed. Adapters Found: $($Adapters.Count). Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        Write-WRTEError "Unable to retrieve network adapter information."

        Write-Log "Adapter Information failed. $($_.Exception.Message)" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}