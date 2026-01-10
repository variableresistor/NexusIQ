# Nexus IQ PowerShell Module
PowerShell module to interact with the Nexus IQ REST API. Essentially a wrapper for built-in Nexus IQ REST API functionality. Documentation for the REST API can be found [here](https://help.sonatype.com/iqserver/automating/rest-apis). Thanks to [Atlassian.BitBucket](https://github.com/beyondcomputing-org/Atlassian.Bitbucket) for code samples.

## Installation
Run the following command in PowerShell session to install the module from the PowerShell Gallery. If following the instructions above, the below command should not require elevation

```powershell
if (Get-Module Microsoft.PowerShell.PSResourceGet -List)
{
    Install-PSResource -Name NexusIQ -TrustRepository
}
else
{
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name NexusIQ -Scope CurrentUser
}
```

## Authentication
The module provides machine / user encrypted persistance between sessions. Instructions on generating your API token here: [User Token REST API - v2](https://help.sonatype.com/iqserver/automating/rest-apis/user-token-rest-api---v2) and run:
```powershell
Connect-NexusIQ -BaseUrl https://nexusiq.mycompany.com
```

Alternatively, generate the token through the web UI by logging in with a username and password (not SSO), then select "Manage User Token".

## Update
If you already have the module installed, run the following command to update the module from the PowerShell Gallery to the latest version.

```powershell
if (Get-Module Microsoft.PowerShell.PSResourceGet -List)
{
    Update-PSResource -Name NexusIQ
}
else
{
    Update-Module -Name NexusIQ
}

Then add this to your Visual Studio Code's PowerShell Profile:

```powershell
$Host.PrivateData.VerboseForegroundColor = "Cyan"
$Host.PrivateData.WarningForegroundColor = "DarkYellow"
```
