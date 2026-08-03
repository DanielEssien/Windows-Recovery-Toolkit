###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Core
# File       : Bootstrap.ps1
# Purpose    : Initializes the WRTE application and starts
#              the application lifecycle.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################
function Start-Bootstrap {

    [CmdletBinding()]
    param()

    Initialize-Configuration

    Initialize-Logger

    Write-Log "Bootstrap completed."

    Start-Application

}