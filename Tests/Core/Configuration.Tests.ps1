###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : Configuration.Tests.ps1
# Purpose    : Tests WRTE configuration loading and access.
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

    $ConfigurationFile =
        Join-Path `
            $ProjectRoot `
            "Core\Configuration.ps1"

    $SettingsFile =
        Join-Path `
            $ProjectRoot `
            "Config\Settings.json"

    . $ConfigurationFile
}

Describe "WRTE Configuration" {

    Context "Required files" {

        It "Configuration.ps1 exists" {

            $ConfigurationFile |
                Should -Exist
        }

        It "Settings.json exists" {

            $SettingsFile |
                Should -Exist
        }
    }

    Context "Configuration functions" {

        It "Initialize-Configuration is available" {

            Get-Command `
                Initialize-Configuration `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Get-Configuration is available" {

            Get-Command `
                Get-Configuration `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Settings file" {

        It "contains valid JSON" {

            {
                Get-Content `
                    -Path $SettingsFile `
                    -Raw `
                    -ErrorAction Stop |
                    ConvertFrom-Json `
                        -ErrorAction Stop
            } |
                Should -Not -Throw
        }

        It "contains an Application configuration section" {

            $Settings =
                Get-Content `
                    -Path $SettingsFile `
                    -Raw |
                ConvertFrom-Json

            $Settings.Application |
                Should -Not -BeNullOrEmpty
        }

        It "contains an application name" {

            $Settings =
                Get-Content `
                    -Path $SettingsFile `
                    -Raw |
                ConvertFrom-Json

            $Settings.Application.Name |
                Should -Not -BeNullOrEmpty
        }

        It "contains an application version" {

            $Settings =
                Get-Content `
                    -Path $SettingsFile `
                    -Raw |
                ConvertFrom-Json

            $Settings.Application.Version |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Configuration initialization" {

        It "initializes the WRTE configuration" {

            {
                Initialize-Configuration
            } |
                Should -Not -Throw
        }

        It "returns configuration after initialization" {

            Initialize-Configuration

            $Configuration =
                Get-Configuration

            $Configuration |
                Should -Not -BeNullOrEmpty
        }

        It "returns the configured WRTE application name" {

            Initialize-Configuration

            $Configuration =
                Get-Configuration

            $Configuration.Application.Name |
                Should -Be `
                    "Windows Recovery Toolkit Enterprise"
        }
    }
}