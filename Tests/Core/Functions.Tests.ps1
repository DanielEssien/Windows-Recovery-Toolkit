###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Tests
# File       : Functions.Tests.ps1
# Purpose    : Validates critical WRTE functions after loading.
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

    . $LoaderFile
}

Describe "WRTE Function Integrity" {

    Context "Diagnostics functions" {

        $Functions = @(
            @{ FunctionName = "Start-QuickHealth" }
            @{ FunctionName = "Start-SFC" }
            @{ FunctionName = "Start-DISMScan" }
            @{ FunctionName = "Start-DISMRestore" }
            @{ FunctionName = "Start-DiskCheck" }
            @{ FunctionName = "Start-MemoryTest" }
            @{ FunctionName = "Show-RecoveryInformation" }
            @{ FunctionName = "Show-EventLogDiagnostics" }
            @{ FunctionName = "Show-CrashDumpDiagnostics" }
            @{ FunctionName = "Show-StartupDiagnostics" }
        )

        It "loads <FunctionName>" -ForEach $Functions {

            Get-Command `
                -Name $FunctionName `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Hardware functions" {

        $Functions = @(
            @{ FunctionName = "Show-HardwareOverview" }
            @{ FunctionName = "Show-StorageDevices" }
            @{ FunctionName = "Show-BatteryInformation" }
            @{ FunctionName = "Show-BIOSInformation" }
            @{ FunctionName = "Show-DriverHealth" }
        )

        It "loads <FunctionName>" -ForEach $Functions {

            Get-Command `
                -Name $FunctionName `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Security functions" {

        $Functions = @(
            @{ FunctionName = "Show-SecurityOverview" }
            @{ FunctionName = "Show-DefenderStatus" }
            @{ FunctionName = "Show-FirewallStatus" }
            @{ FunctionName = "Show-BitLockerStatus" }
            @{ FunctionName = "Show-SecureBootStatus" }
            @{ FunctionName = "Show-DiskEncryptionStatus" }
            @{ FunctionName = "Show-TPMStatus" }
        )

        It "loads <FunctionName>" -ForEach $Functions {

            Get-Command `
                -Name $FunctionName `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Report functions" {

        $Functions = @(
            @{ FunctionName = "New-WRTESystemReport" }
            @{ FunctionName = "New-WRTEDiagnosticReport" }
            @{ FunctionName = "Export-LatestWRTEReport" }
        )

        It "loads <FunctionName>" -ForEach $Functions {

            Get-Command `
                -Name $FunctionName `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Context "Utility functions" {

        $Functions = @(
            @{ FunctionName = "Show-EnvironmentInformation" }
            @{ FunctionName = "Find-WRTEProcess" }
            @{ FunctionName = "Find-WRTEService" }
            @{ FunctionName = "Open-WRTEDeviceManager" }
            @{ FunctionName = "Open-WRTEEventViewer" }
            @{ FunctionName = "Open-WRTEAdministrativeTools" }
        )

        It "loads <FunctionName>" -ForEach $Functions {

            Get-Command `
                -Name $FunctionName `
                -CommandType Function `
                -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }
}