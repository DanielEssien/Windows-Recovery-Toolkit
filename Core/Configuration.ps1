###############################################################
# Configuration Manager
###############################################################

$Global:WRTE_Config = $null

function Initialize-Configuration {

    $configPath = Join-Path $PSScriptRoot "..\Config\Settings.json"

    if (!(Test-Path $configPath)) {

        throw "Configuration file not found."

    }

    $Global:WRTE_Config = Get-Content $configPath -Raw | ConvertFrom-Json

}