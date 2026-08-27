###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : Logger.Tests.ps1
# Purpose    : Tests WRTE logging initialization and output.
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

    $LoggerFile =
        Join-Path `
            $ProjectRoot `
            "Core\Logger.ps1"

    . $ConfigurationFile
    . $LoggerFile

    Initialize-Configuration
}

Describe "WRTE Logger" {

    Context "Logger functions" {

        It "Initialize-Logger is available" {

            Get-Command `
                Initialize-Logger `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Write-Log is available" {

            Get-Command `
                Write-Log `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Logger initialization" {

        It "initializes without throwing" {

            {
                Initialize-Logger
            } |
                Should -Not -Throw
        }

        It "creates a log file path" {

            Initialize-Logger

            $script:LogFile |
                Should -Not -BeNullOrEmpty
        }

        It "creates the log file" {

            Initialize-Logger

            Test-Path $script:LogFile |
                Should -BeTrue
        }
    }

    Context "Log writing" {

        It "writes an INFO message" {

            Initialize-Logger

            $Message =
                "Pester logger test message"

            Write-Log `
                -Message $Message `
                -Level INFO

            $Content =
                Get-Content `
                    -Path $script:LogFile `
                    -Raw

            $EscapedMessage =
                [regex]::Escape($Message)

            $Content |
                Should -Match $EscapedMessage
        }

        It "uses INFO as the default level" {

            Initialize-Logger

            $Message =
                "Pester default log level test"

            Write-Log `
                -Message $Message

            $Content =
                Get-Content `
                    -Path $script:LogFile `
                    -Raw

            $Content |
                Should -Match `
                    "\[INFO\].*$([regex]::Escape($Message))"
        }

        It "accepts WARNING level" {

            Initialize-Logger

            {
                Write-Log `
                    -Message "Pester warning test" `
                    -Level WARNING
            } |
                Should -Not -Throw
        }

        It "accepts ERROR level" {

            Initialize-Logger

            {
                Write-Log `
                    -Message "Pester error test" `
                    -Level ERROR
            } |
                Should -Not -Throw
        }
    }
}