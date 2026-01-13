# Nexus IQ PowerShell Module
# Introduction
A PowerShell module for the Sonatype Nexus IQ REST API acting as a functional wrapper, translating complex HTTP web requests into easy-to-use PowerShell cmdlets. It allows administrators and DevOps engineers to automate security governance tasks directly from their terminal or within CI/CD scripts without manually constructing JSON payloads or managing headers.
Most functions support the -Passthru parameter to allow for chaining function calls together.

## Authentication
The module provides machine / user encrypted persistance between sessions. Instructions on generating your API token here: [User Token REST API - v2](https://help.sonatype.com/iqserver/automating/rest-apis/user-token-rest-api---v2) and run:
```powershell
$Credential = Get-Credential -Prompt "Enter the usercode and passcode generated from Nexus IQ"
Connect-NexusIQ -BaseUrl https://nexusiq.mycompany.com -Credential $Credential
```
Test to make sure it works:
```powershell
Test-NexusIQLogin
```
To delete your credentials and start over:
```powershell
Disconnect-NexusIQ
```

## Application Management:
Retrieve an application in Nexus IQ with the name displayed in the UI:
```powershell
Get-NexusIQApplication -Name "My Application's Name"
```
You can also retrieve more than 1 application using wildcards or by passing in more than one name:
```powershell
Get-NexusIQApplication -Name "My Application*"
Get-NexusIQApplication -Name "My Application 1","My Application 2"
```
Retrieve an organization where the PublicId is the unique identifier in Nexus IQ, sometimes called Application Id.
```powershell
Get-NexusIQApplication -PublicId AppId1
```
To simply retrieve all applications:
```powershell
Find-NexusIQApplication
```
Creating a new application:
```powershell
New-NexusIQApplication -ApplicationId AppId1 -Name "My First Application" -OrganizationName Contoso
```
Deleting an application:
```powershell
Remove-NexusIQApplication -Name "My First Application"
# Or using the pipeline
Get-NexusIQApplication -Name "My First Application" | Remove-NexusIQApplication
```
You can rename an application using named parameters or using the pipeline. You can pass the PassThru parameter to pipe the output into another function:
```powershell
 Rename-NexusIQApplication -Name "My First Application" -NewName "Rename-ApplicationNewName" -PassThru
 Get-NexusIQApplication -Name "My First Application" | Rename-NexusIQApplication -NewName "My First App's new name"
```
To relocate an application to another organization:
```powershell
$ReferenceApp = New-NexusIQApplication -PublicId "App1" -Name "My First Application" -OrganizationName Contoso
Move-NexusIQApplicationOrganization -OrganizationName Fabrikam -PublicId "App1" -PassThru
```

## Reporting
Export the release stage report to PDF:
```powershell
Get-NexusIQApplication -Name "My Application's Name" | Export-NexusIQReport -Stage release -ReportType PDF -OutFile "$env:USERPROFILE\Desktop\Report1.pdf"
```
Retrieves a report from My First Application in the "Stage Release" stage formatted in JSON:
```powershell
Get-NexusIQReport -Name "My First Application" -Stage stage-release
```

## Organizations
To retrieve basic information about an organization:
```powershell
Get-NexusIQOrganization -Name Contoso
```

## Policy
"Retrieves all policies:
```powershell
Get-NexusIQPolicy
```
"Retrieves all policies by Organization name:
```powershell
Get-NexusIQPolicy -Type Organization -Name Contoso
```
Retrieves policies by applied to an Application:
```powershell
Get-NexusIQPolicy -Type Application -Name "My First Application"
```

## Update
If you already have the module installed, run the following command to update the module from the PowerShell Gallery to the latest version.

```powershell
Update-Module -Name NexusIQ
```
