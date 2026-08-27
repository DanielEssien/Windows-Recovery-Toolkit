###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Core
# File       : Configuration.ps1
# Purpose    : Loads and provides access to application
#              configuration settings.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

$script:Configuration = $null

function Initialize-Configuration {

    $configPath = Join-Path $PSScriptRoot "..\Config\Settings.json"

    if (-not (Test-Path $configPath)) {
        throw "Configuration file not found: $configPath"
    }

    $script:Configuration =
        Get-Content `
            -Path $configPath `
            -Raw `
            -ErrorAction Stop |
        ConvertFrom-Json `
            -ErrorAction Stop

    if (-not (Test-WRTEConfiguration -Configuration $script:Configuration)) {
        $script:Configuration = $null
        throw "WRTE configuration validation failed."
    }
}

function Get-Configuration {

    if ($null -eq $script:Configuration) {
        throw "Configuration has not been initialized."
    }

    return $script:Configuration
}