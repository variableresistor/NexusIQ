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
    "Get-NexusIQSettings"
    "Save-NexusIQLogin"
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
)
CmdletsToExport = @()
# VariablesToExport = '*'
AliasesToExport = @(
    "Login-NexusIQ"
    "New-NexusIQLogin"
)
# ModuleList = @()
PrivateData = @{
    PSData = @{
        Tags = 'NexusIQ', 'Nexus'
        # LicenseUri = ''
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

