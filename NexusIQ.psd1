@{
RootModule = 'NexusIQ'
ModuleVersion = '1.0.0'
CompatiblePSEditions = @('Core','Desktop')
GUID = 'c3d771fe-aabc-4c99-bf81-98f7f7c47332'
Author = 'Neil White'
CompanyName = 'variableresistor'
Copyright = 'Copyright 2023 variableresistor'
Description = 'Module acts as a wrapper for the Nexus IQ REST API'
PowerShellVersion = '5.1.0'
# RequiredModules = @()
RequiredAssemblies = @("System.IO.Compression.FileSystem")
# TypesToProcess = @()
# FormatsToProcess = @()
NestedModules = @("NexusIQ.Application","NexusIQ.Authentication","NexusIQ.Organization","NexusIQ.Report","NexusIQ.Scan")
FunctionsToExport = @(
    "Connect-NexusIQ"
    "Disconnect-NexusIQ"
    "Get-NexusIQSettings"
    "Test-NexusIQLogin"
    "Get-NexusIQApplication"
    "Get-NexusIQReport"
    "Export-NexusIQReport"
    "Get-NexusIQOrganization"
    "New-NexusIQApplication"
    "Remove-NexusIQApplication"
    "Get-NexusIQPolicyId"
    "Get-NexusIQPolicy"
    "Get-NexusIQPolicyViolation"
    "Set-NexusIQApplication"
)
CmdletsToExport = @()
# VariablesToExport = '*'
AliasesToExport = @(
    "Login-NexusIQ"
    "Logout-NexusIQ"
    "Save-NexusIQLogin"
    "Remove-NexusIQLogin"
)
# ModuleList = @()
PrivateData = @{
    PSData = @{
        Tags = 'NexusIQ', 'Nexus'
        LicenseUri = 'https://github.com/variableresistor/NexusIQ/blob/main/LICENSE'
        ProjectUri = 'https://github.com/variableresistor/NexusIQ'
        # IconUri = ''
        # ReleaseNotes = ''
        # Prerelease = ''
        # ExternalModuleDependencies = @()
    }
}
# HelpInfoURI = ''
# DefaultCommandPrefix = ''S
}

