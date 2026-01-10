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
$PathSeparator = switch (Test-Path Env:/Path)
{
  $true { ";" } # WIndows
  $false { ";" } # Linux b/c it's all caps
}
$env:PSModulePath += "$PathSeparator$TempDirectory/$ModuleName"
Import-Module $env:ModuleName -Verbose
# Publish-Module -Name $ModuleName -Repository PSGallery -NuGetApiKey $env:NuGetApiKey -Verbose
