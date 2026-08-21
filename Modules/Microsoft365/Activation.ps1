# Activation.ps1

###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Activation.ps1
# Purpose    : Displays Microsoft Office activation and
#              licensing information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Microsoft Office activation status.

.DESCRIPTION
Retrieves available Microsoft Office licensing information from
the Windows Software Protection Platform and reports detected
Office products, license status, license description, and partial
product keys.

Where available, the function also queries Microsoft's Office
Software Protection Platform script (OSPP.VBS) for additional
licensing information.

Microsoft 365 subscription activation does not always expose all
licensing details through the traditional Software Licensing
interfaces. WRTE therefore reports only information observable
from supported local Windows and Office licensing components.

.EXAMPLE
Show-OfficeActivationStatus

.OUTPUTS
None

.NOTES
This function is read-only.

License status values are translated from the Windows Software
Protection Platform LicenseStatus property.
#>

function Show-OfficeActivationStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Office Activation"

    Write-Info "Collecting Microsoft Office licensing information..."

    $StartTime = Get-Date

    try {

        #------------------------------------------------------
        # Helper: Translate License Status
        #------------------------------------------------------

        function ConvertTo-WRTELicenseStatus {

            param(
                [Parameter(Mandatory)]
                [int]$Status
            )

            switch ($Status) {

                0 { return "Unlicensed" }

                1 { return "Licensed" }

                2 { return "Out-of-Box Grace" }

                3 { return "Out-of-Tolerance Grace" }

                4 { return "Non-Genuine Grace" }

                5 { return "Notification" }

                6 { return "Extended Grace" }

                default { return "Unknown" }
            }
        }

        #------------------------------------------------------
        # Installed Office Product Information
        #------------------------------------------------------

        $ClickToRunPath =
            "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"

        if (Test-Path $ClickToRunPath) {

            try {

                $OfficeConfig =
                    Get-ItemProperty `
                        -Path $ClickToRunPath `
                        -ErrorAction Stop

                if ($OfficeConfig.ProductReleaseIds) {

                    Write-Property `
                        "Installed Product" `
                        ($OfficeConfig.ProductReleaseIds -replace ",", ", ")
                }

                if ($OfficeConfig.ClientVersionToReport) {

                    Write-Property `
                        "Office Version" `
                        $OfficeConfig.ClientVersionToReport
                }
            }
            catch {

                Write-Log `
                    ("Unable to read Office Click-to-Run configuration: {0}" `
                    -f $_.Exception.Message) `
                    -Level WARNING
            }
        }

        #------------------------------------------------------
        # Software Licensing Platform
        #------------------------------------------------------

        Show-Section "Licensing Status"

        $OfficeLicenses = @()

        try {

            $OfficeLicenses = @(
                Get-CimInstance `
                    -ClassName SoftwareLicensingProduct `
                    -ErrorAction Stop |
                Where-Object {

                    $_.Name -match "Office" -and
                    (
                        $_.PartialProductKey -or
                        $_.LicenseStatus -ne 0
                    )
                }
            )
        }
        catch {

            Write-Log `
                ("Unable to query SoftwareLicensingProduct: {0}" `
                -f $_.Exception.Message) `
                -Level WARNING
        }

        #------------------------------------------------------
        # Display Licensing Records
        #------------------------------------------------------

        if ($OfficeLicenses) {

            $LicenseNumber = 0

            foreach ($License in $OfficeLicenses) {

                $LicenseNumber++

                if ($OfficeLicenses.Count -gt 1) {

                    Write-Info `
                        ("License record {0}" -f $LicenseNumber)
                }

                if ($License.Name) {

                    Write-Property `
                        "Product" `
                        $License.Name
                }

                if ($License.Description) {

                    Write-Property `
                        "Description" `
                        $License.Description
                }

                $LicenseStatus =
                    ConvertTo-WRTELicenseStatus `
                        -Status $License.LicenseStatus

                Write-Property `
                    "License Status" `
                    $LicenseStatus

                if ($License.PartialProductKey) {

                    Write-Property `
                        "Partial Product Key" `
                        $License.PartialProductKey
                }

                if ($License.ProductKeyChannel) {

                    Write-Property `
                        "License Channel" `
                        $License.ProductKeyChannel
                }

                if ($License.ID) {

                    Write-Property `
                        "License ID" `
                        $License.ID
                }

                if ($OfficeLicenses.Count -gt 1) {

                    Write-Host ""
                }
            }
        }
        else {

            Write-WRTEWarning `
                "No traditional Office licensing records were detected."

            Write-Info `
                "Microsoft 365 subscription activation may not expose complete licensing information through this interface."
        }

        #------------------------------------------------------
        # OSPP.VBS Detection
        #------------------------------------------------------

        Show-Section "Office Software Protection Platform"

        $OSPPPaths = @(

            "$env:ProgramFiles\Microsoft Office\Office16\OSPP.VBS",

            "${env:ProgramFiles(x86)}\Microsoft Office\Office16\OSPP.VBS",

            "$env:ProgramFiles\Microsoft Office\root\Office16\OSPP.VBS",

            "${env:ProgramFiles(x86)}\Microsoft Office\root\Office16\OSPP.VBS",

            "$env:ProgramFiles\Microsoft Office\Office15\OSPP.VBS",

            "${env:ProgramFiles(x86)}\Microsoft Office\Office15\OSPP.VBS"
        )

        $OSPPPath =
            $OSPPPaths |
            Where-Object {
                $_ -and (Test-Path $_)
            } |
            Select-Object -First 1

        if ($OSPPPath) {

            Write-Property `
                "OSPP.VBS" `
                "Available"

            Write-Property `
                "OSPP Path" `
                $OSPPPath

            try {

                $OSPPOutput =
                    & cscript.exe `
                        //Nologo `
                        $OSPPPath `
                        /dstatus 2>&1

                $OSPPText =
                    $OSPPOutput |
                    Out-String

                #--------------------------------------------------
                # Extract useful OSPP information
                #--------------------------------------------------

                $LicenseName =
                    $OSPPOutput |
                    Where-Object {
                        $_ -match "LICENSE NAME:"
                    } |
                    Select-Object -First 1

                if ($LicenseName) {

                    $Value =
                        ($LicenseName -replace ".*LICENSE NAME:\s*", "").Trim()

                    Write-Property `
                        "OSPP License" `
                        $Value
                }

                $LicenseDescription =
                    $OSPPOutput |
                    Where-Object {
                        $_ -match "LICENSE DESCRIPTION:"
                    } |
                    Select-Object -First 1

                if ($LicenseDescription) {

                    $Value =
                        ($LicenseDescription `
                            -replace ".*LICENSE DESCRIPTION:\s*", "").Trim()

                    Write-Property `
                        "OSPP Description" `
                        $Value
                }

                $OSPPStatus =
                    $OSPPOutput |
                    Where-Object {
                        $_ -match "LICENSE STATUS:"
                    } |
                    Select-Object -First 1

                if ($OSPPStatus) {

                    $Value =
                        ($OSPPStatus `
                            -replace ".*LICENSE STATUS:\s*", "").Trim()

                    Write-Property `
                        "OSPP Status" `
                        $Value
                }

                $LastFive =
                    $OSPPOutput |
                    Where-Object {
                        $_ -match "Last 5 characters"
                    } |
                    Select-Object -First 1

                if ($LastFive) {

                    $Value =
                        ($LastFive `
                            -replace ".*Last 5 characters of installed product key:\s*", "").Trim()

                    Write-Property `
                        "OSPP Partial Key" `
                        $Value
                }

                if ([string]::IsNullOrWhiteSpace($OSPPText)) {

                    Write-Info `
                        "OSPP returned no licensing information."
                }
            }
            catch {

                Write-WRTEWarning `
                    "Unable to query Office Software Protection Platform."

                Write-Log `
                    ("OSPP query failed: {0}" `
                    -f $_.Exception.Message) `
                    -Level WARNING
            }
        }
        else {

            Write-Property `
                "OSPP.VBS" `
                "Not detected"

            Write-Info `
                "This is normal for some Microsoft 365 Apps installations."
        }

        #------------------------------------------------------
        # Summary
        #------------------------------------------------------

        Show-Section "Activation Summary"

        $LicensedOffice =
            $OfficeLicenses |
            Where-Object {
                $_.LicenseStatus -eq 1
            }

        if ($LicensedOffice) {

            Write-Property `
                "Activation State" `
                "Licensed"
        }
        elseif ($OfficeLicenses) {

            $States =
                $OfficeLicenses |
                ForEach-Object {
                    ConvertTo-WRTELicenseStatus `
                        -Status $_.LicenseStatus
                } |
                Select-Object -Unique

            Write-Property `
                "Activation State" `
                ($States -join ", ")
        }
        else {

            Write-Property `
                "Activation State" `
                "Unable to determine"
        }

        #------------------------------------------------------
        # Completion
        #------------------------------------------------------

        $Duration =
            (Get-Date) - $StartTime

        Write-Log `
            ("Office activation check completed in {0:N2} seconds." `
            -f $Duration.TotalSeconds) `
            -Level INFO
    }
    catch {

        Write-WRTEWarning `
            "Unable to determine Microsoft Office activation status."

        Write-Log `
            ("Office activation check failed: {0}" `
            -f $_.Exception.Message) `
            -Level ERROR
    }

    Show-Footer
    Wait-WRTE
}