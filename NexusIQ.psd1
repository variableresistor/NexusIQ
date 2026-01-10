@{
RootModule = 'NexusIQ'
ModuleVersion = '1.1.0'
CompatiblePSEditions = @('Core','Desktop')
GUID = 'c3d771fe-aabc-4c99-bf81-98f7f7c47332'
Author = 'Neil White'
Description = 'Module acts as a wrapper for the Nexus IQ REST API'
PowerShellVersion = '5.1.0'
# RequiredModules = @()
# RequiredAssemblies = @()
# TypesToProcess = @()
# FormatsToProcess = @()
# NestedModules = @()
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
    "Find-NexusIQApplication"
    "Move-NexusIQApplicationOrganization"
    "Rename-NexusIQApplication"
)
CmdletsToExport = @()
AliasesToExport = @(
    "Login-NexusIQ"
    "Logout-NexusIQ"
    "Save-NexusIQLogin"
    "Remove-NexusIQLogin"
)
# ModuleList = @()
PrivateData = @{
    PSData = @{
        Tags = 'NexusIQ', 'Nexus', 'PoshNexusIQ'
        LicenseUri = 'https://github.com/variableresistor/NexusIQ/blob/main/LICENSE'
        ProjectUri = 'https://github.com/variableresistor/NexusIQ'
        IconUri = 'https://github.com/variableresistor/NexusIQ/blob/main/assets/icon.png'
        ReleaseNotes = 'https://github.com/variableresistor/NexusIQ/blob/main/CHANGELOG.md'
    }
}
# HelpInfoURI = ''
}
