###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : AdminTools.ps1
# Purpose    : Opens common Windows administrative tools.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Opens common Windows administrative tools.

.DESCRIPTION
Provides helper functions for launching commonly used Windows
administrative consoles from the WRTE Utilities module.

.EXAMPLE
Open-WRTEAdministrativeTools

.OUTPUTS
None
#>

function Open-WRTEAdministrativeTools {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Administrative Tools"

    Write-Info "Opening Windows administrative tools..."

    try {

        Start-Process `
            -FilePath "control.exe" `
            -ArgumentList "/name Microsoft.AdministrativeTools" `
            -ErrorAction Stop

        Write-Success "Administrative Tools opened successfully."

        Write-Log `
            "Administrative Tools opened successfully." `
            -Level INFO

    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEError "Unable to open Administrative Tools."
        Write-Info "Error: $ErrorMessage"

        Write-Log `
            "Administrative Tools launch failed. $ErrorMessage" `
            -Level ERROR

    }

    Show-Footer
    Wait-WRTE
}


<#
.SYNOPSIS
Opens Device Manager.

.DESCRIPTION
Launches the Windows Device Manager console.

.EXAMPLE
Open-WRTEDeviceManager

.OUTPUTS
None
#>

function Open-WRTEDeviceManager {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Device Manager"

    Write-Info "Opening Device Manager..."

    try {

        Start-Process `
            -FilePath "devmgmt.msc" `
            -ErrorAction Stop

        Write-Success "Device Manager opened successfully."

        Write-Log `
            "Device Manager opened successfully." `
            -Level INFO

    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEError "Unable to open Device Manager."
        Write-Info "Error: $ErrorMessage"

        Write-Log `
            "Device Manager launch failed. $ErrorMessage" `
            -Level ERROR

    }

    Show-Footer
    Wait-WRTE
}


<#
.SYNOPSIS
Opens Event Viewer.

.DESCRIPTION
Launches the Windows Event Viewer console.

.EXAMPLE
Open-WRTEEventViewer

.OUTPUTS
None
#>

function Open-WRTEEventViewer {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Event Viewer"

    Write-Info "Opening Event Viewer..."

    try {

        Start-Process `
            -FilePath "eventvwr.msc" `
            -ErrorAction Stop

        Write-Success "Event Viewer opened successfully."

        Write-Log `
            "Event Viewer opened successfully." `
            -Level INFO

    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEError "Unable to open Event Viewer."
        Write-Info "Error: $ErrorMessage"

        Write-Log `
            "Event Viewer launch failed. $ErrorMessage" `
            -Level ERROR

    }

    Show-Footer
    Wait-WRTE
}