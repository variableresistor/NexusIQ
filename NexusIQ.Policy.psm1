using module .\Base.psm1
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
.NOTES
    https://help.sonatype.com/iqserver/automating/rest-apis/policy-violation-rest-api---v2#PolicyViolationRESTAPIv2-Step1-GetthePolicyIDs
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
    Retrieves the policy IDs used to retrieve policy violations
.EXAMPLE
    $PolicyInfo = Get-NexusIQPolicyId
    Get-NexusIQPolicyViolation -PolicyId $PolicyInfo[0].id
.NOTES
    https://help.sonatype.com/iqserver/automating/rest-apis/policy-violation-rest-api---v2#PolicyViolationRESTAPIv2-Step1-GetthePolicyIDs
#>
filter Get-NexusIQPolicyId
{
    [CmdletBinding()]
    param ()
    (Invoke-NexusIQAPI -Path "policies").policies
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
.NOTES
    https://help.sonatype.com/iqserver/automating/rest-apis/policy-violation-rest-api---v2#PolicyViolationRESTAPIv2-Step2-GetthePolicyViolations
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
