<#
.SYNOPSIS
    Consolidates all the submodules into a single module file. Helps speed up module import.
#>
[CmdletBinding()]
param ()
$Script:ErrorActionPreference = 'Stop'
$Separator = [System.IO.Path]::DirectorySeparatorChar
Write-Information "Put all the module files' content into a single file"
$SourceDir = Split-Path $PSScriptRoot
$RootModulePath = "$SourceDir$Separator`NexusIQ.psm1"
Set-Content -Path $RootModulePath -Value (Get-Content "$SourceDir$Separator`Base.psm1")
Remove-Item "$SourceDir$Separator`Base.psm1"

Write-Information "Add the rest of the file content"
$ModuleFiles = Get-ChildItem -File -Path $SourceDir -Filter "*.psm1" | Where-Object -Property Name -NE ([System.IO.Path]::GetFileName($RootModulePath))
($ModuleFiles | Get-Content) -replace "using\smodule\s\.\\Base\.psm1","" | Add-Content -Path $RootModulePath

Write-Information "Modify the module manifest to include only a single module file."
$ManifestFile = "$SourceDir$Separator`NexusIQ.psd1"
(Get-Content $ManifestFile) -replace "NestedModules\s\=\s@\(.*\)","NestedModules = @()" |
Set-Content -Path $ManifestFile

$ModuleFiles | Remove-Item -Verbose
