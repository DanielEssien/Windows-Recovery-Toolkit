###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : BIOS.ps1
# Purpose    : Displays BIOS and firmware information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays BIOS information.

.DESCRIPTION
Retrieves BIOS vendor, version, release date, serial number,
SMBIOS version, and firmware characteristics.

.EXAMPLE
Show-BIOSInformation

.OUTPUTS
None
#>

function Show-BIOSInformation {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "BIOS Information"

    Write-Info "Collecting BIOS information..."

    $StartTime = Get-Date

    try {

        $BIOS = Get-CimInstance `
            -ClassName Win32_BIOS `
            -ErrorAction Stop |
            Select-Object -First 1

        $ComputerSystem = Get-CimInstance `
            -ClassName Win32_ComputerSystem `
            -ErrorAction Stop |
            Select-Object -First 1

        $ReleaseDate = if ($null -ne $BIOS.ReleaseDate) {
            $BIOS.ReleaseDate.ToString("yyyy-MM-dd")
        }
        else {
            "Unavailable"
        }

        Write-BlankLine

        Write-Property "Manufacturer" $BIOS.Manufacturer
        Write-Property "BIOS Version" $BIOS.SMBIOSBIOSVersion
        Write-Property "Release Date" $ReleaseDate
        Write-Property "Serial Number" $BIOS.SerialNumber

        Write-Property "SMBIOS Version" `
            ("{0}.{1}" -f `
                $BIOS.SMBIOSMajorVersion,
                $BIOS.SMBIOSMinorVersion)

        Write-Property "System Manufacturer" $ComputerSystem.Manufacturer
        Write-Property "System Model" $ComputerSystem.Model

        $Elapsed = (Get-Date) - $StartTime

        Write-BlankLine
        Write-Property "Execution Time" `
            ("{0:N2} sec" -f $Elapsed.TotalSeconds)

        Write-Log "BIOS Information completed. BIOS Version: $($BIOS.SMBIOSBIOSVersion). Duration: $($Elapsed.TotalSeconds.ToString('N2')) seconds."

    }
    catch {

        Write-WRTEError "Unable to retrieve BIOS information."

        Write-Log "BIOS Information failed. $($_.Exception.Message)" `
            -Level "ERROR"

    }

    Show-Footer
    Wait-WRTE
}