using module .\Base.psm1
<#
.SYNOPSIS
    Retrieves an Organization in Nexus IQ
.EXAMPLE
    Get-NexusIQOrganization -Name MyOrg
.EXAMPLE
    "MyOrg1" | Get-NexusIQOrganization
.LINK
    https://help.sonatype.com/iqserver/automating/rest-apis/organizations-rest-api---v2
#>
filter Get-NexusIQOrganization
{
    [CmdletBinding(DefaultParameterSetName="Id")]
    param (
        # Name of the organization
        [Parameter(ParameterSetName="Name",ValueFromPipeline)]
        [string[]]$Name,
        
        # Id of the organization
        [Parameter(ParameterSetName="Id",ValueFromPipelineByPropertyName)]
        [string[]]$Id
    )
    if ($Name)
    {
        foreach ($OrgName in $Name)
        {
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
