using module .\Base.psm1
<#
.SYNOPSIS
    Starts a scan and waits for the scan to complete. Doesn't really work right and the documentation seems incorrect.
.PARAMETER ApplicationId
    The application ID for your application
.PARAMETER TargetDirectory
    Working directory to scan files within
.PARAMETER Target
    This is the path to a specific application archive file, a directory containing such archives or the ID of a Docker image.
    For archives, a number of formats are supported, including jar, war, ear, tar, tar.gz, zip and many others.
    You can specify multiple scan targets ( directories or files) separated by spaces test/dir/*/*.jar test/*/*.ear
.EXAMPLE
    Invoke-NexusIQScan -ApplicationId AppId1 -TargetDirectory "$env:USERPROFILE\MyRepo" -Target "**/*.dll"
.LINK
    https://help.sonatype.com/iqserver/integrations/nexus-iq-cli
#>
filter Invoke-NexusIQScan
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias("ApplicationId")]
        [string]$PublicId,

        [Parameter(Mandatory)]
        [Alias("Directory")]
        [string]$TargetDirectory,

        [Parameter(Mandatory)]
        [string]$Target,

        [ValidateSet("stage-release","source","build","release")]
        [string]$Stage = "build",

        [ValidateSet("Windows","Linux","Mac","Cross-platform")]
        [string]$Platform = "Windows",

        [string]$Version = "1.161.0-01+630"
    )
    $CliPath = Save-NexusIQCli -Platform $Platform -Version $Version -PassThru
    $Settings = Get-NexusIQSettings
    Get-NexusIQApplication -PublicId $PublicId | Out-Null
    Push-Location
    Set-Location $TargetDirectory
    $ParamFileName = "$([NexusIQSettings]::SaveDir)\cli-params.txt"
    @"
--application-id
$PublicId
--server-url
$($Settings.BaseUrl)
--stage
$Stage
$Target
"@.TrimStart() | Out-File -FilePath $ParamFileName

    if ($Platform -eq "Cross-Platform")
    {
        $Java = "$env:ProgramFiles\Microsoft\jdk-11.0.12.7-hotspot\bin\java.exe"
        if (-not (Test-Path $Java)) { $Java = "java" }
        . "$Java" -jar "$CliPath"--authentication "$($Settings.Credential.Username)`:$($Settings.Credential.GetNetworkCredential().Password)" @$ParamFileName
    }
    else
    {
        . "$CliPath" --authentication "$($Settings.Credential.Username)`:$($Settings.Credential.GetNetworkCredential().Password)" @$ParamFileName
    }
    
    Remove-Item $ParamFileName
    Pop-Location
}

filter Save-NexusIQCli
{
    [CmdletBinding()]
    param (
        [ValidateSet("Windows","Linux","Mac","Cross-Platform")]
        [string]$Platform = "Windows",

        [ValidateNotNullOrEmpty()]
        [string]$Version = "1.161.0-01+630",

        # Tells the function to output the full path to the CLI tool
        [switch]$PassThru
    )
    $CliName = @{
        Windows = "nexus-iq-cli.exe"
        Linux   = "nexus-iq-cli"
        Mac     = "nexus-iq-cli"
        "Cross-Platform" = "nexus-iq-cli-$Version.jar" -replace "\+.*\.jar",".jar"
    }
    $CliPath = $(if ($env:OS -eq "Windows_NT") { "$([NexusIQSettings]::SaveDir)\$($CliName.Item($Platform))" } else { "$([NexusIQSettings]::SaveDir)/$($CliName.Item($Platform))"})
    if (-not (Test-Path $CliPath))
    {
        Write-Verbose "CLI tool wasn't found '$CliPath'. Downloading..."
        $Links = @{
            Windows          = "https://download.sonatype.com/clm/scanner/nexus-iq-cli-$Version-windows.zip"
            Linux            = "https://download.sonatype.com/clm/scanner/nexus-iq-cli-$Version-unix.zip"
            Mac              = "https://download.sonatype.com/clm/scanner/nexus-iq-cli-$Version-mac.pkg"
            "Cross-Platform" = "https://download.sonatype.com/clm/scanner/latest.jar"
        }
        $Url = $Links.Item($Platform)
        $OrigSecurityProtocol = [Net.ServicePointManager]::SecurityProtocol
        if ($PSVersionTable.PSEdition -ne "Core" -and "Tls12" -notin ([Net.ServicePointManager]::SecurityProtocol))
        {
            [Net.ServicePointManager]::SecurityProtocol=@(([Net.ServicePointManager]::SecurityProtocol),[Net.SecurityProtocolType]::Tls12)
        }
        $WebClient = New-Object Net.WebClient # Way faster than Invoke-WebRequest
        $DefaultProxy = [System.Net.WebRequest]::DefaultWebProxy
        if ($DefaultProxy -and (-not $DefaultProxy.IsBypassed($Url)))
        {
            $WebClient.Proxy = New-Object Net.WebProxy($DefaultProxy.GetProxy($Url).OriginalString, $true)
            $WebClient.Proxy.UseDefaultCredentials = $true
        }
        $ArchivePath = $(if ($env:OS -eq "Windows_NT") { "$env:TEMP\$([System.IO.Path]::GetFileName($Links.Item($Platform)))"} else { "$env:TEMP/$([System.IO.Path]::GetFileName($Links.Item($Platform)))" })
        Write-Verbose "Downloading package using URL '$Url'"
        $WebClient.DownloadFile($Url, $ArchivePath)
        switch ([System.IO.Path]::GetExtension($ArchivePath))
        {
            ".zip" {
                [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath,(Split-Path $CliPath)) # Expand-Archive $ArchivePath -Destination "$([NexusIQSettings]::SaveDir)"
            }
            ".pkg" {
                pkgutil --expand-full "$ArchivePath" "$(Split-Path $CliPath)"
            }
            ".jar" {
                Move-Item $ArchivePath -Destination $CliPath
            }
        }
        if ($PSVersionTable.PSVersion -lt 6) { [Net.ServicePointManager]::SecurityProtocol = $OrigSecurityProtocol }
    }
    else { Write-Verbose "The executable '$CliPath' was already downloaded" }
    if ($Platform -ne "Cross-Platform")
    {
        if (-not (Test-Path $CliPath)) { Write-Error "Something went wrong and the cli wasn't found"}
        else { Remove-Item $ArchivePath }
    }
    
    if ($PassThru) { $CliPath }
}
