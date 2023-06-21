[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param ()

BeforeAll {
    Import-Module "$(Split-Path $PSScriptRoot)$([System.IO.Path]::DirectorySeparatorChar)NexusIQ.psd1"
    $BaseUrl = "https://nexusiq.myorg.com"

    if (-not (Test-Path -Path "$env:USERPROFILE$([System.IO.Path]::DirectorySeparatorChar).PoshNexusIQ$([System.IO.Path]::DirectorySeparatorChar)Auth.xml"))
    {
        Save-NexusIQLogin -BaseUrl $BaseUrl -APIVersion v2 | Out-Null
    }
}

Describe "Save-NexusIQLogin" {
    BeforeEach {
        $Script:Settings = Import-Clixml -Path "$env:USERPROFILE$([System.IO.Path]::DirectorySeparatorChar).PoshNexusIQ$([System.IO.Path]::DirectorySeparatorChar)Auth.xml"
        Remove-Item "$env:USERPROFILE\.PoshNexusIQ" -Recurse
    }
    It "Saves their profile info" {
        $Result = Save-NexusIQLogin -Credential $Settings.Credential -BaseUrl $Settings.BaseUrl -APIVersion $Settings.APIVersion
        "$env:USERPROFILE$([System.IO.Path]::DirectorySeparatorChar).PoshNexusIQ$([System.IO.Path]::DirectorySeparatorChar)Auth.xml" | Should -Exist
        $Result.Credential | Should -Not -BeNullOrEmpty
        $Result.Credential.UserName | Should -Be $Settings.Credential.UserName
        $Result.APIVersion | Should -Be $Settings.APIVersion
    }
    AfterEach {
        if (-not (Test-Path "$env:USERPROFILE\.PoshNexusIQ"))
        {
            New-Item -Path "$env:USERPROFILE\.PoshNexusIQ" -ItemType Directory | Out-Null
        }
        $Script:Settings | Export-Clixml -Path "$env:USERPROFILE$([System.IO.Path]::DirectorySeparatorChar).PoshNexusIQ\Auth.xml" -Force
    }
}

Describe "Get-NexusIQSettings" {
    BeforeAll {
        $Script:Settings = Get-NexusIQSettings
    }
    It "Returns their profile info" {
        $Settings | Should -Not -BeNullOrEmpty
        $Settings.APIVersion | Should -Be "v2"
        $Settings.BaseUrl | Should -Be $BaseUrl
        $Settings.Credential | Should -BeOfType PSCredential
    }
}
