###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Defender.ps1
# Purpose    : Displays Microsoft Defender security status.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Microsoft Defender status.

.DESCRIPTION
Retrieves Microsoft Defender antivirus status, real-time
protection state, signature information, and recent scan details.

.EXAMPLE
Show-DefenderStatus

.OUTPUTS
None

.NOTES
Microsoft Defender may be disabled or operating in passive mode
when another antivirus product is registered with Windows.
#>

function Show-DefenderStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Microsoft Defender Status"

    Write-Info "Collecting Microsoft Defender information..."

    $StartTime = Get-Date

    try {

        $DefenderService = Get-Service `
            -Name "WinDefend" `
            -ErrorAction SilentlyContinue

        $DefenderStatus = $null

        try {

            $DefenderStatus = Get-MpComputerStatus `
                -ErrorAction Stop

        }
        catch {

            $DefenderStatus = $null

        }

        Show-Section "Service"

        if ($null -ne $DefenderService) {

            Write-Property "WinDefend Service" $DefenderService.Status

        }
        else {

            Write-Property "WinDefend Service" "Unavailable"

        }

        if ($null -eq $DefenderStatus) {

            Write-BlankLine
            Write-WRTEWarning "Microsoft Defender status information is unavailable."
            Write-Info "A third-party antivirus product may be managing endpoint protection."

            Write-Log "Microsoft Defender Status completed. Defender information unavailable." `
                -Level "WARNING"

            Show-Footer
            Wait-WRTE
            return
        }

        Show-Section "Protection Status"

        Write-Property "Antivirus Enabled" $DefenderStatus.AntivirusEnabled
        Write-Property "Antispyware Enabled" $DefenderStatus.AntispywareEnabled
        Write-Property "Real-Time Protection" $DefenderStatus.RealTimeProtectionEnabled
        Write-Property "Behavior Monitor" $DefenderStatus.BehaviorMonitorEnabled
        Write-Property "IOAV Protection" $DefenderStatus.IoavProtectionEnabled

        Show-Section "Signature Information"

        if (-not [string]::IsNullOrWhiteSpace(
                $DefenderStatus.AntivirusSignatureVersion
            )) {

            Write-Property "Signature Version" `
                $DefenderStatus.AntivirusSignatureVersion

        }
        else {

            Write-Property "Signature Version" "Unavailable"

        }

        if ($null -ne $DefenderStatus.AntivirusSignatureLastUpdated) {

            Write-Property "Last Updated" `
                ($DefenderStatus.AntivirusSignatureLastUpdated.ToString("yyyy-MM-dd HH:mm:ss"))

        }
        else {

            Write-Property "Last Updated" "Unavailable"

        }

        if ($null -ne $DefenderStatus.AntivirusSignatureAge -and
            $DefenderStatus.AntivirusSignatureAge -ne 65535) {

            Write-Property "Signature Age" `
                ("{0} day(s)" -f $DefenderStatus.AntivirusSignatureAge)

        }
        else {

            Write-Property "Signature Age" "Unavailable"

        }

        Show-Section "Scan Information"

        if ($null -ne $DefenderStatus.QuickScanEndTime) {

            Write-Property "Last Quick Scan" `
                ($DefenderStatus.QuickScanEndTime.ToString("yyyy-MM-dd HH:mm:ss"))

        }
        else {

            Write-Property "Last Quick Scan" "Unavailable"

        }

        if ($null -ne $DefenderStatus.FullScanEndTime) {

            Write-Property "Last Full Scan" `
                ($DefenderStatus.FullScanEndTime.ToString("yyyy-MM-dd HH:mm:ss"))

        }
        else {

            Write-Property "Last Full Scan" "Unavailable"

        }

        Show-Section "Assessment"

        if ($DefenderStatus.AntivirusEnabled -and
            $DefenderStatus.RealTimeProtectionEnabled) {

            Write-Success "Microsoft Defender protection is active."

            $Assessment = "Active"

        }
        elseif (-not $DefenderStatus.AntivirusEnabled -and
                -not $DefenderStatus.RealTimeProtectionEnabled) {

            Write-WRTEWarning "Microsoft Defender protection is not active."
            Write-Info "Another antivirus product may be providing protection."

            $Assessment = "Defender Inactive"

        }
        else {

            Write-WRTEWarning "Microsoft Defender is only partially active."

            $Assessment = "Partial"

        }

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "Microsoft Defender Status completed. Assessment: $Assessment. Antivirus Enabled: $($DefenderStatus.AntivirusEnabled). Real-Time Protection: $($DefenderStatus.RealTimeProtectionEnabled). Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        $ErrorMessage = $_.Exception.Message

        Write-WRTEError "Unable to retrieve Microsoft Defender status."
        Write-Info "Error: $ErrorMessage"

        Write-Log "Microsoft Defender Status failed. $ErrorMessage" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}