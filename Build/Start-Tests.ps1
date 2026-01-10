[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ModuleName = $env:ModuleName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({Test-Path $_})]
    [string]$TempDirectory = $env:AGENT_TEMPDIRECTORY
)
Set-StrictMode -Version 1
#Requires -Modules @{ ModuleName="Pester"; ModuleVersion="5.0.0" }

Import-Module "$env:BUILD_SOURCESDIRECTORY/$ModuleName.psd1" -Verbose
$ResultsFolderPath = New-Item -Path $TempDirectory ItemType Directory | Select-Object -Expand FullName

$Config = New-PesterConfiguration
$Config.CodeCoverage.Enabled = $true
$Config.CodeCoverage.Path = @('./*.psm1')
$Config.CodeCoverage.OutputPath = "$ResultsFolderPath/coverage.xml"
$Config.CodeCoverage.OutputFormat = 'JaCoCo'
$Config.Run.Exit = $true
$Config.TestResult.Enabled = $true
$Config.TestResult.OutputPath = "$ResultsFolderPath/test-results.xml"
$Config.TestResult.OutputFormat = 'NUnitXml'
$Config.Output.CIFormat = 'AzureDevOps'
$Splat = @{
    InformationAction = "Continue"
    Verbose           = $true
    Configuration     = $Config
}
Invoke-Pester @Splat
