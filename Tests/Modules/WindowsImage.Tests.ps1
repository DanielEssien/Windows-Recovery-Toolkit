###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : WindowsImage.Tests.ps1
# Purpose    : Tests Windows Image Repair safety controls.
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

    . "$ProjectRoot\Modules\WindowsRepair\WindowsImage.ps1"

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

Describe "WRTE Windows Image Repair" {

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
                            WindowsImageRepair = $false
                        }
                    }
                }
            }

            Mock Read-Host {
                return "Y"
            }
        }

        It "simulates Windows Image Repair" {

            Start-WindowsImageRepair

            Should -Invoke `
                Write-Success `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Windows Image Repair simulation completed."
                }
        }

        It "does not require administrator privileges" {

            Start-WindowsImageRepair

            Should -Invoke `
                Test-IsAdministrator `
                -Times 0
        }
    }

    Context "Global DryRun disabled but Windows Image Repair disabled" {

        BeforeEach {

            Mock Get-Configuration {

                return [pscustomobject]@{
                    WindowsRepair = [pscustomobject]@{
                        DryRun = $false

                        LiveFeatures = [pscustomobject]@{
                            WindowsImageRepair = $false
                        }
                    }
                }
            }

            Mock Read-Host {
                return "Y"
            }
        }

        It "keeps Windows Image Repair in simulation mode" {

            Start-WindowsImageRepair

            Should -Invoke `
                Write-Success `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Windows Image Repair simulation completed."
                }
        }

        It "reports that live execution is not enabled" {

            Start-WindowsImageRepair

            Should -Invoke `
                Write-Info `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Live execution for Windows Image Repair is not enabled."
                }
        }

        It "does not perform the administrator check" {

            Start-WindowsImageRepair

            Should -Invoke `
                Test-IsAdministrator `
                -Times 0
        }
    }

    Context "Global DryRun disabled and Windows Image Repair enabled" {

        BeforeEach {

            Mock Get-Configuration {

                return [pscustomobject]@{
                    WindowsRepair = [pscustomobject]@{
                        DryRun = $false

                        LiveFeatures = [pscustomobject]@{
                            WindowsImageRepair = $true
                        }
                    }
                }
            }

            Mock Read-Host {
                return "N"
            }
        }

        It "enters the controlled live repair path" {

            Start-WindowsImageRepair

            Should -Invoke `
                Test-IsAdministrator `
                -Times 1
        }

        It "allows the user to cancel before DISM execution" {

            Start-WindowsImageRepair

            Should -Invoke `
                Write-Log `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Windows Image Repair cancelled by user."
                }
        }
    }
}