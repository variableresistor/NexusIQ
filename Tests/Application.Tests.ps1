[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param ()

BeforeAll {
    Import-Module (Split-Path $PSScriptRoot) -Force
    $AppId = "MyAppId"
    $AppName = "My Wonderful app"
    $TempAppId = "MyAppTempId"
    $TempAppName = "My temporary app"
    $AppId2 = "MyApp2"
    $AppName2 = "My 2nd wonderful app"
    $OrganizationName = "Org1"
}

Describe "Get-NexusIQApplication" {
    Context "App Id parameter" {
        It "Returns the specified application by app id using a named parameter" {
            $Result = Get-NexusIQApplication -ApplicationId $AppId
            $Result | Should -Not -BeNullOrEmpty
            $Result | Should -HaveCount 1
            $Result.publicId | Should -Be $AppId
        }
        It "Returns the specified application by app id using the pipeline" {
            $Result = $AppId | Get-NexusIQApplication
            $Result | Should -Not -BeNullOrEmpty
            $Result | Should -HaveCount 1
            $Result.publicId | Should -Be $AppId
        }
        It "Returns the specified applications by multiple app ids using the pipeline" {
            $Result = $AppId,$AppId2 | Get-NexusIQApplication | Sort-Object -Property name
            $Result | Should -Not -BeNullOrEmpty
            $Result | Should -HaveCount 2
            $Result[0].publicId | Should -Be $AppId
            $Result[1].publicId | Should -Be $AppId2
        }
    }

    Context "Name parameter" {
        It "Returns the specified application by app name" {
            $Result = Get-NexusIQApplication -Name $AppName
            $Result | Should -Not -BeNullOrEmpty
            $Result | Should -HaveCount 1
            $Result.publicId | Should -Be $AppId
            $Result.name | Should -Be $AppName
        }
        It "Returns the specified application by wildcard" {
            $Result = Get-NexusIQApplication -Name "*$AppName"
            $Result | Should -Not -BeNullOrEmpty
            $Result | Should -HaveCount 1
            $Result.publicId | Should -Be $AppId
        }
    }
}

Describe "New-NexusIQApplication" {
    BeforeAll {
        $Result = New-NexusIQApplication -ApplicationId $TempAppId -Name $TempAppName -OrganizationName CNRWM
    }
    It "Retrieves the organization, then calls the API" {
        $Result | Should -Not -BeNullOrEmpty
        $Result | Should -HaveCount 1
        $Result.publicId | Should -Be $TempAppId
        $Result.name | Should -Be $TempAppName

    }
    AfterAll {
        Remove-NexusIQApplication -ApplicationId $TempAppId
    }
}

Describe "Remove-NexusIQApplication" {
    It "Retrieves the organization, then calls the API" {
        $Result = New-NexusIQApplication -ApplicationId $TempAppId -Name $TempAppName -OrganizationName $OrganizationName
        Remove-NexusIQApplication -ApplicationId $TempAppId
        Get-NexusIQApplication -ApplicationId $TempAppId -ErrorAction Ignore | Should -BeNullOrEmpty
    }
    It "Takes a value from the pipeline" {
        New-NexusIQApplication -ApplicationId $TempAppId -Name $TempAppName -OrganizationName $OrganizationName |
        Remove-NexusIQApplication
        Get-NexusIQApplication -ApplicationId $TempAppId -ErrorAction Ignore | Should -BeNullOrEmpty
    }
}
