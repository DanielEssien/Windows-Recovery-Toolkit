###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : ExportReport.Tests.ps1
# Purpose    : Tests WRTE report companion export behavior.
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

    $ExportReportFile =
        Join-Path `
            $ProjectRoot `
            "Modules\Reports\ExportReport.ps1"

    #----------------------------------------------------------
    # Test-safe WRTE command stubs
    #----------------------------------------------------------

    function Show-Banner {}
    function Show-Section {}
    function Write-Info {}
    function Write-WRTEWarning {}
    function Write-WRTEError {}
    function Write-Success {}
    function Write-Property {}
    function Write-Log {

        param(
            [string]$Message,
            [string]$Level
        )
    }
    function Show-Footer {}
    function Wait-WRTE {}
    function Get-WRTEReportPath {}

    . $ExportReportFile
}

Describe "WRTE Export Latest Report" {

    BeforeEach {

        $script:TestReportDirectory =
            Join-Path `
                $TestDrive `
                "Reports"

        New-Item `
            -Path $script:TestReportDirectory `
            -ItemType Directory `
            -Force |
            Out-Null

        $script:TextReportPath =
            Join-Path `
                $script:TestReportDirectory `
                "WRTE-DiagnosticReport-TEST-20260827-120000.txt"

        $script:JsonReportPath =
            [System.IO.Path]::ChangeExtension(
                $script:TextReportPath,
                ".json"
            )

        $script:HtmlReportPath =
            [System.IO.Path]::ChangeExtension(
                $script:TextReportPath,
                ".html"
            )

        Set-Content `
            -Path $script:TextReportPath `
            -Value "WRTE test text report"

        Set-Content `
            -Path $script:JsonReportPath `
            -Value '{"Report":"Test"}'

        Set-Content `
            -Path $script:HtmlReportPath `
            -Value "<html><body>WRTE test report</body></html>"

        Mock Show-Banner {}
        Mock Show-Section {}
        Mock Write-Info {}
        Mock Write-WRTEWarning {}
        Mock Write-WRTEError {}
        Mock Write-Success {}
        Mock Write-Property {}
        Mock Write-Log {}
        Mock Show-Footer {}
        Mock Wait-WRTE {}

        Mock Get-WRTEReportPath {
            $script:TestReportDirectory
        }

        Mock Copy-Item {}
    }

    Context "Report companion detection" {

        It "exports the latest text report" {

            Export-LatestWRTEReport

            Should -Invoke Copy-Item `
                -Times 1 `
                -ParameterFilter {
                    $Path -eq $script:TextReportPath
                }
        }

        It "exports the matching JSON companion report" {

            Export-LatestWRTEReport

            Should -Invoke Copy-Item `
                -Times 1 `
                -ParameterFilter {
                    $Path -eq $script:JsonReportPath
                }
        }

        It "exports the matching HTML companion report" {

            Export-LatestWRTEReport

            Should -Invoke Copy-Item `
                -Times 1 `
                -ParameterFilter {
                    $Path -eq $script:HtmlReportPath
                }
        }

        It "exports text JSON and HTML as one report set" {

            Export-LatestWRTEReport

            Should -Invoke Copy-Item `
                -Times 3
        }
    }

    Context "Missing companion reports" {

        It "still exports the text report when JSON and HTML companions are absent" {

            Remove-Item `
                -Path $script:JsonReportPath `
                -Force

            Remove-Item `
                -Path $script:HtmlReportPath `
                -Force

            Export-LatestWRTEReport

            Should -Invoke Copy-Item `
                -Times 1 `
                -ParameterFilter {
                    $Path -eq $script:TextReportPath
                }

            Should -Invoke Copy-Item `
                -Times 1
        }
    }

    Context "Export logging" {

        It "records the HTML destination in the export log" {

            Export-LatestWRTEReport

            Should -Invoke Write-Log `
                -Times 1 `
                -ParameterFilter {
                    $Message -like "*HTML:*"
                }
        }
    }
}