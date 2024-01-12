[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param ()

BeforeAll {
    Import-Module (Split-Path $PSScriptRoot) -Scope Local
    $Separator = [System.IO.Path]::DirectorySeparatorChar
    $SaveDir = "$env:APPDATA$Separator`NexusIQ"
    $AuthXmlPath = "$SaveDir$Separator`Auth.xml"

    [uri]$BaseUrl = "https://nexusiq.myorg.com"

    if (-not (Test-Path -Path $AuthXmlPath))
    {
        Write-Error "You need to log into the application using Connect-NexusIq before continuing"
    }
    $Settings = Import-Clixml -Path $AuthXmlPath
}

Describe "Connect-NexusIQ or Save-NexusIQLogin" {
    BeforeEach {
        if (Test-Path $AuthXmlPath) { Remove-Item $SaveDir -Recurse }
    }
    It "Saves their profile info" {
        $Result = Connect-NexusIQ -Credential $Settings.Credential -BaseUrl $Settings.BaseUrl -APIVersion $Settings.APIVersion
        $AuthXmlPath | Should -Exist
        $Result.Credential | Should -Not -BeNullOrEmpty
        $Result.Credential.UserName | Should -Be $Settings.Credential.UserName
        $Result.APIVersion | Should -Be $Settings.APIVersion
        $Result | Should -HaveCount 1
    }
    It "Saves their profile info by passing a credential from the pipeline" {
        $Result = $Settings | Connect-NexusIQ -BaseUrl $Settings.BaseUrl -APIVersion $Settings.APIVersion
        $AuthXmlPath | Should -Exist
        $Result.Credential | Should -Not -BeNullOrEmpty
        $Result.Credential.UserName | Should -Be $Settings.Credential.UserName
        $Result.APIVersion | Should -Be $Settings.APIVersion
    }

    AfterEach {
        if (-not (Test-Path $SaveDir))
        {
            New-Item -Path $SaveDir -ItemType Directory | Out-Null
        }
        $Settings | Export-Clixml -Path $AuthXmlPath
    }
}

Describe "Disconnect-NexusIQ or Remove-NexusIQLogin" {
    It "Removes their login information from disk" {
        Disconnect-NexusIQ
        $AuthXmlPath | Should -Not -Exist
    }
    It "Doesn't blow up if the profile doesn't exist" {
        if (Test-Path $SaveDir) { Remove-Item $SaveDir -Recurse }
        { Disconnect-NexusIQ -WarningAction SilentlyContinue } | Should -Not -Throw
    }

    AfterEach {
        if (-not (Test-Path $SaveDir))
        {
            New-Item -Path $SaveDir -ItemType Directory | Out-Null
        }
        $Settings | Export-Clixml -Path $AuthXmlPath
    }
}

Describe "Get-NexusIQSettings" {
    It "Returns their profile info" {
        $Settings | Should -Not -BeNullOrEmpty
        $Settings.APIVersion.ToString() | Should -Be "v2"
        $Settings.BaseUrl | Should -Be $BaseUrl
        $Settings.Credential | Should -BeOfType PSCredential
    }
}
