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

If matching JSON or HTML companion reports exist, they are
exported alongside the text report.

If files with the same names already exist on the Desktop,
a shared timestamp is appended to prevent existing files from
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

            $CompanionHtmlFile =
                [System.IO.Path]::ChangeExtension(
                    $LatestReport.FullName,
                    ".html"
                )

            $HtmlReport =
                if (Test-Path -Path $CompanionHtmlFile) {
                    Get-Item `
                        -Path $CompanionHtmlFile `
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
            
            $DestinationHtmlFile =
                if ($HtmlReport) {

                    Join-Path `
                        -Path $DesktopPath `
                        -ChildPath $HtmlReport.Name

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

            $HtmlDestinationExists =
                if ($DestinationHtmlFile) {
                    Test-Path `
                        -Path $DestinationHtmlFile
                }
                else {
                    $false
                }

            if (
                $TextDestinationExists -or
                $JsonDestinationExists -or
                $HtmlDestinationExists
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
            
                if ($HtmlReport) {

                    $DestinationHtmlFile =
                        Join-Path `
                            -Path $DesktopPath `
                            -ChildPath (
                                "$BaseName-Exported-$Timestamp.html"
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

            if ($HtmlReport) {

                Copy-Item `
                    -Path $HtmlReport.FullName `
                    -Destination $DestinationHtmlFile `
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

            if ($HtmlReport) {

                Write-Property `
                    "HTML Source" `
                    $HtmlReport.FullName

                Write-Property `
                    "HTML Destination" `
                    $DestinationHtmlFile
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
                ("Latest WRTE report exported. Text: {0}. JSON: {1}. HTML: {2}. Duration: {3:N2} seconds." `
                -f $DestinationTextFile,
                    $DestinationJsonFile,
                    $DestinationHtmlFile,
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