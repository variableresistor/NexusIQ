using module .\Base.psm1
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
    Saves the user's Nexus IQ token using a saved PSCredential object stored as a CliXml file with an XML extension.
    Only works on a per-machine, per-user basis.
.PARAMETER Credential
    PSCredential where the username is the UserCode and the password is the PassCode. This will be passed to Nexus IQ when calling the
    API. PowerShell 7+ automatically formats the username and password properly using Base-64 encoding and Basic authentication.
.PARAMETER BaseUrl
    The URL of the Nexus IQ website
.EXAMPLE
    Save-NexusIQLogin -BaseUrl https://nexusiq.mycompany.com
.EXAMPLE
    # Reuse an existing profile's base URL and change the credentials
    $Settings = Get-NexusIQSettings
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
    if (-not (Test-Path([NexusIQSettings]::SaveDir))) { New-Item -Type Directory -Path ([NexusIQSettings]::SaveDir) | Out-Null }
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
        Remove-Item [NexusIQSettings]::SaveDir -Recurse
    }
    else
    {
        Write-Warning "The profile did not exist in path $([NexusIQSettings]::SaveDir)"
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
