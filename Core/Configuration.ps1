###############################################################
# Configuration Manager
###############################################################

$script:Configuration = $null

function Initialize-Configuration {

    $configPath = Join-Path $PSScriptRoot "..\Config\Settings.json"

    if (-not (Test-Path $configPath)) {
        throw "Configuration file not found: $configPath"
    }

    $script:Configuration = Get-Content $configPath -Raw | ConvertFrom-Json
}

function Get-Configuration {

    if ($null -eq $script:Configuration) {
        throw "Configuration has not been initialized."
    }

    return $script:Configuration
}