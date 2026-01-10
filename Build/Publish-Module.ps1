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
"----Temp Directory-----"
Get-ChildItem $TempDirectory | Select-Object -ExpandProperty Path
"----Module Directory-----"
Get-ChildItem "$TempDirectory/$ModuleName" | Select-Object -ExpandProperty Path
"----Imported Module Directory-----"
Get-ChildItem (Split-Path $ModuleInfo) -Recurse | Select-Object -ExpandProperty Path
# Publish-Module -Name $ModuleName -Repository PSGallery -NuGetApiKey $env:NuGetApiKey -Verbose
