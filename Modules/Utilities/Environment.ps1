###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : Environment.ps1
# Purpose    : Displays Windows environment information.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Displays Windows environment information.

.DESCRIPTION
Retrieves commonly useful local environment details including
computer name, current user, domain or workgroup, operating
system architecture, PowerShell version, execution policy,
temporary paths, and administrator status.

.EXAMPLE
Show-EnvironmentInformation

.OUTPUTS
None

.NOTES
This function is read-only.
#>

function Show-EnvironmentInformation {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Environment Information"

    Write-Info "Collecting environment information..."

    $StartTime = Get-Date

    try {

        #------------------------------------------------------
        # Computer and User
        #------------------------------------------------------

        $ComputerSystem =
            Get-CimInstance `
                -ClassName Win32_ComputerSystem `
                -ErrorAction Stop

        $CurrentIdentity =
            [Security.Principal.WindowsIdentity]::GetCurrent()

        $Principal =
            New-Object `
                Security.Principal.WindowsPrincipal(
                    $CurrentIdentity
                )

        $IsAdministrator =
            $Principal.IsInRole(
                [Security.Principal.WindowsBuiltInRole]::Administrator
            )

        Show-Section "Computer and User"

        Write-Property "Computer Name" $env:COMPUTERNAME
        Write-Property "Current User" $env:USERNAME

        if ($env:USERDOMAIN) {

            Write-Property "User Domain" $env:USERDOMAIN

        }

        if ($ComputerSystem.PartOfDomain) {

            Write-Property "Domain Status" "Domain Joined"
            Write-Property "Domain" $ComputerSystem.Domain

        }
        else {

            Write-Property "Domain Status" "Workgroup"
            Write-Property "Workgroup" $ComputerSystem.Workgroup

        }

        Write-Property `
            "Administrator" `
            $(if ($IsAdministrator) { "Yes" } else { "No" })

        #------------------------------------------------------
        # Platform
        #------------------------------------------------------

        Show-Section "Platform"

        Write-Property `
            "OS Architecture" `
            $env:PROCESSOR_ARCHITECTURE

        Write-Property `
            "Processor Count" `
            $env:NUMBER_OF_PROCESSORS

        Write-Property `
            "Windows Directory" `
            $env:WINDIR

        Write-Property `
            "System Drive" `
            $env:SystemDrive

        #------------------------------------------------------
        # PowerShell
        #------------------------------------------------------

        Show-Section "PowerShell"

        Write-Property `
            "PowerShell Version" `
            $PSVersionTable.PSVersion.ToString()

        Write-Property `
            "Edition" `
            $PSVersionTable.PSEdition

        Write-Property `
            "Platform" `
            $PSVersionTable.Platform

        Write-Property `
            "Execution Policy" `
            (Get-ExecutionPolicy)

        #------------------------------------------------------
        # Paths
        #------------------------------------------------------

        Show-Section "Environment Paths"

        Write-Property `
            "User Profile" `
            $env:USERPROFILE

        Write-Property `
            "Local AppData" `
            $env:LOCALAPPDATA

        Write-Property `
            "AppData" `
            $env:APPDATA

        Write-Property `
            "Temp Path" `
            $env:TEMP

        #------------------------------------------------------
        # Session
        #------------------------------------------------------

        Show-Section "Session"

        Write-Property `
            "PowerShell Process ID" `
            $PID

        Write-Property `
            "Host" `
            $Host.Name

        Write-Property `
            "Current Directory" `
            (Get-Location).Path

        #------------------------------------------------------
        # Completion
        #------------------------------------------------------

        $Duration =
            (Get-Date) - $StartTime

        Write-BlankLine

        Write-Property `
            "Execution Time" `
            ("{0:N2} sec" -f $Duration.TotalSeconds)

        Write-Log `
            ("Environment information completed in {0:N2} seconds." `
            -f $Duration.TotalSeconds) `
            -Level INFO

    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEError `
            "Unable to collect environment information."

        Write-Info `
            "Error: $ErrorMessage"

        Write-Log `
            "Environment information failed. $ErrorMessage" `
            -Level ERROR

    }

    Show-Footer
    Wait-WRTE
}