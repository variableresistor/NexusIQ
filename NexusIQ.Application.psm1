using module .\Base.psm1
<#
.SYNOPSIS
    Retrieves all the applications in NexusIQ
#>
filter Find-NexusIQApplication
{
    [CmdletBinding()]
    param (
        # Name of the application to search for by wildcard.
        [SupportsWildcards()]
        [string]$Name
    )
    Write-Verbose "Listing all applications..."
    $Applications = Invoke-NexusIQAPI -Path "applications" | Select-Object -ExpandProperty applications
    if ($Name) { $Applications | Where-Object -Property name -Like $Name }
    else { $Applications }
}

<#
.SYNOPSIS
    Retrieves the Application in Nexus IQ based on its "Public ID"
.EXAMPLE
    Get-NexusIQApplication -ApplicationId App1Id
.EXAMPLE
    Get-NexusIQApplication -Name App1Name
.EXAMPLE
    Get-NexusIQApplication -Name App1*
.LINK
    https://help.sonatype.com/iqserver/automating/rest-apis/application-rest-api---v2
#>
filter Get-NexusIQApplication
{
    [CmdletBinding(DefaultParameterSetName="App Id parameter set")]
    param (
        # This is the application ID for the application. In the IQ Server GUI this is represented by the "Application" field. It must be unique., i.e. publicId
        [Parameter(Mandatory,ParameterSetName="App Id parameter set",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("ApplicationId")]
        [string[]]$PublicId,

        # This is the name of the application. In the IQ Server GUI this corresponds to the "Application Name" field. It must be unique.
        [Parameter(Mandatory,ParameterSetName="App Name parameter set")]
        [SupportsWildcards()]
        [string[]]$Name
    )
    if ($PublicId)
    {
        foreach ($AppId in $PublicId)
        {
            Invoke-NexusIQAPI -Path "applications" -Parameters @{ publicId=$AppId } | Select-Object -ExpandProperty applications -OutVariable Result
            if (-not $Result) { Write-Error "No application with ID $AppId" }
        }
    }
    elseif ($Name)
    {
        $AllApplications = Find-NexusIQApplication
        foreach ($AppName in $Name)
        {
            $AllApplications | Where-Object -Property name -Like $AppName | Select-Object -ExpandProperty publicId | ForEach-Object -Process {
                Write-Verbose "Found app with name $AppName and id $_"
                Invoke-NexusIQAPI -Path "applications" -Parameters @{ publicId=$_ } | Select-Object -ExpandProperty applications
            }
        }
    }
}

<#
.SYNOPSIS
    Retrieves the Application in Nexus IQ based on its "Public ID"
.EXAMPLE
    New-NexusIQApplication -ApplicationId AppId1 -Name "My Special App" -OrganizationName MyOrg
.LINK
    https://help.sonatype.com/iqserver/automating/rest-apis/application-rest-api---v2
#>
filter New-NexusIQApplication
{
    [CmdletBinding()]
    param (
        # This is the application ID for the application. In the IQ Server GUI this is represented by the "Application" field. It must be unique., i.e. publicId
        [Parameter(Mandatory)]
        [Alias("ApplicationId")]
        [string]$PublicId,

        # This is the name of the application. In the IQ Server GUI this corresponds to the "Application Name" field. It must be unique.
        [Parameter(Mandatory)]
        [string]$Name,

        # Name of the organization to add this application to
        [Parameter(Mandatory)]
        [string]$OrganizationName
    )
    $Organization = Get-NexusIQOrganization -Name $OrganizationName
    Invoke-NexusIQAPI -Path "applications" -Method Post -Body (
        [PSCustomObject]@{
            publicId       = $PublicId
            name           = $Name
            organizationId = $Organization.id
        } | ConvertTo-Json
    ) -ContentType "application/json"
}

<#
.SYNOPSIS
    Removes an application
.EXAMPLE
    Remove-NexusIQApplication -ApplicationId AppId1
.EXAMPLE
    Get-NexusIQApplication -ApplicationId AppId1 | Remove-NexusIQApplication
.LINK
    https://help.sonatype.com/iqserver/automating/rest-apis/application-rest-api---v2
#>
filter Remove-NexusIQApplication
{
    [CmdletBinding()]
    param (
        # This is the application ID for the application. In the IQ Server GUI this is represented by the "Application" field. It must be unique., i.e. publicId
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias("ApplicationId")]
        [string]$PublicId
    )
    # Halt if the application wasn't found
    $Application = Get-NexusIQApplication -PublicId $PublicId -ErrorAction Stop
    Invoke-NexusIQAPI -Path "applications/$($Application.id)" -Method Delete
}
