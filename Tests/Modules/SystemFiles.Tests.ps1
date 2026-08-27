###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : SystemFiles.Tests.ps1
# Purpose    : Tests Windows System File Repair safety controls.
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

    . "$ProjectRoot\Modules\WindowsRepair\SystemFiles.ps1"

    # Provide lightweight test functions for WRTE dependencies.
    function Show-Banner {}
    function Show-Section {}
    function Show-Footer {}
    function Wait-WRTE {}
    function Write-Info {}
    function Write-WRTEWarning {}
    function Write-WRTEError {}
    function Write-Success {}
    function Write-BlankLine {}
    function Write-Property {}
    function Write-Log {}
    function Test-IsAdministrator { return $false }
    function Get-Configuration {}
}

Describe "WRTE System File Repair" {

    BeforeEach {

        Mock Show-Banner {}
        Mock Show-Section {}
        Mock Show-Footer {}
        Mock Wait-WRTE {}

        Mock Write-Info {}
        Mock Write-WRTEWarning {}
        Mock Write-WRTEError {}
        Mock Write-Success {}
        Mock Write-BlankLine {}
        Mock Write-Property {}
        Mock Write-Log {}

        Mock Test-IsAdministrator {
            return $true
        }
    }

    Context "Global DryRun enabled" {

        BeforeEach {

            Mock Get-Configuration {

                return [pscustomobject]@{
                    WindowsRepair = [pscustomobject]@{
                        DryRun = $true

                        LiveFeatures = [pscustomobject]@{
                            SystemFileRepair = $false
                        }
                    }
                }
            }

            Mock Read-Host {
                return "Y"
            }
        }

        It "simulates System File Repair" {

            Start-SystemFileRepair

            Should -Invoke `
                Write-Success `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "System File Repair simulation completed."
                }
        }

        It "does not require administrator privileges" {

            Start-SystemFileRepair

            Should -Invoke `
                Test-IsAdministrator `
                -Times 0
        }
    }

    Context "Global DryRun disabled but System File Repair disabled" {

        BeforeEach {

            Mock Get-Configuration {

                return [pscustomobject]@{
                    WindowsRepair = [pscustomobject]@{
                        DryRun = $false

                        LiveFeatures = [pscustomobject]@{
                            SystemFileRepair = $false
                        }
                    }
                }
            }

            Mock Read-Host {
                return "Y"
            }
        }

        It "keeps System File Repair in simulation mode" {

            Start-SystemFileRepair

            Should -Invoke `
                Write-Success `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "System File Repair simulation completed."
                }
        }

        It "reports that live execution is not enabled" {

            Start-SystemFileRepair

            Should -Invoke `
                Write-Info `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Live execution for System File Repair is not enabled."
                }
        }

        It "does not perform the administrator check" {

            Start-SystemFileRepair

            Should -Invoke `
                Test-IsAdministrator `
                -Times 0
        }
    }

    Context "Global DryRun disabled and System File Repair enabled" {

        BeforeEach {

            Mock Get-Configuration {

                return [pscustomobject]@{
                    WindowsRepair = [pscustomobject]@{
                        DryRun = $false

                        LiveFeatures = [pscustomobject]@{
                            SystemFileRepair = $true
                        }
                    }
                }
            }

            Mock Read-Host {
                return "N"
            }
        }

        It "enters the controlled live repair path" {

            Start-SystemFileRepair

            Should -Invoke `
                Test-IsAdministrator `
                -Times 1
        }

        It "allows the user to cancel before SFC execution" {

            Start-SystemFileRepair

            Should -Invoke `
                Write-Log `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "System File Repair cancelled by user."
                }
        }
    }
}