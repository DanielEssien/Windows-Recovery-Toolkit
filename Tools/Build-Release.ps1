###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tools
# File       : Build-Release.ps1
# Purpose    : Builds a clean distributable WRTE release package.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

[CmdletBinding()]
param (

    [Parameter()]
    [string]$Version = "0.5.0"
)

$ProjectRoot =
    Split-Path `
        -Parent `
        $PSScriptRoot

$BuildRoot =
    Join-Path `
        -Path $ProjectRoot `
        -ChildPath "Build"

$PackageName =
    "Windows-Recovery-Toolkit-Enterprise-v$Version"

$PackageDirectory =
    Join-Path `
        -Path $BuildRoot `
        -ChildPath $PackageName

$ZipFile =
    Join-Path `
        -Path $BuildRoot `
        -ChildPath "$PackageName.zip"

$RequiredDirectories = @(
    "Assets",
    "Config",
    "Core",
    "Modules",
    "Resources",
    "Tools"
)

$RequiredFiles = @(
    "Launcher.ps1",
    "Launcher.bat",
    "LICENSE",
    "README.md"
)

Write-Host ""
Write-Host "WRTE Release Builder" -ForegroundColor Cyan
Write-Host "--------------------" -ForegroundColor Cyan
Write-Host ""

Write-Host "Version : $Version"
Write-Host "Output  : $PackageDirectory"
Write-Host ""

try {

    if (Test-Path -Path $PackageDirectory) {

        Remove-Item `
            -Path $PackageDirectory `
            -Recurse `
            -Force `
            -ErrorAction Stop
    }

    if (Test-Path -Path $ZipFile) {

        Remove-Item `
            -Path $ZipFile `
            -Force `
            -ErrorAction Stop
    }

    New-Item `
        -Path $PackageDirectory `
        -ItemType Directory `
        -Force `
        -ErrorAction Stop |
        Out-Null

    foreach ($Directory in $RequiredDirectories) {

        $SourceDirectory =
            Join-Path `
                -Path $ProjectRoot `
                -ChildPath $Directory

        if (-not (Test-Path -Path $SourceDirectory)) {

            throw "Required directory not found: $SourceDirectory"
        }

        Copy-Item `
            -Path $SourceDirectory `
            -Destination $PackageDirectory `
            -Recurse `
            -Force `
            -ErrorAction Stop
    }

    foreach ($File in $RequiredFiles) {

        $SourceFile =
            Join-Path `
                -Path $ProjectRoot `
                -ChildPath $File

        if (-not (Test-Path -Path $SourceFile)) {

            throw "Required file not found: $SourceFile"
        }

        Copy-Item `
            -Path $SourceFile `
            -Destination $PackageDirectory `
            -Force `
            -ErrorAction Stop
    }

    $PackagedToolsDirectory =
        Join-Path `
            -Path $PackageDirectory `
            -ChildPath "Tools"

    $BuildScript =
        Join-Path `
            -Path $PackagedToolsDirectory `
            -ChildPath "Build-Release.ps1"

    if (Test-Path -Path $BuildScript) {

        Remove-Item `
            -Path $BuildScript `
            -Force `
            -ErrorAction Stop
    }

    Compress-Archive `
        -Path $PackageDirectory `
        -DestinationPath $ZipFile `
        -CompressionLevel Optimal `
        -ErrorAction Stop

    Write-Host ""
    Write-Host "Release package created successfully." -ForegroundColor Green
    Write-Host ""
    Write-Host "Folder : $PackageDirectory"
    Write-Host "ZIP    : $ZipFile"
    Write-Host ""
}
catch {

    Write-Host ""
    Write-Host "Release build failed." -ForegroundColor Red
    Write-Host "Reason: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""

    exit 1
}