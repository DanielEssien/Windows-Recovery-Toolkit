###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Core
# File       : Logger.ps1
# Purpose    : Provides centralized application logging
#              services.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

function Initialize-Logger {

    $config = Get-Configuration

    $logFolder = Join-Path $PSScriptRoot "..\$($config.Paths.Logs)"

    if (-not (Test-Path $logFolder)) {

        New-Item -Path $logFolder -ItemType Directory | Out-Null

    }

    $script:LogFile = Join-Path $logFolder $config.Logging.FileName

}

function Write-Log {

    param(

        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO","WARNING","ERROR")]
        [string]$Level = "INFO"

    )

    if (-not $script:LogFile) {
        throw "Logger has not been initialized."
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Add-Content -Path $script:LogFile `
        -Value "$timestamp [$Level] $Message"

}