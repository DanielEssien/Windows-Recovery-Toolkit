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
function Get-WRTETheme {

    [CmdletBinding()]
    param()

    $Config = Get-Configuration

    return $Config.Theme

}
function Show-Banner {

    [CmdletBinding()]
    param()

    $Config = Get-Configuration

    $PrimaryColor = Get-WRTEColor `
        -Name "Primary" `
        -Fallback Cyan

    $SecondaryColor = Get-WRTEColor `
        -Name "Secondary" `
        -Fallback Green

    $MottoColor = Get-WRTEColor `
        -Name "Motto" `
        -Fallback DarkCyan

    Clear-WRTE

    Write-Host ""
    Write-Host ("=" * 60) `
        -ForegroundColor $PrimaryColor

    Write-Host (" {0}" -f $Config.Application.Name) `
        -ForegroundColor $SecondaryColor

    Write-Host (" {0}" -f $Config.Application.Motto) `
        -ForegroundColor $MottoColor

    Write-Host ("=" * 60) `
        -ForegroundColor $PrimaryColor

    Write-Host ""
}
function Show-Section {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title
    )

    $SectionColor = Get-WRTEColor `
        -Name "Section" `
        -Fallback Yellow

    $SeparatorColor = Get-WRTEColor `
        -Name "Separator" `
        -Fallback DarkGray

    Write-Host ""
    Write-Host $Title `
        -ForegroundColor $SectionColor

    Write-Host ("-" * $Title.Length) `
        -ForegroundColor $SeparatorColor
}
function Write-Info {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $Color = Get-WRTEColor `
        -Name "Info" `
        -Fallback Cyan

    Write-Host "[INFO]  $Message" `
        -ForegroundColor $Color
}
function Write-Success {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $Color = Get-WRTEColor `
        -Name "Success" `
        -Fallback Green

    Write-Host "[ OK ]  $Message" `
        -ForegroundColor $Color
}
function Write-WRTEWarning {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $Color = Get-WRTEColor `
        -Name "Warning" `
        -Fallback Yellow

    Write-Host "[WARN]  $Message" `
        -ForegroundColor $Color
}
function Write-WRTEError {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $Color = Get-WRTEColor `
        -Name "Error" `
        -Fallback Red

    Write-Host "[FAIL]  $Message" `
        -ForegroundColor $Color
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

    $SeparatorColor = Get-WRTEColor `
        -Name "Separator" `
        -Fallback DarkGray

    $FooterColor = Get-WRTEColor `
        -Name "Footer" `
        -Fallback DarkGray

    $Copyright = [char]0x00A9

    Write-Host ""
    Write-Host ("=" * 60) `
        -ForegroundColor $SeparatorColor

    Write-Host (
        "Version {0} | {1} 2026 {2}" -f `
        $Config.Application.Version,
        $Copyright,
        $Config.Application.Author
    ) -ForegroundColor $FooterColor
}

function Write-BlankLine {

    [CmdletBinding()]
    param()

    Write-Host ""

}

function Get-WRTEColor {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [ConsoleColor]$Fallback
    )

    $Theme = Get-WRTETheme
    $Value = $Theme.$Name

    if ([string]::IsNullOrWhiteSpace($Value)) {

        return $Fallback

    }

    try {

        return [ConsoleColor](
            [Enum]::Parse(
                [ConsoleColor],
                $Value,
                $true
            )
        )

    }
    catch {

        return $Fallback

    }

}