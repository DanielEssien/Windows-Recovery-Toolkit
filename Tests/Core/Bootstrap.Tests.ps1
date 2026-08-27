###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : Bootstrap.Tests.ps1
# Purpose    : Tests WRTE bootstrap startup and failure handling.
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

    . (Join-Path $ProjectRoot "Core\ConfigurationValidation.ps1")
    . (Join-Path $ProjectRoot "Core\Configuration.ps1")
    . (Join-Path $ProjectRoot "Core\Logger.ps1")
    . (Join-Path $ProjectRoot "Core\Bootstrap.ps1")

    function Start-Application {}
}

Describe "WRTE Bootstrap" {

    Context "Bootstrap function" {

        It "Start-Bootstrap is available" {

            Get-Command `
                Start-Bootstrap `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Successful startup" {

        It "initializes configuration and logger before starting the application" {

            Mock Initialize-Configuration {}
            Mock Initialize-Logger {}
            Mock Write-Log {}
            Mock Start-Application {}

            Start-Bootstrap

            Should -Invoke Initialize-Configuration -Times 1
            Should -Invoke Initialize-Logger -Times 1
            Should -Invoke Write-Log -Times 1
            Should -Invoke Start-Application -Times 1
        }
    }

    Context "Configuration failure" {

        It "does not start the application when configuration initialization fails" {

            Mock Initialize-Configuration {
                throw "Test configuration failure."
            }

            Mock Initialize-Logger {}
            Mock Write-Log {}
            Mock Start-Application {}

            {
                Start-Bootstrap
            } |
                Should -Not -Throw

            Should -Invoke Initialize-Configuration -Times 1
            Should -Invoke Initialize-Logger -Times 0
            Should -Invoke Start-Application -Times 0
        }
    }

    Context "Logger failure" {

        It "does not start the application when logger initialization fails" {

            Mock Initialize-Configuration {}

            Mock Initialize-Logger {
                throw "Test logger failure."
            }

            Mock Write-Log {}
            Mock Start-Application {}

            {
                Start-Bootstrap
            } |
                Should -Not -Throw

            Should -Invoke Initialize-Configuration -Times 1
            Should -Invoke Initialize-Logger -Times 1
            Should -Invoke Start-Application -Times 0
        }
    }

    Context "Application failure" {

        It "handles an unexpected application startup failure" {

            Mock Initialize-Configuration {}
            Mock Initialize-Logger {}
            Mock Write-Log {}

            Mock Start-Application {
                throw "Test application failure."
            }

            {
                Start-Bootstrap
            } |
                Should -Not -Throw

            Should -Invoke Start-Application -Times 1
        }
    }
}