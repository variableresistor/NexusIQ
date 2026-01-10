$null = "Import Microsoft.PowerShell.Commands.WebRequestMethod"
$UserHomeFolder = if (Test-Path Env:\APPDATA) { $env:APPDATA } else { $HOME }

<#
.SYNOPSIS
    Retrieves all the applications in NexusIQ
.LINK
    https://help.sonatype.com/en/application-rest-api.html
#>
filter Find-NexusIQApplication
{
    [CmdletBinding()]
    param (
        # Name of the application to search for by wildcard.
        [SupportsWildcards()]
        [string]$Name,

        # Public Id of the application
        [SupportsWildcards()]
        [string]$PublicId,

        # Sets to filter the results by organization
        [string]$OrganizationName
    )
    if ($OrganizationName)
    {
        Write-Verbose "Filtering by applications associated with organization '$OrganizationName'"
        $Organization = Get-NexusIQOrganization -Name $OrganizationName
        Invoke-NexusIQAPI -Path "applications/organization/$($Organization.id)" | Select-Object -ExpandProperty applications
    }
    else
    {
        Write-Verbose "Listing all applications..."
        $Applications = Invoke-NexusIQAPI -Path "applications" | Select-Object -ExpandProperty applications
        if (-not ($PSBoundParameters.ContainsKey("Name")) -and -not (($PSBoundParameters.ContainsKey("PublicId"))))
        {
            $Applications
        }
        else
        {
            if ($Name)
            {
                Write-Verbose "Filtering applications with name like '$Name'"
                $Applications | Where-Object -Property name -Like $Name
            }
            if ($PublicId)
            {
                Write-Verbose "Filtering applications with publicId like '$PublicId'"
                $Applications | Where-Object -Property publicId -Like $PublicId
            }
        }
    }
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
    https://help.sonatype.com/en/application-rest-api.html
#>
filter Get-NexusIQApplication
{
    [CmdletBinding(DefaultParameterSetName="Id")]
    param (
        # Unique id of the application
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Id")]
        [string[]]$Id,

        # This is the application ID for the application. In the IQ Server GUI this is represented by the "Application" field. It must be unique., i.e. publicId
        [Parameter(Mandatory,Position=0,ValueFromPipelineByPropertyName,ParameterSetName="PublicId")]
        [Alias("ApplicationId")]
        [string[]]$PublicId,

        # This is the name of the application. In the IQ Server GUI this corresponds to the "Application Name" field.
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Name")]
        [SupportsWildcards()]
        [string[]]$Name
    )
    if ($PSBoundParameters.ContainsKey("Id"))
    {
        $Id | ForEach-Object -Process { Invoke-NexusIQAPI -Path "applications/$_" }
    }
    elseif ($PSBoundParameters.ContainsKey("PublicId"))
    {
        foreach ($AppId in $PublicId)
        {
            Write-Verbose "Searching for application with PublicId $AppId"
            Invoke-NexusIQAPI -Path "applications" -Parameters @{ publicId=$AppId } | Select-Object -ExpandProperty applications -OutVariable Result
            if (-not $Result) { Write-Error "No application with ID $AppId" }
        }
    }
    elseif ($PSBoundParameters.ContainsKey("Name"))
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
    Set an Application's properties in Nexus IQ based on its Id
.EXAMPLE
    Get-NexusIQApplication -PublicId App1Id | Set-NexusIQApplication -PublicId App2Id -Name "This is my renamed app"
.LINK
    https://help.sonatype.com/en/application-rest-api.html
#>
filter Set-NexusIQApplication
{
    [CmdletBinding(DefaultParameterSetName="Id")]
    param (
        # This is the application ID for the application. In the IQ Server GUI this is represented by the "Application" field. It must be unique., NOT the public Id
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Id")]
        [string]$Id,

        # Name of the application, i.e. what you see in the UI's application page
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Name")]
        [string]$Name,

        # This is the application ID for the application. In the IQ Server GUI this is represented by the "Application" field. It must be unique., i.e. publicId
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="PublicId")]
        [string]$PublicId,

        # The new Public Id to set the application to, aka App Id from the UI
        [string]$NewPublicId,

        # The new name
        [string]$NewName,

        # Output the result to the pipeline
        [switch]$PassThru
    )
    $IQApp = if ($PSBoundParameters.ContainsKey("Name"))
    {
        Get-NexusIQApplication -Name $Name
    }
    elseif ($PSBoundParameters.ContainsKey("PublicId"))
    {
        Get-NexusIQApplication -PublicId $PublicId
    }
    else
    {
        Get-NexusIQApplication -Id $Id
    }
    $Splat = @{
        Path        = "applications/$($IQApp.id)"
        Method      = "Put"
        ContentType = "application/json"
    }
    if ($NewPublicId)
    {
        $IQApp.publicId = $NewPublicId
        $IQApp = Invoke-NexusIQAPI @Splat -Body ($IQApp | ConvertTo-Json -Depth 99 -Compress)
    }
    if ($NewName)
    {
        $IQApp.name = $NewName
        $IQApp = Invoke-NexusIQAPI @Splat -Body ($IQApp | ConvertTo-Json -Depth 99 -Compress)
    }
    if ($PassThru)
    {
        $IQApp
    }
}

filter Move-NexusIQApplicationOrganization
{
    [CmdletBinding(DefaultParameterSetName="Id")]
    param (
        # This is internally used only, it's only used for pipeline input
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Id")]
        [string]$Id,

        # Name of the application, i.e. what you see in the UI's application page
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Name")]
        [string]$Name,

        # This is the application ID for the application. In the IQ Server GUI this is represented by the "Application" field. It must be unique., i.e. publicId
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="PublicId")]
        [string]$PublicId,

        # Name of the organization to move the application to
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [switch]$PassThru
    )
    $IQApp = if ($PSBoundParameters.ContainsKey("Id"))
    {
        Get-NexusIQApplication -Id $Id
    }
    elseif ($PSBoundParameters.ContainsKey("PublicId"))
    {
        Get-NexusIQApplication -PublicId $PublicId
    }
    elseif ($PSBoundParameters.ContainsKey("Name"))
    {
        Get-NexusIQApplication -Name $Name
    }
    Write-Verbose "Retrieving old organization information from app $($IQApp.name)"
    $OldOrganization = Get-NexusIQOrganization -Id $IQApp.organizationId
    Write-Verbose "Retrieving new organization information"
    $NewOrganization = Get-NexusIQOrganization -Name $OrganizationName
    if ($OldOrganization.name -eq $OrganizationName)
    {
        Write-Warning "The old and new organizations were the same: $OrganizationName"
    }
    else
    {
        Write-Verbose "Moving application from '$($OldOrganization.name)' to '$($NewOrganization.name)'"
        Invoke-NexusIQAPI -Path "applications/$($IQApp.id)/move/organization/$($NewOrganization.id)" -Method Post |
        Select-Object -ExpandProperty warnings -ErrorAction Ignore | ForEach-Object -Process { Write-Warning $_ }
        if ($PassThru)
        {
            $IQApp | Get-NexusIQApplication
        }
    }
}

#region Argument completers
$OrganizationCompleterScriptBlock = {
    param ( $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters )
    Invoke-NexusIQAPI -Path "organizations" | Select-Object -ExpandProperty organizations |
    Select-Object -ExpandProperty name | ForEach-Object -Process { $_ }
}
$RegisterArgumentCompleterParams = @{
    CommandName   = "Move-NexusIQApplicationOrganization","New-NexusIQApplication","Find-NexusIQApplication"
    ParameterName = "OrganizationName"
    ScriptBlock   = $OrganizationCompleterScriptBlock
}
Register-ArgumentCompleter @RegisterArgumentCompleterParams

$RegisterArgumentCompleterParams = @{
    CommandName   = "Get-NexusIQOrganization"
    ParameterName = "Name"
    ScriptBlock   = $OrganizationCompleterScriptBlock
}
Register-ArgumentCompleter @RegisterArgumentCompleterParams
#endregion

<#
.SYNOPSIS
    Renames an application in Nexus IQ based on its "Public ID"
.EXAMPLE
    Get-NexusIQApplication -PublicId App1Id | Rename-NexusIQApplication -NewName "This is my renamed app"
.EXAMPLE
    Get-NexusIQApplication -Name "My App" | Rename-NexusIQApplication -NewName "This is my renamed app"
.LINK
    https://help.sonatype.com/en/application-rest-api.html
#>
filter Rename-NexusIQApplication
{
    [CmdletBinding(DefaultParameterSetName="Id")]
    param (
        # This is the application ID for the application. In the IQ Server GUI this is represented by the "Application" field. It must be unique., NOT the public Id
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Id")]
        [string]$Id,

        # Name of the application, i.e. what you see in the UI's application page
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Name")]
        [string]$Name,

        # The Public Id of the application, aka App Id from the UI
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="PublicId")]
        [string]$PublicId,

        # The new Public Id to set the application to, aka App Id from the UI
        [string]$NewPublicId,

        # The new name
        [string]$NewName,

        [switch]$PassThru
    )
    Set-NexusIQApplication @PSBoundParameters
}

<#
.SYNOPSIS
    Retrieves the Application in Nexus IQ based on its "Public ID"
.EXAMPLE
    New-NexusIQApplication -ApplicationId AppId1 -Name "My Special App" -OrganizationName MyOrg
.LINK
    https://help.sonatype.com/en/application-rest-api.html
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
    Remove-NexusIQApplication PublicId AppId1
.EXAMPLE
    Get-NexusIQApplication PublicId AppId1 | Remove-NexusIQApplication
.EXAMPLE
    Remove-NexusIQApplication -Name "New App"
.LINK
    https://help.sonatype.com/en/application-rest-api.html
#>
filter Remove-NexusIQApplication
{
    [CmdletBinding(DefaultParameterSetName="Id")]
    param (
        # Unique internal Id of the application
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Id")]
        [string]$Id,

        # This is the application ID for the application. In the IQ Server GUI this is represented by the "Application" field. It must be unique., i.e. publicId
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="PublicId")]
        [Alias("ApplicationId")]
        [string]$PublicId,

        # Name of the application, i.e. what you see in the UI's application page
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Name")]
        [string]$Name
    )
    $InternalId = ""
    if ($PSBoundParameters.ContainsKey("Id"))
    {
        $InternalId = $Id
    }
    else
    {
        # Halt if the application wasn't found
        $InternalId = Get-NexusIQApplication @PSBoundParameters -ErrorAction Stop | Select-Object -ExpandProperty id
    }
    Invoke-NexusIQAPI -Path "applications/$InternalId" -Method Delete
}

<#
.SYNOPSIS
    Retrieves an Organization in Nexus IQ
.EXAMPLE
    Get-NexusIQOrganization -Name MyOrg
.EXAMPLE
    "MyOrg1" | Get-NexusIQOrganization
.LINK
    https://help.sonatype.com/en/organizations-rest-api.html
#>
filter Get-NexusIQOrganization
{
    [CmdletBinding(DefaultParameterSetName="Id")]
    param (
        # Name of the organization
        [Parameter(ParameterSetName="Name",ValueFromPipeline,Position=0)]
        [string[]]$Name,
        
        # Id of the organization
        [Parameter(ParameterSetName="Id",ValueFromPipelineByPropertyName)]
        [string[]]$Id
    )
    if ($Name)
    {
        foreach ($OrgName in $Name)
        {
            Write-Verbose "Finding organization $OrgName"
            Invoke-NexusIQAPI -Path "organizations" -Parameters @{ organizationName=$OrgName } |
            Select-Object -ExpandProperty organizations
        }
    }
    elseif ($Id)
    {
        foreach ($OrgId in $Id)
        {
            Invoke-NexusIQAPI -Path "organizations/$OrgId"
        }
    }
    else
    {
        (Invoke-NexusIQAPI -Path "organizations").organizations
    }
}

<#
.SYNOPSIS
    Retrieves the policy IDs used to retrieve policy violations
.EXAMPLE
    $PolicyInfo = Get-NexusIQPolicyId
    Get-NexusIQPolicyViolation -PolicyId $PolicyInfo[0].id
.LINK
    https://help.sonatype.com/en/policy-violation-rest-api.html#PolicyViolationRESTAPIv2-Step1-GetthePolicyIDs
#>
filter Get-NexusIQPolicyId
{
    [CmdletBinding()]
    param ()
    (Invoke-NexusIQAPI -Path "policies").policies
}

<#
.SYNOPSIS
    Retrieves polices and their associated organizations or applications. Basically makes it easier for the user to look up policies by 
    doing all the heavy lifting under the hood.
.EXAMPLE
    Get-NexusIQPolicy -Type Organization -Name MyOrg
    # Retrieves all the policies of the specified organization
.EXAMPLE
    Get-NexusIQPolicy -Type Application -Name MyApp1
    # Retrieves the policies of the specified application
.LINK
    https://help.sonatype.com/en/policy-violation-rest-api.html#PolicyViolationRESTAPIv2-Step1-GetthePolicyIDs
#>
filter Get-NexusIQPolicy
{
    [CmdletBinding()]
    param (
        # Whether to retrieve an application's policies or an organization's
        [ValidateSet("Organization","Application")]
        [string]$Type,

        # Name of the organization to query for policies
        [string[]]$Name,

        # Name of the application to query for policies
        [Parameter(ParameterSetName="Application Name")]
        [string[]]$ApplicationName
    )
    switch ($Type)
    {
        "Organization" {
            $Organizations = Get-NexusIQOrganization -Name $Name
            $Name | Where-Object { $_ -notin $Organizations.name } | ForEach-Object {
                Write-Error "The organization '$_' was not found" -ErrorAction Stop
            }
            Get-NexusIQPolicyId | Where-Object -Property ownerType -EQ "ORGANIZATION" | Where-Object -Property ownerId -In $Organizations.id
            continue
        }
        "Application" {
            $Applications = Get-NexusIQApplication -Name $Name
            $Name | Where-Object { $_ -NotIn $Applications.name }  | ForEach-Object {
                Write-Error "The application '$_' was not found" -ErrorAction Stop
            }
            Get-NexusIQPolicyId | Where-Object -Property ownerType -EQ "APPLICATION" | Where-Object -Property ownerId -In $Applications.id
            continue
        }
        default {
            # Just retrieve all of them
            Get-NexusIQPolicyId
        }
    }
}

<#
.SYNOPSIS
    The Policy Violation REST APIs allow you to access and extract policy violations gathered during the evaluation of applications.
    In most cases the desire for getting to this data is to integrate into other tools your company may have.
    For example you may have a specific dashboard or reporting application that should have this data.
.EXAMPLE
    $PolicyInfo = Get-NexusIQPolicyId | Where-Object -Property name -EQ "Security-High"
    Get-NexusIQPolicyViolation -PolicyId $PolicyInfo.id
.EXAMPLE
    Get-NexusIQPolicyId | Where-Object -Property threatLevel -gt 5 | Get-NexusIQPolicyViolation
.LINK
    https://help.sonatype.com/en/policy-violation-rest-api.html#PolicyViolationRESTAPIv2-Step2-GetthePolicyViolations
#>
filter Get-NexusIQPolicyViolation
{
    [CmdletBinding()]
    param (
        # Id of the policy to find the violations for
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PolicyId")]
        [guid[]]$Id
    )
    foreach ($PolicyId in $Id)
    {
        Invoke-NexusIQAPI -Path "policyViolations" -Parameters @{ p=$PolicyId }
    }
}

<#
.SYNOPSIS
    Retrieves reports for the specified stage of an application
.EXAMPLE
    Get-NexusIQReport -ApplicationId MyApp1 -Stage stage-release
.EXAMPLE
    Get-NexusIQReport -Name MyAppName -Stage stage-release
.EXAMPLE
    Get-NexusIQApplication -ApplicationId MyApp1 | Get-NexusIQReport -Stage stage-release
.LINK
    https://help.sonatype.com/en/report-rest-api.html
#>
filter Get-NexusIQReport
{
    [CmdletBinding(DefaultParameterSetName="Id")]
    param (
        # Unique internal Id of the application
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Id")]
        [string]$Id,

        # This is the application ID for the application. In the IQ Server GUI this is represented by the "Application" field. It must be unique., i.e. publicId
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="PublicId")]
        [Alias("ApplicationId")]
        [string]$PublicId,

        # Name of the application, i.e. what you see in the UI's application page
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Name")]
        [string]$Name,

        # Stage the report was run on
        [Parameter(Mandatory)]
        [ValidateSet("stage-release","source","build","release")]
        [string]$Stage
    )
    $InternalId = ""
    if ($PSBoundParameters.ContainsKey("Id"))
    {
        $InternalId = $Id
    }
    elseif ($PSBoundParameters.ContainsKey("PublicId"))
    {
        $InternalId = Get-NexusIQApplication -PublicId $PublicId | Select-Object -ExpandProperty id
    }
    elseif ($PSBoundParameters.ContainsKey("Name"))
    {
        $InternalId = Get-NexusIQApplication -Name $Name | Select-Object -ExpandProperty id
    }
    Invoke-NexusIQAPI -Path "reports/applications/$InternalId" | Where-Object -Property stage -EQ $Stage
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
    [CmdletBinding(DefaultParameterSetName="Id")]
    param (
        # Unique internal Id of the application
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Id")]
        [string]$Id,

        # The unique ID of the application
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="PublicId")]
        [Alias("ApplicationId")]
        [string]$PublicId,

        # This is the name of the application. In the IQ Server GUI this corresponds to the "Application Name" field.
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="Name")]
        [string]$Name,

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
    $ReportsInfo = if ($PSBoundParameters.ContainsKey("Id"))
    {
        Get-NexusIQReport -Id $Id -Stage $Stage
    }
    elseif ($PSBoundParameters.ContainsKey("PublicId"))
    {
        Get-NexusIQReport -PublicId $PublicId -Stage $Stage
    }
    elseif ($PSBoundParameters.ContainsKey("Name"))
    {
        Get-NexusIQReport -Name $Name -Stage $Stage
    }
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

<#
.SYNOPSIS
    Saves the user's Nexus IQ token using a saved PSCredential object stored as a CliXml file with an XML extension.
    Only works on a per-machine, per-user basis.
.PARAMETER Credential
    PSCredential where the username is the UserCode and the password is the PassCode. This will be passed to Nexus IQ when calling the
    API. PowerShell 7+ automatically formats the username and password properly using Base-64 encoding and Basic authentication.
.PARAMETER BaseUrl
    The URL of the Nexus IQ website
.EXAMPLE
    Connect-NexusIQ -BaseUrl https://nexusiq.mycompany.com
.EXAMPLE
    # Reuse an existing profile's base URL and change the credentials
    $Settings = Get-NexusIQ
    $Settings | Connect-NexusIQ -Credential (Get-Credential)
#>
filter Connect-NexusIQ
{
    [CmdletBinding()]
    [Alias("Login-NexusIQ","Save-NexusIQLogin")]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$BaseUrl,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [PSCredential]$Credential,

        [Parameter(ValueFromPipeline)]
        [NexusIQAPIVersion]$APIVersion = "V2"
    )
    if (-not (Test-Path ([NexusIQSettings]::SaveDir))) { New-Item -Type Directory -Path ([NexusIQSettings]::SaveDir) | Out-Null }
    else { Write-Verbose "Profile folder already existed" }

    $Settings = [NexusIQSettings]::new($Credential,$BaseUrl,$APIVersion)
    $Settings | Export-CliXml -Path ([NexusIQSettings]::SavePath) -Encoding 'utf8' -Force
    $Settings
}

<#
.SYNOPSIS
    Removes the user's login profile
.EXAMPLE
    Disconnect-NexusIQ
#>
filter Disconnect-NexusIQ
{
    [CmdletBinding()]
    [Alias("Logout-NexusIQ","Remove-NexusIQLogin")]
    param ()
    if (Test-Path ([NexusIQSettings]::SaveDir))
    {
        Remove-Item ([NexusIQSettings]::SaveDir) -Recurse
    }
    else
    {
        Write-Warning "The profile did not exist in path $([NexusIQSettings]::SaveDir)"
    }
}

<#
.SYNOPSIS
    Retrieves the saved profile information of the current user, including BaseUrl and the userCode and passCode they are using. No parameters required.
#>
filter Get-NexusIQSettings
{
    [CmdletBinding()]
    [OutputType([NexusIQSettings])]
    param ()
    if (Test-Path -Path ([NexusIQSettings]::SavePath))
    {
        $XML = Import-Clixml -Path ([NexusIQSettings]::SavePath)
        [NexusIQSettings]::new($XML.Credential,$XML.BaseUrl,$XML.APIVersion)
    }
    else
    {
        throw "Use Connect-NexusIQ to create a login profile"
    }
}

<#
.SYNOPSIS
    Verifies the user can log into the system. No parameters required.
#>
filter Test-NexusIQLogin
{
    [CmdletBinding()]
    [OutputType([bool])]
    param ()
    try
    {
        if (Invoke-NexusIQAPI -Path "userTokens/currentUser/hasToken" -ErrorAction Stop) { $true }
    }
    catch { $false }
}

filter Invoke-NexusIQAPI
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Path,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = "Get",
        # Use the api or rest extension
        [ValidateSet("api","rest","ui")]
        [string]$RequestType = "api",
        [Hashtable]$Parameters,
        $Body,
        [string]$ContentType,
        # Optionally where to output the result
        [string]$OutFile
    )
    $Settings = Get-NexusIQSettings
    $StringBuilder = [System.Text.StringBuilder]::new("$($Settings.BaseUrl)$RequestType")
    if ($RequestType -eq "api") { $StringBuilder.Append("/$($Settings.APIVersion.ToString())") | Out-Null }
    $StringBuilder.Append("/$Path") | Out-Null

    if ($Parameters)
    {
        $Separator = "?"
        $Parameters.Keys | ForEach-Object {
            $StringBuilder.Append(("{0}{1}={2}" -f $Separator,$_,[System.Web.HttpUtility]::UrlEncode($Parameters."$_".ToString()))) | Out-Null
            $Separator = "&"
        }
    }
    $Uri = $StringBuilder.ToString()
    Write-Verbose "Invoking Url $Uri"

    $Splat = @{
        Uri=$Uri
        Method=$Method
    }
    if ($PSVersionTable.PSVersion.Major -ge "6.0")
    {
        $Splat.Add("Authentication","Basic")
        $Splat.Add("Credential",$Settings.Credential)
    }
    else
    {
        $Pair = "$($Settings.Username):$($Settings.Credential.GetNetworkCredential().Password)"
        $EncodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Pair))
        $Headers = @{ Authorization = "Basic $EncodedCreds" }
        $Splat.Add("Headers",$Headers)
    }

    if ($ContentType) { $Splat.Add("ContentType",$ContentType) }
    # Either output to a file or save the response to the "Response" variable
    if ($PSBoundParameters.ContainsKey("Outfile")) { ($Splat.Add("OutFile",$OutFile) ) }
    else  { $Splat.Add("OutVariable","Response") }
    if ($Body) { $Splat.Add("Body",$Body) }

    $null = Invoke-RestMethod @Splat
    if ($Response)
    {
        Write-Verbose "Unravel the response so it outputs each item to the pipeline instead of all at once"
        for ([UInt16]$i = 0; $i -lt $Response.Count; $i++) { $Response[$i] }
    }
}

class NexusIQSettings
{
    static [String]$SaveDir = "$UserHomeFolder$([System.IO.Path]::DirectorySeparatorChar)NexusIQ"
    static [String]$SavePath = "$([NexusIQSettings]::SaveDir)$($([System.IO.Path]::DirectorySeparatorChar))Auth.xml"

    # Parameters
    [String]$BaseUrl
    [PSCredential]$Credential
    [NexusIQAPIVersion]$APIVersion

    NexusIQSettings([PSCredential]$Credential,[uri]$BaseUrl,[NexusIQAPIVersion]$APIVersion)
    {
        $this.BaseUrl = $BaseUrl
        $this.Credential = $Credential
        $this.APIVersion = $APIVersion
    }
}

enum NexusIQAPIVersion
{
    v1
    v2
}
