###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : WindowsUpdateRepair.Tests.ps1
# Purpose    : Tests Windows Update Repair safety controls.
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

    . "$ProjectRoot\Modules\WindowsRepair\WindowsUpdateRepair.ps1"

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

Describe "WRTE Windows Update Repair" {

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
                            WindowsUpdateRepair = $false
                        }
                    }
                }
            }

            Mock Read-Host {
                return "Y"
            }
        }

        It "simulates Windows Update Repair" {

            Start-WindowsUpdateRepair

            Should -Invoke `
                Write-Success `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Windows Update Repair simulation completed."
                }
        }

        It "does not require administrator privileges" {

            Start-WindowsUpdateRepair

            Should -Invoke `
                Test-IsAdministrator `
                -Times 0
        }
    }

    Context "Global DryRun disabled but Windows Update Repair disabled" {

        BeforeEach {

            Mock Get-Configuration {

                return [pscustomobject]@{
                    WindowsRepair = [pscustomobject]@{
                        DryRun = $false

                        LiveFeatures = [pscustomobject]@{
                            WindowsUpdateRepair = $false
                        }
                    }
                }
            }

            Mock Read-Host {
                return "Y"
            }
        }

        It "keeps Windows Update Repair in simulation mode" {

            Start-WindowsUpdateRepair

            Should -Invoke `
                Write-Success `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Windows Update Repair simulation completed."
                }
        }

        It "reports that live execution is not enabled" {

            Start-WindowsUpdateRepair

            Should -Invoke `
                Write-Info `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Live execution for Windows Update Repair is not enabled."
                }
        }

        It "does not perform the administrator check" {

            Start-WindowsUpdateRepair

            Should -Invoke `
                Test-IsAdministrator `
                -Times 0
        }
    }

        Context "Global DryRun disabled and Windows Update Repair enabled" {

        BeforeEach {

            Mock Get-Configuration {

                return [pscustomobject]@{
                    WindowsRepair = [pscustomobject]@{
                        DryRun = $false

                        LiveFeatures = [pscustomobject]@{
                            WindowsUpdateRepair = $true
                        }
                    }
                }
            }
        }

        It "enters the controlled live repair path" {

            Mock Read-Host {
                return "N"
            }

            Start-WindowsUpdateRepair

            Should -Invoke `
                Test-IsAdministrator `
                -Times 1
        }

        It "allows the user to cancel before repair actions execute" {

            Mock Read-Host {
                return "N"
            }

            Start-WindowsUpdateRepair

            Should -Invoke `
                Write-Log `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Windows Update Repair cancelled by user."
                }
        }

        It "shows the stronger live repair warning" {

            Mock Read-Host {
                return "N"
            }

            Start-WindowsUpdateRepair

            Should -Invoke `
                Write-WRTEWarning `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -eq
                    "Do not interrupt WRTE while the repair is in progress."
                }
        }
    }

    Context "Windows Update service restoration" {

        BeforeEach {

            Mock Get-Configuration {

                return [pscustomobject]@{
                    WindowsRepair = [pscustomobject]@{
                        DryRun = $false

                        LiveFeatures = [pscustomobject]@{
                            WindowsUpdateRepair = $true
                        }
                    }
                }
            }

            Mock Read-Host {
                return "Y"
            }

            Mock Test-IsAdministrator {
                return $true
            }

            Mock Get-Service {

                param (
                    $Name
                )

                $Status =
                    if ($Name -eq "BITS") {
                        "Stopped"
                    }
                    else {
                        "Running"
                    }

                return [pscustomobject]@{
                    Name   = $Name
                    Status = $Status
                }
            }

            Mock Stop-Service {}
            Mock Start-Service {}
            Mock Rename-Item {}

            Mock Test-Path {
                return $true
            }
        }

        It "restores services that were originally running" {

            Start-WindowsUpdateRepair

            Should -Invoke `
                Start-Service `
                -Times 1 `
                -ParameterFilter {
                    $Name -eq "wuauserv"
                }

            Should -Invoke `
                Start-Service `
                -Times 1 `
                -ParameterFilter {
                    $Name -eq "CryptSvc"
                }

            Should -Invoke `
                Start-Service `
                -Times 1 `
                -ParameterFilter {
                    $Name -eq "msiserver"
                }
        }

        It "does not start a service that was originally stopped" {

            Start-WindowsUpdateRepair

            Should -Invoke `
                Start-Service `
                -Times 0 `
                -ParameterFilter {
                    $Name -eq "BITS"
                }
        }

        It "attempts service restoration even when the repair fails" {

            Mock Rename-Item {
                throw "Test cache rename failure."
            }

            Start-WindowsUpdateRepair

            Should -Invoke `
                Start-Service `
                -Times 1 `
                -ParameterFilter {
                    $Name -eq "wuauserv"
                }

            Should -Invoke `
                Write-Log `
                -Times 1 `
                -ParameterFilter {
                    $args[0] -like
                    "Windows Update Repair failed.*"
                }
        }
    }
}