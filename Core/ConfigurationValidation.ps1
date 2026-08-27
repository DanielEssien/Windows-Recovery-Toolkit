###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Core
# File       : ConfigurationValidation.ps1
# Purpose    : Validates required WRTE configuration settings.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

function Test-WRTEConfiguration {

    <#
    .SYNOPSIS
        Validates the WRTE configuration object.

    .DESCRIPTION
        Confirms that required configuration sections and properties
        exist and contain usable values.

    .PARAMETER Configuration
        The configuration object to validate.

    .OUTPUTS
        System.Boolean
    #>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [object]$Configuration
    )

    if ($null -eq $Configuration) {
        return $false
    }

    if ($null -eq $Configuration.Application) {
        return $false
    }

    $RequiredApplicationProperties = @(
        "Name",
        "ShortName",
        "Version",
        "Author",
        "Company",
        "Motto"
    )

    foreach ($Property in $RequiredApplicationProperties) {

        $Value =
            $Configuration.Application.$Property

        if ([string]::IsNullOrWhiteSpace([string]$Value)) {
            return $false
        }
    }

    if ($null -eq $Configuration.Paths) {
        return $false
    }

    if ([string]::IsNullOrWhiteSpace(
        [string]$Configuration.Paths.Logs
    )) {
        return $false
    }

    return $true
}