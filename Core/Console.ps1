###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Core
# File       : Console.ps1
# Purpose    : Provides reusable console user interface
#              functions.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

function Clear-WRTE {

    [CmdletBinding()]
    param()

    Clear-Host

}

function Show-Banner {

    [CmdletBinding()]
    param()

    $Config = Get-Configuration

    Clear-WRTE

    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host (" {0}" -f $Config.Application.Name) -ForegroundColor Green
    Write-Host (" {0}" -f $Config.Application.Motto) -ForegroundColor DarkCyan
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host ""

}

function Show-Section {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Title

    )

    Write-Host ""
    Write-Host $Title -ForegroundColor Yellow
    Write-Host ("-" * $Title.Length) -ForegroundColor DarkGray

}

function Write-Info {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Message

    )

    Write-Host "[INFO]  $Message" -ForegroundColor Cyan

}

function Write-Success {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Message

    )

    Write-Host "[ OK ]  $Message" -ForegroundColor Green

}

function Write-WRTEWarning {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Message

    )

    Write-Host "[WARN]  $Message" -ForegroundColor Yellow

}

function Write-WRTEError {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Message

    )

    Write-Host "[FAIL]  $Message" -ForegroundColor Red

}

function Wait-WRTE {

    [CmdletBinding()]
    param()

    Write-Host ""

    Read-Host "Press ENTER to continue"

}

<#
.SYNOPSIS
Displays a formatted name/value pair.

.DESCRIPTION
Displays a property label and its value using
consistent alignment throughout WRTE.

.PARAMETER Name
The property name.

.PARAMETER Value
The property value.
#>

function Write-Property {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [AllowNull()]
        $Value

    )

    Write-Host ("{0,-20}: {1}" -f $Name, $Value)

}

<#
.SYNOPSIS
Displays a formatted WRTE menu item.

.DESCRIPTION
Displays a menu option with consistent formatting
throughout the application.

.PARAMETER Key
The selection key.

.PARAMETER Description
The menu description.
#>

function Write-MenuItem {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Description

    )

    Write-Host ("[{0}] {1}" -f $Key, $Description)

}

<#
.SYNOPSIS
Displays the WRTE footer.

.DESCRIPTION
Displays a separator at the bottom of a screen.
#>

function Show-Footer {

    [CmdletBinding()]
    param()

    $Config = Get-Configuration

    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor DarkGray
    Write-Host ("Version {0} | © 2026 {1}" -f `
        $Config.Application.Version,
        $Config.Application.Author) -ForegroundColor DarkGray

}

function Write-BlankLine {

    [CmdletBinding()]
    param()

    Write-Host ""

}