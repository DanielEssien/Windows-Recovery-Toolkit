###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : NetworkReset.Tests.ps1
# Purpose    : Tests Network Stack Reset safety controls.
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

    . "$ProjectRoot\Modules\WindowsRepair\NetworkReset.ps1"

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

Describe "WRTE Network Stack Reset" {

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
                            NetworkStackReset = $false
                        }
                    }
                }
            }

            Mock Read-Host {
                return "Y"
            }
        }

        It "simulates Network Stack Reset" {

            Start-NetworkStackReset

            Should -Invoke `
                Write-Success `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Network Stack Reset simulation completed."
                }
        }

        It "does not require administrator privileges" {

            Start-NetworkStackReset

            Should -Invoke `
                Test-IsAdministrator `
                -Times 0
        }
    }

    Context "Global DryRun disabled but Network Stack Reset disabled" {

        BeforeEach {

            Mock Get-Configuration {

                return [pscustomobject]@{
                    WindowsRepair = [pscustomobject]@{
                        DryRun = $false

                        LiveFeatures = [pscustomobject]@{
                            NetworkStackReset = $false
                        }
                    }
                }
            }

            Mock Read-Host {
                return "Y"
            }
        }

        It "keeps Network Stack Reset in simulation mode" {

            Start-NetworkStackReset

            Should -Invoke `
                Write-Success `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Network Stack Reset simulation completed."
                }
        }

        It "reports that live execution is not enabled" {

            Start-NetworkStackReset

            Should -Invoke `
                Write-Info `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Live execution for Network Stack Reset is not enabled."
                }
        }

        It "does not perform the administrator check" {

            Start-NetworkStackReset

            Should -Invoke `
                Test-IsAdministrator `
                -Times 0
        }
    }

    Context "Global DryRun disabled and Network Stack Reset enabled" {

        BeforeEach {

            Mock Get-Configuration {

                return [pscustomobject]@{
                    WindowsRepair = [pscustomobject]@{
                        DryRun = $false

                        LiveFeatures = [pscustomobject]@{
                            NetworkStackReset = $true
                        }
                    }
                }
            }

            Mock Read-Host {
                return "N"
            }
        }

        It "enters the controlled live reset path" {

            Start-NetworkStackReset

            Should -Invoke `
                Test-IsAdministrator `
                -Times 1
        }

        It "allows the user to cancel before network reset commands execute" {

            Start-NetworkStackReset

            Should -Invoke `
                Write-Log `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Network Stack Reset cancelled by user."
                }
        }

        It "shows the stronger live network warning" {

            Start-NetworkStackReset

            Should -Invoke `
                Write-WRTEWarning `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Active network sessions may be interrupted."
                }
        }
    }
}