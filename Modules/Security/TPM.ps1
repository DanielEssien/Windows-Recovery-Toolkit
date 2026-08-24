###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : TPM.ps1
# Purpose    : Displays Trusted Platform Module status and
#              readiness information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Trusted Platform Module status.

.DESCRIPTION
Checks whether a Trusted Platform Module is present and reports
its availability, readiness, ownership, activation state, and
specification version where available.

The function is read-only and does not initialize, clear, reset,
or otherwise modify the TPM.

.EXAMPLE
Show-TPMStatus

.OUTPUTS
None

.NOTES
This function is read-only.
#>

function Show-TPMStatus {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "TPM Status"

    Write-Info "Collecting Trusted Platform Module information..."

    $StartTime = Get-Date

    try {

        $TPMAvailable = $false
        $TPMReady = $false
        $TPMEnabled = $false
        $TPMActivated = $false
        $TPMOwned = $false

        $ManufacturerName = "Unavailable"
        $ManufacturerVersion = "Unavailable"
        $SpecificationVersion = "Unavailable"

        #------------------------------------------------------
        # Primary TPM Query
        #------------------------------------------------------

        $GetTPMCommand =
            Get-Command `
                -Name Get-Tpm `
                -ErrorAction SilentlyContinue

        if ($GetTPMCommand) {

            try {

                $TPM =
                    Get-Tpm `
                        -ErrorAction Stop

                if ($TPM) {

                    $TPMAvailable =
                        [bool]$TPM.TpmPresent

                    $TPMReady =
                        [bool]$TPM.TpmReady

                    $TPMEnabled =
                        [bool]$TPM.TpmEnabled

                    $TPMActivated =
                        [bool]$TPM.TpmActivated

                    $TPMOwned =
                        [bool]$TPM.TpmOwned
                }
            }
            catch {

                Write-Log `
                    ("Get-Tpm query failed: {0}" `
                    -f $_.Exception.Message) `
                    -Level WARNING
            }
        }

        #------------------------------------------------------
        # TPM CIM Information
        #------------------------------------------------------

        $TPMCim = $null

        try {

            $TPMCim =
                Get-CimInstance `
                    -Namespace "root\CIMV2\Security\MicrosoftTpm" `
                    -ClassName Win32_Tpm `
                    -ErrorAction Stop
        }
        catch {

            Write-Log `
                ("Unable to query Win32_Tpm: {0}" `
                -f $_.Exception.Message) `
                -Level WARNING
        }

        if ($TPMCim) {

            $TPMAvailable = $true

            if ($TPMCim.ManufacturerVersion) {
                $ManufacturerVersion =
                    $TPMCim.ManufacturerVersion
            }

            if ($TPMCim.SpecVersion) {
                $SpecificationVersion =
                    $TPMCim.SpecVersion
            }

            if ($TPMCim.ManufacturerIdTxt) {
                $ManufacturerName =
                    $TPMCim.ManufacturerIdTxt
            }
        }

        #------------------------------------------------------
        # Summary
        #------------------------------------------------------

        Show-Section "Summary"

        $TPMPresentText =
            if ($TPMAvailable) {
                "Yes"
            }
            else {
                "No"
            }

        $TPMReadyText =
            if ($TPMReady) {
                "Yes"
            }
            else {
                "No"
            }

        $TPMEnabledText =
            if ($TPMEnabled) {
                "Yes"
            }
            else {
                "No"
            }

        $TPMActivatedText =
            if ($TPMActivated) {
                "Yes"
            }
            else {
                "No"
            }

        $TPMOwnedText =
            if ($TPMOwned) {
                "Yes"
            }
            else {
                "No"
            }

        Write-Property `
            "TPM Present" `
            $TPMPresentText

        Write-Property `
            "TPM Ready" `
            $TPMReadyText

        Write-Property `
            "TPM Enabled" `
            $TPMEnabledText

        Write-Property `
            "TPM Activated" `
            $TPMActivatedText

        Write-Property `
            "TPM Owned" `
            $TPMOwnedText
            
        #------------------------------------------------------
        # TPM Details
        #------------------------------------------------------

        Show-Section "TPM Details"

        Write-Property `
            "Manufacturer" `
            $ManufacturerName

        Write-Property `
            "Manufacturer Version" `
            $ManufacturerVersion

        Write-Property `
            "Specification Version" `
            $SpecificationVersion

        #------------------------------------------------------
        # Assessment
        #------------------------------------------------------

        Show-Section "Assessment"

        if (-not $TPMAvailable) {

            $Assessment =
                "No Trusted Platform Module was detected."

            Write-WRTEWarning $Assessment
        }
        elseif (-not $TPMEnabled) {

            $Assessment =
                "A TPM is present but is not enabled."

            Write-WRTEWarning $Assessment
        }
        elseif (-not $TPMReady) {

            $Assessment =
                "A TPM is present and enabled but is not ready for use."

            Write-WRTEWarning $Assessment
        }
        else {

            $Assessment =
                "The Trusted Platform Module is present, enabled, and ready for use."

            Write-Success $Assessment
        }

        #------------------------------------------------------
        # Completion
        #------------------------------------------------------

        $Duration =
            (Get-Date) - $StartTime

        Write-Log `
            ("TPM Status completed. Present: {0}. Ready: {1}. Enabled: {2}. Activated: {3}. Owned: {4}. Specification: {5}. Assessment: {6}. Duration: {7:N2} seconds." `
            -f $TPMAvailable,
                $TPMReady,
                $TPMEnabled,
                $TPMActivated,
                $TPMOwned,
                $SpecificationVersion,
                $Assessment,
                $Duration.TotalSeconds) `
            -Level INFO
    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEWarning `
            "Unable to collect TPM information."

        Write-Info `
            "Error: $ErrorMessage"

        Write-Log `
            "TPM Status failed. $ErrorMessage" `
            -Level ERROR
    }

    Show-Footer
    Wait-WRTE
}