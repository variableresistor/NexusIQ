# Nexus IQ PowerShell Module
PowerShell module to interact with the Nexus IQ REST API. Essentially a wrapper for built-in Nexus IQ REST API functionality. Documentation for the REST API can be found [here](https://help.sonatype.com/iqserver/automating/rest-apis). Thanks to [Atlassian.BitBucket](https://github.com/beyondcomputing-org/Atlassian.Bitbucket) for code samples.

## Using The Module
See Confluence page https://cnr.atlassian.net/wiki/spaces/CNRD/pages/1382219801/PowerShell+Environment+Setup on setting up local PowerShell environment

## Installation
Run the following command in PowerShell session to install the module from the PowerShell Gallery. If following the instructions above, the below command should not require elevation

```powershell
Install-Module -Name hNexusIQ -Scope CurrentUser
```

## Authentication
The module provides machine / user encrypted persistance between sessions. Instructions on generating your API token here: [User Token REST API - v2](https://help.sonatype.com/iqserver/automating/rest-apis/user-token-rest-api---v2) and run
```powershell
Connect-NexusIQ -BaseUrl https://nexusiq.mycompany.com
```

Alternatively, generate the token through the web UI by logging in with a username and password (not SSO), then select "Manage User Token".

## Update
If you already have the module installed, run the following command to update the module from the PowerShell Gallery to the latest version.

```powershell
Update-Module -Name NexusIQ
```

## Developing
It's not really fleshed out yet, but a few things that need to be done to develop locally:
* Change the parameters in all the Pester test files to some arbitrary values
* Import the .\Pase.psm1 before trying to troubleshoot your contribution. This is so the module files can be
organized neatly into separate files.
* Use Connect-NexusIQ to point to your local Nexus IQ instance
