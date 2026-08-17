###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : DNS.ps1
# Purpose    : Displays DNS configuration and resolution details.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays DNS configuration information.

.DESCRIPTION
Retrieves DNS servers configured on active physical network
adapters and performs a basic DNS resolution test.

.EXAMPLE
Show-DNSInformation

.OUTPUTS
None
#>

function Show-DNSInformation {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "DNS Information"

    Write-Info "Collecting DNS configuration..."

    $StartTime = Get-Date

    try {

        $Adapters = @(
            Get-NetAdapter `
                -ErrorAction Stop |
                Where-Object {
                    $_.Status -eq "Up" -and
                    $_.HardwareInterface
                }
        )

        if ($Adapters.Count -eq 0) {

            Write-WRTEWarning "No active physical network adapters were detected."

            Write-Log "DNS Information completed. No active physical adapters detected." `
                -Level "WARNING"

            Show-Footer
            Wait-WRTE
            return
        }

        foreach ($Adapter in $Adapters) {

            Show-Section $Adapter.Name

            Write-Property "Description" $Adapter.InterfaceDescription

            $DNSConfig = Get-DnsClientServerAddress `
                -InterfaceIndex $Adapter.ifIndex `
                -ErrorAction SilentlyContinue

            $IPv4DNS = @(
                $DNSConfig |
                    Where-Object {
                        $_.AddressFamily -eq 2
                    } |
                    ForEach-Object {
                        $_.ServerAddresses
                    } |
                    Where-Object {
                        -not [string]::IsNullOrWhiteSpace($_)
                    }
            )

            $IPv6DNS = @(
                $DNSConfig |
                    Where-Object {
                        $_.AddressFamily -eq 23
                    } |
                    ForEach-Object {
                        $_.ServerAddresses
                    } |
                    Where-Object {
                        -not [string]::IsNullOrWhiteSpace($_)
                    }
            )

            if ($IPv4DNS.Count -gt 0) {

                Write-Property "IPv4 DNS Servers" `
                    ($IPv4DNS -join ", ")

            }
            else {

                Write-Property "IPv4 DNS Servers" "Unavailable"

            }

            if ($IPv6DNS.Count -gt 0) {

                Write-Property "IPv6 DNS Servers" `
                    ($IPv6DNS -join ", ")

            }
            else {

                Write-Property "IPv6 DNS Servers" "Unavailable"

            }
        }

        Show-Section "DNS Resolution Test"

        try {

            $DNSResult = Resolve-DnsName `
                -Name "www.microsoft.com" `
                -Type A `
                -ErrorAction Stop |
                Where-Object {
                    -not [string]::IsNullOrWhiteSpace($_.IPAddress)
                } |
                Select-Object -First 1

            if ($null -ne $DNSResult) {

                Write-Success "DNS resolution is working."
                Write-Property "Test Host" "www.microsoft.com"
                Write-Property "Resolved Address" $DNSResult.IPAddress

                $DNSStatus = "Working"

            }
            else {

                Write-WRTEWarning "DNS resolution returned no IPv4 address."

                $DNSStatus = "No IPv4 Result"

            }

        }
        catch {

            Write-WRTEError "DNS resolution failed."

            $DNSStatus = "Failed"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "DNS Information completed. Status: $DNSStatus. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        Write-WRTEError "Unable to retrieve DNS information."

        Write-Log "DNS Information failed. $($_.Exception.Message)" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}