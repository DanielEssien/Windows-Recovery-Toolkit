###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : ModuleSmoke.Tests.ps1
# Purpose    : Performs smoke tests across WRTE module scripts.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

BeforeAll {

    $ProjectRoot =
        Split-Path `
            -Parent `
            (Split-Path -Parent $PSScriptRoot)

    $ModulesRoot =
        Join-Path `
            $ProjectRoot `
            "Modules"
}

Describe "WRTE Module Smoke Tests" {

    Context "Module structure" {

        It "Modules directory exists" {

            $ModulesRoot |
                Should -Exist
        }

        $RequiredModules = @(
            @{ ModuleName = "Dashboard" }
            @{ ModuleName = "Diagnostics" }
            @{ ModuleName = "Hardware" }
            @{ ModuleName = "Networking" }
            @{ ModuleName = "Maintenance" }
            @{ ModuleName = "WindowsRepair" }
            @{ ModuleName = "Security" }
            @{ ModuleName = "OneDrive" }
            @{ ModuleName = "Microsoft365" }
            @{ ModuleName = "Reports" }
            @{ ModuleName = "Utilities" }
        )

        It "contains the <ModuleName> module" -ForEach $RequiredModules {

            $ModulePath =
                Join-Path `
                    $ModulesRoot `
                    $ModuleName

            $ModulePath |
                Should -Exist
        }
    }

    Context "PowerShell script integrity" {

        BeforeDiscovery {

            $DiscoveryProjectRoot =
                Split-Path `
                    -Parent `
                    (Split-Path -Parent $PSScriptRoot)

            $DiscoveryModulesRoot =
                Join-Path `
                    $DiscoveryProjectRoot `
                    "Modules"

            $ModuleTestCases =
                @(
                    Get-ChildItem `
                        -Path $DiscoveryModulesRoot `
                        -Filter "*.ps1" `
                        -Recurse `
                        -File |
                        ForEach-Object {
                            @{
                                Name     = $_.Name
                                FullName = $_.FullName
                            }
                        }
                )
        }

        It "discovers module scripts" {

            $Scripts =
                @(
                    Get-ChildItem `
                        -Path $ModulesRoot `
                        -Filter "*.ps1" `
                        -Recurse `
                        -File
                )

            $Scripts.Count |
                Should -BeGreaterThan 0
        }

        It "<Name> contains no parser errors" -ForEach $ModuleTestCases {

            $Tokens = $null
            $Errors = $null

            [System.Management.Automation.Language.Parser]::ParseFile(
                $FullName,
                [ref]$Tokens,
                [ref]$Errors
            ) | Out-Null

            $Errors.Count |
                Should -Be 0
        }
    }
}