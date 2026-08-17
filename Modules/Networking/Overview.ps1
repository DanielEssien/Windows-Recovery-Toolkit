###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Overview.ps1
# Purpose    : Displays a summary of active network information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays a summary of active network information.

.DESCRIPTION
Retrieves active network adapter, IPv4 address, default gateway,
DNS servers, DHCP status, link speed, and internet connectivity.

.EXAMPLE
Show-NetworkOverview

.OUTPUTS
None
#>

function Show-NetworkOverview {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Network Overview"

    Write-Info "Collecting network information..."

    $StartTime = Get-Date

    try {

        $Adapter = Get-NetAdapter `
            -ErrorAction Stop |
            Where-Object {
                $_.Status -eq "Up" -and
                $_.HardwareInterface
            } |
            Sort-Object -Property LinkSpeed -Descending |
            Select-Object -First 1

        if ($null -eq $Adapter) {

            Write-WRTEWarning "No active physical network adapter was detected."

            Write-Log "Network Overview completed. No active physical adapter detected." `
                -Level "WARNING"

            Show-Footer
            Wait-WRTE
            return
        }

        $IPConfig = Get-NetIPConfiguration `
            -InterfaceIndex $Adapter.ifIndex `
            -ErrorAction Stop

        $IPv4Address = if ($null -ne $IPConfig.IPv4Address) {
            ($IPConfig.IPv4Address.IPAddress -join ", ")
        }
        else {
            "Unavailable"
        }

        $Gateway = if ($null -ne $IPConfig.IPv4DefaultGateway) {
            ($IPConfig.IPv4DefaultGateway.NextHop -join ", ")
        }
        else {
            "Unavailable"
        }

        $DNSServers = if ($null -ne $IPConfig.DNSServer.ServerAddresses) {
            ($IPConfig.DNSServer.ServerAddresses -join ", ")
        }
        else {
            "Unavailable"
        }

        $DHCP = Get-NetIPInterface `
            -InterfaceIndex $Adapter.ifIndex `
            -AddressFamily IPv4 `
            -ErrorAction SilentlyContinue

        $DHCPStatus = if ($null -ne $DHCP) {
            $DHCP.Dhcp
        }
        else {
            "Unavailable"
        }

        $InternetAvailable = Test-InternetConnection

        Write-BlankLine
        Show-Section "Active Connection"

        Write-Property "Adapter" $Adapter.Name
        Write-Property "Description" $Adapter.InterfaceDescription
        Write-Property "Status" $Adapter.Status
        Write-Property "Link Speed" $Adapter.LinkSpeed
        Write-Property "MAC Address" $Adapter.MacAddress

        Show-Section "IP Configuration"

        Write-Property "IPv4 Address" $IPv4Address
        Write-Property "Default Gateway" $Gateway
        Write-Property "DNS Servers" $DNSServers
        Write-Property "DHCP" $DHCPStatus

        Show-Section "Connectivity"

        if ($InternetAvailable) {

            Write-Success "Internet connectivity detected."

        }
        else {

            Write-WRTEWarning "Internet connectivity could not be confirmed."

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Network Overview completed. Adapter: $($Adapter.Name). Internet: $InternetAvailable. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        Write-WRTEError "Unable to retrieve network information."

        Write-Log "Network Overview failed. $($_.Exception.Message)" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}
