using module .\Base.psm1
<#
.SYNOPSIS
    Retrieves reports for all stages of an application
#>
filter Find-NexusIQReport
{
    [CmdletBinding()]
    param (
        # The unique ID of the application
        [Parameter(Mandatory)]
        [Alias("ApplicationId")]
        [string]$PublicId
    )
    Write-Verbose "Finding application's internal Id with public ID $PublicId"
    $InternalId = Get-NexusIQApplication @PSBoundParameters | Select-Object -ExpandProperty id
    Invoke-NexusIQAPI -Path "reports/applications/$InternalId"
}

<#
.SYNOPSIS
    Retrieves reports for the specified stage of an application
.EXAMPLE
    Get-NexusIQReport -ApplicationId MyApp1 -Stage stage-release
.EXAMPLE
    Get-NexusIQApplication -ApplicationId MyApp1 | Get-NexusIQReport -Stage stage-release
.LINK
    https://help.sonatype.com/iqserver/automating/rest-apis/application-rest-api---v2#ApplicationRESTAPIv2-Step1-GettheOrganizationID
#>
filter Get-NexusIQReport
{
    [CmdletBinding()]
    param (
        # The unique ID of the application
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias("ApplicationId")]
        [string]$PublicId,

        # Stage the report was run on
        [Parameter(Mandatory)]
        [ValidateSet("stage-release","source","build","release")]
        [string]$Stage
    )
    Find-NexusIQReport -PublicId $PublicId | Where-Object -Property stage -EQ $Stage
}

<#
.SYNOPSIS
    Downloads a security scan report based on the type specified. It will end up in your default download location.
.EXAMPLE
    $NexusApp = Get-NexusIQApplication -ApplicationId MyAppId -ErrorAction Stop
    $FileName = "$($NexusApp.publicId.Substring(0,5))_$($NexusApp.name).pdf"
    $IQReportPath = "$env:OneDrive\Documents\$FileName" # Set it to the app's display name
    Export-NexusIQReport -ApplicationId MyAppId1 -Stage stage-release -ReportType PDF -OutFile $IQReportPath
.EXAMPLE
    Get-NexusIQApplication -ApplicationId MyAppId | Export-NexusIQReport -Stage stage-release -ReportType PDF -OutFile "$env:TEMP\Report.pdf"
#>
filter Export-NexusIQReport
{
    [CmdletBinding()]
    param (
        # The unique ID of the application
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias("ApplicationId")]
        [string]$PublicId,

        # Stage the report was run on
        [Parameter(Mandatory)]
        [ValidateSet("stage-release","source","build","release")]
        [string]$Stage,

        # Format to output the data in
        [Parameter(Mandatory)]
        [ValidateSet("RAW","PDF")]
        [string]$ReportType,

        # Directory to output the reports to
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path (Split-Path $_) })]
        [string]$OutFile
    )
    $ReportsInfo = Get-NexusIQReport -PublicId $PublicId -Stage $Stage
    if ($ReportsInfo)
    {
        switch ($ReportType)
        {
            "PDF" {
                $BasePath = $ReportsInfo.reportDataUrl -replace "api\/v2\/applications\/","report/" -replace "\/raw","" -replace "\/reports\/","/"
                Invoke-NexusIQAPI -Path "$BasePath/printReport" -RequestType rest -OutFile $OutFile
            }
            "RAW" {
                $Path = $ReportsInfo.reportDataUrl -replace "api\/v2\/",""
                Invoke-NexusIQAPI -Path $Path -RequestType api -OutFile $OutFile
            }
        }
        Get-ItemProperty -Path $OutFile
    }
    else { Write-Warning "No report was found for App Id '$PublicId' in stage '$Stage'. Have you generated a report?" }
}
