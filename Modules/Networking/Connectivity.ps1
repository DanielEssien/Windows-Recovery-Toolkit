###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Connectivity.ps1
# Purpose    : Tests local and internet network connectivity.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Tests network connectivity.

.DESCRIPTION
Checks the active network adapter, default gateway,
DNS resolution, and internet reachability.

.EXAMPLE
Start-ConnectivityTest

.OUTPUTS
None
#>

function Start-ConnectivityTest {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Connectivity Test"

    Write-Info "Running network connectivity checks..."

    $StartTime = Get-Date

    try {

        $Adapter = Get-NetAdapter `
            -ErrorAction Stop |
            Where-Object {
                $_.Status -eq "Up" -and
                $_.HardwareInterface
            } |
            Select-Object -First 1

        if ($null -eq $Adapter) {

            Write-WRTEError "No active physical network adapter was detected."

            Write-Log "Connectivity Test failed. No active physical adapter detected." `
                -Level "ERROR"

            Show-Footer
            Wait-WRTE
            return
        }

        $IPConfig = Get-NetIPConfiguration `
            -InterfaceIndex $Adapter.ifIndex `
            -ErrorAction Stop

        $Gateway = $IPConfig.IPv4DefaultGateway.NextHop |
            Select-Object -First 1

        Show-Section "Adapter"

        Write-Property "Name" $Adapter.Name
        Write-Property "Status" $Adapter.Status

        Show-Section "Gateway Test"

        $GatewayReachable = $false

        if ($null -ne $Gateway) {

            Write-Property "Gateway" $Gateway

            $GatewayReachable = Test-Connection `
                -TargetName $Gateway `
                -Count 1 `
                -Quiet `
                -ErrorAction SilentlyContinue

            if ($GatewayReachable) {
                Write-Success "Default gateway is reachable."
            }
            else {
                Write-WRTEWarning "Default gateway did not respond."
            }

        }
        else {

            Write-WRTEWarning "No IPv4 default gateway was detected."

        }

        Show-Section "DNS Test"

        $DNSWorking = $false

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

                $DNSWorking = $true

                Write-Success "DNS resolution is working."
                Write-Property "Resolved Address" $DNSResult.IPAddress

            }
            else {

                Write-WRTEWarning "DNS resolution returned no IPv4 address."

            }

        }
        catch {

            Write-WRTEWarning "DNS resolution failed."

        }

        Show-Section "Internet Test"

        $InternetPing = Test-Connection `
            -TargetName "1.1.1.1" `
            -Count 1 `
            -Quiet `
            -ErrorAction SilentlyContinue

        if ($InternetPing) {

            Write-Success "ICMP internet reachability confirmed."

        }
        else {

            Write-WRTEWarning "ICMP internet reachability could not be confirmed."

        }

        $HTTPSWorking = $false

        try {

            $WebResponse = Invoke-WebRequest `
            -Uri "https://www.microsoft.com" `
            -Method Get `
            -TimeoutSec 5 `
            -ErrorAction Stop

            if ($WebResponse.StatusCode -ge 200 -and
                $WebResponse.StatusCode -lt 400) {

                $HTTPSWorking = $true

                Write-Success "HTTPS internet connectivity confirmed."

            }

        }
        catch {

            Write-WRTEWarning "HTTPS internet connectivity could not be confirmed."

        }

        # Overall internet availability
        $InternetReachable = $InternetPing -or $HTTPSWorking

        Show-Section "Overall Status"

        if ($GatewayReachable -and
            $DNSWorking -and
            $InternetPing -and
            $HTTPSWorking) {

            Write-Success "Network connectivity appears healthy."

            $OverallStatus = "Healthy"

        }
        elseif ($GatewayReachable -and
                $DNSWorking -and
                $InternetReachable) {

            Write-WRTEWarning "Internet connectivity is available, but one connectivity test did not respond."

            if (-not $InternetPing) {
                Write-Info "ICMP may be blocked by the network or firewall."
            }

            if (-not $HTTPSWorking) {
                Write-Info "HTTPS connectivity could not be confirmed."
            }

            $OverallStatus = "Healthy - Limited Test Response"

        }
        elseif ($GatewayReachable -and
                $InternetReachable -and
                -not $DNSWorking) {

            Write-WRTEWarning "Internet is reachable, but DNS appears to be failing."

            $OverallStatus = "DNS Issue"

        }
        elseif ($GatewayReachable -and
                -not $InternetReachable) {

            Write-WRTEWarning "Local network is reachable, but internet access could not be confirmed."

            $OverallStatus = "Internet Issue"

        }
        elseif (-not $GatewayReachable) {

            Write-WRTEError "The default gateway could not be reached."

            $OverallStatus = "Gateway Issue"

        }
        else {

            Write-WRTEError "Network connectivity appears degraded."

            $OverallStatus = "Degraded"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Connectivity Test completed. Status: $OverallStatus. Gateway: $GatewayReachable. DNS: $DNSWorking. ICMP: $InternetPing. HTTPS: $HTTPSWorking. Internet: $InternetReachable. Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        Write-WRTEError "Unable to complete the connectivity test."

        Write-Log "Connectivity Test failed. $($_.Exception.Message)" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}