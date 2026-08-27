###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : Loader.Tests.ps1
# Purpose    : Tests WRTE loader integrity and core/module loading.
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

    $LoaderFile =
        Join-Path `
            $ProjectRoot `
            "Core\Loader.ps1"
}

Describe "WRTE Loader" {

    Context "Loader file" {

        It "Loader.ps1 exists" {

            $LoaderFile |
                Should -Exist
        }

        It "contains no PowerShell parser errors" {

            $Tokens = $null
            $Errors = $null

            [System.Management.Automation.Language.Parser]::ParseFile(
                $LoaderFile,
                [ref]$Tokens,
                [ref]$Errors
            ) | Out-Null

            $Errors.Count |
                Should -Be 0
        }
    }

    Context "Loader execution" {

        It "loads without throwing" {

            {
                . $LoaderFile
            } |
                Should -Not -Throw
        }
    }

    Context "Core functions" {

        BeforeAll {
            . $LoaderFile
        }

        $CoreFunctions = @(
            @{ FunctionName = "Initialize-Configuration" }
            @{ FunctionName = "Get-Configuration" }
            @{ FunctionName = "Initialize-Logger" }
            @{ FunctionName = "Write-Log" }
            @{ FunctionName = "Start-Application" }
            @{ FunctionName = "Start-Bootstrap" }
        )

        It "loads <FunctionName>" -ForEach $CoreFunctions {

            Get-Command `
                -Name $FunctionName `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Primary module entry points" {

        BeforeAll {
            . $LoaderFile
        }

        $ModuleFunctions = @(
            @{ FunctionName = "Show-Dashboard" }
            @{ FunctionName = "Show-Diagnostics" }
            @{ FunctionName = "Show-Hardware" }
            @{ FunctionName = "Show-Network" }
            @{ FunctionName = "Show-Maintenance" }
            @{ FunctionName = "Show-WindowsRepair" }
            @{ FunctionName = "Show-Security" }
            @{ FunctionName = "Show-Microsoft365" }
            @{ FunctionName = "Show-OneDrive" }
            @{ FunctionName = "Show-Reports" }
            @{ FunctionName = "Show-Utilities" }
        )

        It "loads <FunctionName>" -ForEach $ModuleFunctions {

            Get-Command `
                -Name $FunctionName `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Loader failure handling" {

        It "throws a clear error when a required script is missing" {

            $TemporaryRoot =
                Join-Path `
                    $TestDrive `
                    "WRTE"

            $CoreRoot =
                Join-Path `
                    $TemporaryRoot `
                    "Core"

            New-Item `
                -Path $CoreRoot `
                -ItemType Directory `
                -Force |
                Out-Null

            $LoaderContent =
                Get-Content `
                    -Path $LoaderFile `
                    -Raw

            $LoaderContent =
                $LoaderContent.Replace(
                    '$PSScriptRoot\ConfigurationValidation.ps1',
                    '$PSScriptRoot\MissingConfigurationValidation.ps1'
                )

            $TemporaryLoader =
                Join-Path `
                    $CoreRoot `
                    "Loader.ps1"

            Set-Content `
                -Path $TemporaryLoader `
                -Value $LoaderContent

            {
                . $TemporaryLoader
            } |
                Should -Throw `
                    "*WRTE loader failed*"
        }
    }
}