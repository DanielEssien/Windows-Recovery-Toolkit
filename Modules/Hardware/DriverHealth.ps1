###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : DriverHealth.ps1
# Purpose    : Evaluates Plug and Play device health and
#              surfaces devices with driver or configuration
#              problems.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays driver and device health information.

.DESCRIPTION
Inspects Windows Plug and Play devices for configuration
problems and surfaces driver metadata for affected devices.

This function is read-only and does not install, remove,
enable, disable, or update any device or driver.

.EXAMPLE
Show-DriverHealth

.OUTPUTS
None

.NOTES
This function is read-only.
#>

function Show-DriverHealth {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Driver & Device Health"

    Write-Info "Collecting device and driver information..."

    $StartTime = Get-Date

    try {

        #------------------------------------------------------
        # Plug and Play Devices
        #------------------------------------------------------

        $Devices = @(
            Get-CimInstance `
                -ClassName Win32_PnPEntity `
                -ErrorAction SilentlyContinue
        )

        $ProblemDevices = @(
            $Devices |
                Where-Object {
                    $_.ConfigManagerErrorCode -ne 0
                } |
                Sort-Object Name
        )

        $HealthyDevices = @(
            $Devices |
                Where-Object {
                    $_.ConfigManagerErrorCode -eq 0
                }
        )

        $DisabledDevices = @(
            $ProblemDevices |
                Where-Object {
                    $_.ConfigManagerErrorCode -eq 22
                }
        )

        $ActiveProblemDevices = @(
            $ProblemDevices |
                Where-Object {
                    $_.ConfigManagerErrorCode -ne 22
                }
        )

        #------------------------------------------------------
        # Driver Information
        #------------------------------------------------------

        $SignedDrivers = @(
            Get-CimInstance `
                -ClassName Win32_PnPSignedDriver `
                -ErrorAction SilentlyContinue
        )

        #------------------------------------------------------
        # Configuration Manager Error Descriptions
        #------------------------------------------------------

        $ErrorCodeDescriptions = @{
            1  = "Device is not configured correctly."
            3  = "Driver may be corrupted or system resources may be low."
            10 = "Device cannot start."
            12 = "Device cannot find enough free resources."
            14 = "Device requires a restart."
            18 = "Drivers for this device should be reinstalled."
            19 = "Registry configuration for this device may be damaged."
            21 = "Windows is removing this device."
            22 = "Device is disabled."
            24 = "Device is not present, not working properly, or lacks required drivers."
            28 = "Drivers for this device are not installed."
            29 = "Device firmware did not provide required resources."
            31 = "Windows cannot load the required drivers."
            32 = "Driver service for this device has been disabled."
            33 = "Windows cannot determine required resources."
            34 = "Windows cannot determine device settings."
            35 = "System firmware does not contain enough information."
            36 = "Device is requesting a PCI interrupt."
            37 = "Windows cannot initialize the device driver."
            38 = "Windows cannot load the driver because a previous instance remains in memory."
            39 = "Driver may be corrupted or missing."
            40 = "Windows cannot access required driver information."
            41 = "Driver loaded but Windows cannot find the hardware."
            42 = "A duplicate device is already running."
            43 = "Device reported a problem and was stopped."
            44 = "An application or service shut down the device."
            45 = "Device is currently disconnected."
            46 = "Windows cannot access the device because the operating system is shutting down."
            47 = "Device has been prepared for safe removal."
            48 = "Device software has been blocked from starting."
            49 = "Windows cannot start new hardware devices because the system hive is too large."
            50 = "Windows cannot apply all device properties."
            51 = "Device is waiting for another device to start."
            52 = "Windows cannot verify the digital signature for the required drivers."
            53 = "Device is reserved for use by the Windows kernel debugger."
            54 = "Device has failed and is undergoing reset."
        }

        #------------------------------------------------------
        # Summary
        #------------------------------------------------------

        Show-Section "Summary"

        Write-Property `
            "Devices Detected" `
            $Devices.Count

        Write-Property `
            "Healthy Devices" `
            $HealthyDevices.Count

        Write-Property `
            "Active Problems" `
            $ActiveProblemDevices.Count

        Write-Property `
            "Disabled Devices" `
            $DisabledDevices.Count

        Write-Property `
            "Signed Drivers Detected" `
            $SignedDrivers.Count

        #------------------------------------------------------
        # Problem Devices
        #------------------------------------------------------

        Show-Section "Problem Devices"

        if ($ProblemDevices.Count -eq 0) {

            Write-Success `
                "No Plug and Play device configuration problems were detected."
        }
        else {

            $ProblemDevicesToDisplay = @(
                $ProblemDevices |
                    Select-Object -First 10
            )

            foreach ($Device in $ProblemDevicesToDisplay) {

                $ErrorCode =
                    [int]$Device.ConfigManagerErrorCode

                if (
                    $ErrorCodeDescriptions.ContainsKey(
                        $ErrorCode
                    )
                ) {
                    $ErrorDescription =
                        $ErrorCodeDescriptions[$ErrorCode]
                }
                else {
                    $ErrorDescription =
                        "Unknown device configuration problem."
                }

                #--------------------------------------------------
                # Match device to signed driver
                #--------------------------------------------------

                $Driver = @(
                    $SignedDrivers |
                        Where-Object {
                            $_.DeviceID -eq $Device.PNPDeviceID
                        } |
                        Select-Object -First 1
                )

                #--------------------------------------------------
                # Normalize device values
                #--------------------------------------------------

                if ($Device.Name) {
                    $DeviceName = $Device.Name
                }
                else {
                    $DeviceName = "Unknown Device"
                }

                if ($Device.PNPClass) {
                    $PNPClass = $Device.PNPClass
                }
                else {
                    $PNPClass = "Unavailable"
                }

                if ($Device.Status) {
                    $DeviceStatus = $Device.Status
                }
                else {
                    $DeviceStatus = "Unavailable"
                }

                Write-Property `
                    "Device" `
                    $DeviceName

                Write-Property `
                    "PNP Class" `
                    $PNPClass

                Write-Property `
                    "Status" `
                    $DeviceStatus

                Write-Property `
                    "Error Code" `
                    $ErrorCode

                Write-Property `
                    "Problem" `
                    $ErrorDescription

                #--------------------------------------------------
                # Driver metadata
                #--------------------------------------------------

                if ($Driver.Count -gt 0) {

                    $DriverInfo =
                        $Driver[0]

                    if ($DriverInfo.DriverProviderName) {
                        $DriverProvider =
                            $DriverInfo.DriverProviderName
                    }
                    else {
                        $DriverProvider =
                            "Unavailable"
                    }

                    if ($DriverInfo.DriverVersion) {
                        $DriverVersion =
                            $DriverInfo.DriverVersion
                    }
                    else {
                        $DriverVersion =
                            "Unavailable"
                    }

                    if ($DriverInfo.DriverDate) {
                        $DriverDate =
                            $DriverInfo.DriverDate.ToString(
                                "dd/MM/yyyy"
                            )
                    }
                    else {
                        $DriverDate =
                            "Unavailable"
                    }
                }
                else {

                    $DriverProvider =
                        "Unavailable"

                    $DriverVersion =
                        "Unavailable"

                    $DriverDate =
                        "Unavailable"
                }

                Write-Property `
                    "Driver Provider" `
                    $DriverProvider

                Write-Property `
                    "Driver Version" `
                    $DriverVersion

                Write-Property `
                    "Driver Date" `
                    $DriverDate

                Write-BlankLine
            }

            if (
                $ProblemDevices.Count -gt
                $ProblemDevicesToDisplay.Count
            ) {

                Write-Info `
                    "$($ProblemDevices.Count - $ProblemDevicesToDisplay.Count) additional problem devices were not displayed."
            }
        }

        #------------------------------------------------------
        # Disabled Devices
        #------------------------------------------------------

        Show-Section "Disabled Devices"

        if ($DisabledDevices.Count -eq 0) {

            Write-Info `
                "No disabled Plug and Play devices were detected."
        }
        else {

            $DisabledDevicesToDisplay = @(
                $DisabledDevices |
                    Select-Object -First 10
            )

            foreach ($Device in $DisabledDevicesToDisplay) {

                if ($Device.Name) {
                    $DeviceName = $Device.Name
                }
                else {
                    $DeviceName = "Unknown Device"
                }

                if ($Device.PNPClass) {
                    $PNPClass = $Device.PNPClass
                }
                else {
                    $PNPClass = "Unavailable"
                }

                Write-Property `
                    "Device" `
                    $DeviceName

                Write-Property `
                    "PNP Class" `
                    $PNPClass

                Write-BlankLine
            }

            if (
                $DisabledDevices.Count -gt
                $DisabledDevicesToDisplay.Count
            ) {

                Write-Info `
                    "$($DisabledDevices.Count - $DisabledDevicesToDisplay.Count) additional disabled devices were not displayed."
            }
        }

        #------------------------------------------------------
        # Assessment
        #------------------------------------------------------

        Show-Section "Assessment"

        if (
            $ActiveProblemDevices.Count -eq 0 -and
            $DisabledDevices.Count -eq 0
        ) {

            $Assessment =
                "No device configuration or driver problems were detected."

            Write-Success $Assessment
        }
        elseif (
            $ActiveProblemDevices.Count -eq 0 -and
            $DisabledDevices.Count -gt 0
        ) {

            $Assessment =
                "No active device problems were detected. Disabled devices are present and may be intentionally disabled."

            Write-Info $Assessment
        }
        elseif ($ActiveProblemDevices.Count -le 3) {

            $Assessment =
                "A small number of active device configuration or driver problems were detected."

            Write-WRTEWarning $Assessment
        }
        else {

            $Assessment =
                "Multiple active device configuration or driver problems were detected. Driver or hardware review is recommended."

            Write-WRTEWarning $Assessment
        }

        #------------------------------------------------------
        # Completion
        #------------------------------------------------------

        $Duration =
            (Get-Date) - $StartTime

        Write-Log `
            ("Driver & Device Health completed. Devices: {0}. Healthy: {1}. Active Problems: {2}. Disabled Devices: {3}. Signed Drivers: {4}. Assessment: {5}. Duration: {6:N2} seconds." `
            -f $Devices.Count,
                $HealthyDevices.Count,
                $ActiveProblemDevices.Count,
                $DisabledDevices.Count,
                $SignedDrivers.Count,
                $Assessment,
                $Duration.TotalSeconds) `
            -Level INFO
    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEWarning `
            "Unable to collect driver and device health information."

        Write-Info `
            "Error: $ErrorMessage"

        Write-Log `
            "Driver & Device Health failed. $ErrorMessage" `
            -Level ERROR
    }

    Show-Footer
    Wait-WRTE
}