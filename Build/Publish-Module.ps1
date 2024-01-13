[CmdletBinding()]
param (
  [ValidateNotNullOrEmpty()][string]$NuGetApiKey = $env:NuGetApiKey
)
$Script:ErrorActionPreference = 'Stop'
Set-StrictMode -Version 1 # Just to be extra careful

$ModuleFolderPath = (Split-Path $PSScriptRoot)
$ModuleName = [System.IO.Path]::GetFileName($ModuleFolderPath)
$Version = ((Get-Content "$ModuleFolderPath\azure-pipelines.yml" | Select-String -Pattern "name:\s\d" -Raw) -replace "name: ","").Trim()
(Get-Content "$ModuleFolderPath\$ModuleName.psd1") -replace "ModuleVersion = '.*'","ModuleVersion = '$Version'" |
Set-Content -Path "$ModuleFolderPath\$ModuleName.psd1" -PassThru

if (Get-Module -Name $ModuleName -ListAvailable)
{
  Remove-Module -Name $ModuleName -ErrorAction SilentlyContinue
  Uninstall-Module -Name $ModuleName -AllVersion -Verbose
}
$env:PSModulePath += ";$(Split-Path $ModuleFolderPath)"
Get-ChildItem -Directory | Remove-Item -Recurse -Verbose
Import-Module $ModuleName -Verbose -RequiredVersion $Version

# Publish-Module -Name $env:ModuleName -Repository PSGallery -NuGetApiKey $NuGetApiKey -Verbose
git reset --hard
