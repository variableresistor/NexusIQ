[CmdletBinding()]
param (
  [ValidateNotNullOrEmpty()]
  [string]$NuGetApiKey = $env:NuGetApiKey,

  [Parameter()]
  [ValidateNotNullOrEmpty()]
  [string]$ModuleName = $env:ModuleName,

  [Parameter()]
  [ValidateScript({Test-Path $_})]
  [string]$TempDirectory = $env:AGENT_TEMPDIRECTORY
)
$Script:ErrorActionPreference = 'Stop'
Set-StrictMode -Version 1 # Just to be extra careful

if (Get-Module -Name $ModuleName -ListAvailable)
{
  Remove-Module -Name $ModuleName -ErrorAction SilentlyContinue
  Uninstall-Module -Name $ModuleName -AllVersions -Verbose
}
Resolve-Path "$TempDirectory/$ModuleName" | Import-Module -Verbose
$ModuleInfo = Get-Module -Name $ModuleName
$ModuleInfo
Get-ChildItem (Split-Path $ModuleInfo)
# Publish-Module -Name $ModuleName -Repository PSGallery -NuGetApiKey $env:NuGetApiKey -Verbose
