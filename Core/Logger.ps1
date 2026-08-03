###############################################################
# Logging Engine
###############################################################

function Write-Log {

    param(

        [string]$Message,

        [string]$Level = "INFO"

    )

    if (-not $Global:WRTE_Config.Logging.Enabled) {

        return

    }

    $folder = Join-Path $PSScriptRoot "..\$($Global:WRTE_Config.Logging.Folder)"

    if (!(Test-Path $folder)) {

        New-Item $folder -ItemType Directory | Out-Null

    }

    $file = Join-Path $folder $Global:WRTE_Config.Logging.FileName

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Add-Content $file "[$time] [$Level] $Message"

}