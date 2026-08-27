###############################################################
#
# Windows Recovery Toolkit Enterprise (WRTE)
#
# Layer      : Module
# File       : ExportReport.ps1
# Purpose    : Exports the latest generated WRTE report.
#
# Author     : Daniel Ita Essien
# Copyright  : (c) 2026 Daniel Ita Essien
# License    : MIT
#
###############################################################

<#
.SYNOPSIS
Exports the latest WRTE report.

.DESCRIPTION
Locates the most recently generated WRTE text report in the
Reports directory and copies it to the current user's Desktop.

If a file with the same name already exists on the Desktop,
a timestamp is appended to prevent the existing file from
being overwritten.

.EXAMPLE
Export-LatestWRTEReport

.OUTPUTS
None

.NOTES
This function does not modify the original report.
#>

function Export-LatestWRTEReport {

    [CmdletBinding()]
    param()

    Show-Banner
    Show-Section "Export Latest Report"

    Write-Info "Locating the latest WRTE report..."

    $StartTime = Get-Date

    try {

        #------------------------------------------------------
        # Report Directory
        #------------------------------------------------------

        $ReportDirectory =
            Get-WRTEReportPath

        $Reports = @(
            Get-ChildItem `
                -Path $ReportDirectory `
                -Filter "WRTE-*.txt" `
                -File `
                -ErrorAction Stop |
            Sort-Object `
                -Property LastWriteTime `
                -Descending
        )

        #------------------------------------------------------
        # Report Detection
        #------------------------------------------------------

        if ($Reports.Count -eq 0) {

            Write-WRTEWarning `
                "No WRTE reports are available to export."

            Write-Log `
                "Export Latest Report completed. No reports were available." `
                -Level WARNING

        }
        else {

            $LatestReport =
                $Reports[0]

            $CompanionJsonFile =
                [System.IO.Path]::ChangeExtension(
                    $LatestReport.FullName,
                    ".json"
                )

            $JsonReport =
                if (Test-Path -Path $CompanionJsonFile) {
                    Get-Item `
                        -Path $CompanionJsonFile `
                        -ErrorAction Stop
                }
                else {
                    $null
                }

            #--------------------------------------------------
            # Export Destination
            #--------------------------------------------------

            $DesktopPath =
                [Environment]::GetFolderPath(
                    "Desktop"
                )

            if ([string]::IsNullOrWhiteSpace($DesktopPath)) {

                throw "Unable to determine the current user's Desktop path."

            }

            $BaseName =
                [System.IO.Path]::GetFileNameWithoutExtension(
                    $LatestReport.Name
                )

            $DestinationTextFile =
                Join-Path `
                    -Path $DesktopPath `
                    -ChildPath $LatestReport.Name

            $DestinationJsonFile =
                if ($JsonReport) {

                    Join-Path `
                        -Path $DesktopPath `
                        -ChildPath $JsonReport.Name

                }
                else {
                    $null
                }

            #--------------------------------------------------
            # Prevent Overwrite
            #--------------------------------------------------

            $TextDestinationExists =
                Test-Path `
                    -Path $DestinationTextFile

            $JsonDestinationExists =
                if ($DestinationJsonFile) {
                    Test-Path `
                        -Path $DestinationJsonFile
                }
                else {
                    $false
                }

            if (
                $TextDestinationExists -or
                $JsonDestinationExists
            ) {

                $Timestamp =
                    Get-Date `
                        -Format "yyyyMMdd-HHmmss"

                $DestinationTextFile =
                    Join-Path `
                        -Path $DesktopPath `
                        -ChildPath (
                            "$BaseName-Exported-$Timestamp.txt"
                        )

                if ($JsonReport) {

                    $DestinationJsonFile =
                        Join-Path `
                            -Path $DesktopPath `
                            -ChildPath (
                                "$BaseName-Exported-$Timestamp.json"
                            )
                }
            }

            #--------------------------------------------------
            # Export
            #--------------------------------------------------

            Copy-Item `
                -Path $LatestReport.FullName `
                -Destination $DestinationTextFile `
                -ErrorAction Stop

            if ($JsonReport) {

                Copy-Item `
                    -Path $JsonReport.FullName `
                    -Destination $DestinationJsonFile `
                    -ErrorAction Stop
            }

            Show-Section "Report Exported"

            Write-Success `
                "Latest WRTE report exported successfully."

            Write-Property `
                "Text Source" `
                $LatestReport.FullName

            Write-Property `
                "Text Destination" `
                $DestinationTextFile

            if ($JsonReport) {

                Write-Property `
                    "JSON Source" `
                    $JsonReport.FullName

                Write-Property `
                    "JSON Destination" `
                    $DestinationJsonFile
            }

            $ReportSizeKB =
                [math]::Round(
                    $LatestReport.Length / 1KB,
                    2
                )

            Write-Property `
                "Report Size" `
                ("{0} KB" -f $ReportSizeKB)

            Write-Property `
                "Report Created" `
                $LatestReport.LastWriteTime.ToString(
                    "yyyy-MM-dd HH:mm:ss"
                )

            $Duration =
                (Get-Date) - $StartTime

            Write-Property `
                "Execution Time" `
                ("{0:N2} sec" -f $Duration.TotalSeconds)

            Write-Log `
                ("Latest WRTE report exported. Text: {0}. JSON: {1}. Duration: {2:N2} seconds." `
                -f $DestinationTextFile,
                    $DestinationJsonFile,
                    $Duration.TotalSeconds) `
                -Level INFO

        }

    }
    catch {

        $ErrorMessage =
            $_.Exception.Message

        Write-WRTEError `
            "Unable to export the latest WRTE report."

        Write-Info `
            "Error: $ErrorMessage"

        Write-Log `
            "Latest report export failed. $ErrorMessage" `
            -Level ERROR

    }

    Show-Footer
    Wait-WRTE
}