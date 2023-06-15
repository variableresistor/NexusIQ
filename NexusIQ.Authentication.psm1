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
        throw "Use Login-NexusIQ to create a login profile"
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
    $Settings = Get-SonarQubeSettings
    $Settings | Login-NexusIQ -Credential (Get-Credential)
#>
filter Save-NexusIQLogin
{
    [CmdletBinding()]
    [Alias("Login-NexusIQ","New-NexusIQLogin")]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential = (Get-Credential -Message "Enter the Usercode and Passcode generated from Nexus IQ"),

        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$BaseUrl,

        [Parameter(ValueFromPipeline)]
        [NexusIQAPIVersion]$APIVersion = "V2"
    )
    if (-not (Test-Path([NexusIQSettings]::SaveDir))) { New-Item -Type Directory -Path ([NexusIQSettings]::SaveDir) }
    else { Write-Verbose "Profile folder already existed" }

    $Settings = [NexusIQSettings]::new($Credential,$BaseUrl,$APIVersion)
    $Settings | Export-CliXml -Path ([NexusIQSettings]::SavePath) -Encoding 'utf8' -Force
    # -not (Test-NexusIQLogin) ? (Write-Warning "Something went wrong and the token entered wasn't able to authenticate to $($Settings.BaseUrl).") : (Write-Verbose "Login was successful")
    $Settings
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
