###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : ReportHelpers.ps1
# Purpose    : Provides reusable report helper functions.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Returns the WRTE reports directory.

.DESCRIPTION
Resolves the Reports directory relative to the WRTE project root
and creates the directory when it does not already exist.

.EXAMPLE
Get-WRTEReportPath

.OUTPUTS
System.String
#>

function Get-WRTEReportPath {

    [CmdletBinding()]
    param()

    $ProjectRoot =
        Split-Path `
            -Path $PSScriptRoot `
            -Parent |
        Split-Path `
            -Parent

    $ReportPath =
        Join-Path `
            -Path $ProjectRoot `
            -ChildPath "Reports"

    if (-not (Test-Path -Path $ReportPath)) {

        New-Item `
            -Path $ReportPath `
            -ItemType Directory `
            -Force |
        Out-Null

    }

    return $ReportPath
}


<#
.SYNOPSIS
Creates a WRTE report filename.

.DESCRIPTION
Generates a timestamped report filename containing the report
type and local computer name.

.PARAMETER ReportType
Specifies the type of report being generated.

.EXAMPLE
New-WRTEReportFileName -ReportType "SystemReport"

.OUTPUTS
System.String
#>

function New-WRTEReportFileName {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$ReportType

    )

    $Timestamp =
        Get-Date `
            -Format "yyyyMMdd-HHmmss"

    $ComputerName =
        if ([string]::IsNullOrWhiteSpace($env:COMPUTERNAME)) {
            "UnknownComputer"
        }
        else {
            $env:COMPUTERNAME
        }

    return "WRTE-$ReportType-$ComputerName-$Timestamp.txt"
}


<#
.SYNOPSIS
Creates the standard WRTE report header.

.DESCRIPTION
Returns a formatted text header containing WRTE report metadata.

.PARAMETER Title
Specifies the report title.

.EXAMPLE
New-WRTEReportHeader -Title "System Report"

.OUTPUTS
System.String[]
#>

function New-WRTEReportHeader {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Title

    )

    $Generated =
        Get-Date `
            -Format "yyyy-MM-dd HH:mm:ss"

    return @(

        "============================================================"
        " Windows Recovery Toolkit Enterprise"
        " Diagnose. Repair. Restore."
        "============================================================"
        ""
        $Title
        ("-" * $Title.Length)
        ""
        "Generated          : $Generated"
        "Computer           : $env:COMPUTERNAME"
        "User               : $env:USERNAME"
        ""

    )
}