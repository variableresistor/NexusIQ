(Get-Content "./$env:ModuleName.psd1") -replace "ModuleVersion = '.*'","ModuleVersion = '$env:Version'" |
Set-Content -Path "./$env:ModuleName.psd1" -PassThru
if (Get-Module -Name $env:ModuleName -ListAvailable)
{
  Remove-Module -Name $env:ModuleName -ErrorAction SilentlyContinue
  Uninstall-Module -Name $env:ModuleName -AllVersion -Verbose
}
$env:ModulePath += ";$env:Pipeline_Workspace"
Get-ChildItem -Directory | Remove-Item -Recurse -Verbose
Import-Module $env:ModuleName -Verbose -RequiredVersion $env:Version

# Publish-Module -Name $env:ModuleName -Repository PSGallery -NuGetApiKey $(NuGetApiKey) -Verbose
git reset --hard
