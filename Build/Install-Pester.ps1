$AllPesterModules = Get-Module Pester -ListAvailable
$LatestPesterModule = $AllPesterModules | Sort-Object -Property Version -Desc | Select-Object -First 1
if (-not $LatestPesterModule -or $LatestPesterModule.Version -lt [version]"5.0.0")
{
    Install-Module Pester -Repository PSGallery -Scope CurrentUser -AllowClobber -SkipPublisherCheck -MinimumVersion $env:MinimumVersion -Force -Verbose
}
else
{
    $AllPesterModules
    "Pester was up-to-date"
}
