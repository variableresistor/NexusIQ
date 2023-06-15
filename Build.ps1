<#
.SYNOPSIS
    Consolidates all the submodules into a single module file. Helps speed up module import.
#>
[CmdletBinding()]
param ()
Write-Verbose "Put all the module files' content into a single file"
$RootModulePath = "$PSScriptRoot\NexusIQ.psm1"
Set-Content -Path $RootModulePath -Value (Get-Content "$PSScriptRoot\Base.psm1")
Remove-Item "$PSScriptRoot\Base.psm1"
$ModuleFiles = Get-ChildItem -File -Path $PSScriptRoot -Filter "*.psm1" -Exclude ([System.IO.Path]::GetFileName($RootModulePath))
$ModuleFiles | Get-Content | Add-Content -Path $RootModulePath

Write-Verbose "Modify the module manifest to include only a single module file."
$ManifestFile = "$PSScriptRoot\NexusIQ.psd1"
(Get-Content $ManifestFile) -replace "NestedModules\s\=\s@\(.*\)","NestedModules = @()" -replace "using\smodule\s\.\\Base\.psm1","" |
Set-Content -Path $ManifestFile

$ModuleFiles | Remove-Item -Verbose
