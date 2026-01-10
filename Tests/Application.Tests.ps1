[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param ()
BeforeAll {
    Import-Module (Split-Path $PSScriptRoot) -Scope Local
}

BeforeDiscovery {
    $AppId1 = "MyAppId"
    $AppName = "My Wonderful App"
    $TempAppId = "MyAppTempId"
    $TempAppName = "Applications.Tests.ps1"
    $OrganizationName1 = "Org1"
    $OrganizationName2 = "Org2"
}

Describe "Get-NexusIQApplication" {
    Context "App Id parameter" {
        It "Returns the specified application by PublicId using a named parameter" {
            $Result = Get-NexusIQApplication -PublicId $AppId1
            $Result | Should -Not -BeNullOrEmpty
            $Result | Should -HaveCount 1
            $Result.publicId | Should -Be $AppId1
        }
        It "Returns the specified applications by multiple PublicIds" {
            $AppId2 = "$OrganizationName1`_data-collection"
            $Result = Get-NexusIQApplication -PublicId $AppId1,$AppId2 | Sort-Object -Property name
            $Result | Should -Not -BeNullOrEmpty
            $Result | Should -HaveCount 2
            $Result[0].publicId | Should -Be $AppId1
            $Result[1].publicId | Should -Be $AppId2
        }
    }

    Context "Name parameter" {
        It "Returns the specified application by app name" {
            $Result = Get-NexusIQApplication -Name $AppName
            $Result | Should -Not -BeNullOrEmpty
            $Result | Should -HaveCount 1
            $Result.publicId | Should -Be $AppId1
            $Result.name | Should -Be $AppName
        }
        It "Returns the specified application by wildcard" {
            $Result = Get-NexusIQApplication -Name "*$AppName"
            $Result | Should -Not -BeNullOrEmpty
            $Result | Should -HaveCount 1
            $Result.publicId | Should -Be $AppId1
        }
        It "Returns multiple applications by specifying 2 app names" {
            $Result = Get-NexusIQApplication -Name "*$AppName"
            $Result | Should -Not -BeNullOrEmpty
            $Result | Should -HaveCount 1
            $Result.publicId | Should -Be $AppId1
        }
    }
}

Describe "Find-NexusIQApplication" {
    It "Finds an application using the PublicId parameter" {
        $Result = Find-NexusIQApplication -PublicId $AppId1
        $Result | Should -Not -BeNullOrEmpty
        $Result | Should -HaveCount 1
        $Result.publicId | Should -Be $AppId1
    }
    It "Finds an application using the Name parameter" {
        $Result = Find-NexusIQApplication -Name $AppName
        $Result | Should -Not -BeNullOrEmpty
        $Result | Should -HaveCount 1
        $Result.name | Should -Be $AppName
    }
    It "Finds an application using the OrganizationName parameter" {
        $Result = Find-NexusIQApplication -OrganizationName $OrganizationName1
        $Result | Should -Not -BeNullOrEmpty
        $Organization = Get-NexusIQOrganization -Name $OrganizationName1
        $Result[0].organizationId | Should -Be $Organization.id
    }
}

Describe "New-NexusIQApplication" {
    It "Retrieves the organization, then calls the API" {
        $Result = New-NexusIQApplication -ApplicationId $TempAppId -Name $TempAppName -OrganizationName $OrganizationName1
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
    BeforeEach {
        $ReferenceApp = New-NexusIQApplication -PublicId $TempAppId -Name $TempAppName -OrganizationName $OrganizationName1
    }
    It "Deletes and application passing the named PublicId parameter" {
        Remove-NexusIQApplication -PublicId $TempAppId
        Get-NexusIQApplication -PublicId $TempAppId -ErrorAction Ignore | Should -BeNullOrEmpty
    }
    It "Deletes and application passing the named Name parameter" {
        Remove-NexusIQApplication -Name $TempAppName
        Get-NexusIQApplication -PublicId $TempAppId -ErrorAction Ignore | Should -BeNullOrEmpty
    }
    It "Deletes and application passing the named Id parameter" {
        Remove-NexusIQApplication -Id $ReferenceApp.id
        Get-NexusIQApplication -PublicId $TempAppId -ErrorAction Ignore | Should -BeNullOrEmpty
    }
    It "Takes a value from the pipeline" {
        $ReferenceApp | Remove-NexusIQApplication
        Get-NexusIQApplication -PublicId $TempAppId -ErrorAction Ignore | Should -BeNullOrEmpty
    }
    AfterEach {
        Get-NexusIQApplication -PublicId $TempAppId -ErrorAction Ignore | Remove-NexusIQApplication
    }
}

Describe "Set-NexusIQApplication" {
    BeforeEach {
        $ReferenceApp = New-NexusIQApplication -PublicId $TempAppId -Name $TempAppName -OrganizationName $OrganizationName1
    }
    It "Sets name property of an application using pipeline input" {
        $ChangedApp = $ReferenceApp | Set-NexusIQApplication -NewName "$TempAppName-1" -PassThru
        $ChangedApp.publicId | Should -Be $TempAppId
        $ChangedApp.name | Should -Be "$TempAppName-1"
    }
    It "Sets publicId of an application using the named PublicId parameter" {
        $ChangedApp = Set-NexusIQApplication -PublicId $TempAppId -NewPublicId "$TempAppId-1" -PassThru
        $ChangedApp | Should -Not -BeNullOrEmpty
        $ChangedApp.publicId | Should -Be "$TempAppId-1"
        $ChangedApp.name | Should -Be $TempAppName
    }
    AfterEach {
        Get-NexusIQApplication -PublicId $TempAppId,"$TempAppId-1" -ErrorAction Ignore | ForEach-Object -Process {
            $_ | Remove-NexusIQApplication
        }
    }
}

Describe "Rename-NexusIQApplication" {
    BeforeEach {
        $ReferenceApp = New-NexusIQApplication -PublicId $TempAppId -Name $TempAppName -OrganizationName $OrganizationName1
    }
    It "Renames the application to Rename-Application using the pipeline" {
        $RenamedApp = $ReferenceApp |
        Rename-NexusIQApplication -NewPublicId "Rename-ApplicationPublicId" -NewName "Rename-ApplicationNewName" -PassThru
        $RenamedApp.name | Should -Be "Rename-ApplicationNewName"
        $RenamedApp.publicId | Should -Be "Rename-ApplicationPublicId"
    }
    It "Renames the application to Rename-Application using the PublicId named parameter" {
        $RenamedApp = Rename-NexusIQApplication -PublicId $TempAppId -NewPublicId "Rename-ApplicationPublicId" -PassThru
        $RenamedApp.publicId | Should -Be "Rename-ApplicationPublicId"
        $RenamedApp.name | Should -Be $TempAppName
    }
    It "Renames the application to Rename-Application using the Name named parameter" {
        $RenamedApp = Rename-NexusIQApplication -Name $TempAppName -NewName "Rename-ApplicationNewName" -PassThru
        $RenamedApp.name | Should -Be "Rename-ApplicationNewName"
        $RenamedApp.publicId | Should -Be $TempAppId
    }
    AfterEach {
        Get-NexusIQApplication -PublicId $TempAppId,"Rename-ApplicationPublicId" -ErrorAction Ignore | ForEach-Object -Process {
            $_ | Remove-NexusIQApplication
        }
    }
}

Describe "Move-NexusIQApplicationOrganization" {
    BeforeEach {
        $ReferenceApp = New-NexusIQApplication -PublicId $TempAppId -Name $TempAppName -OrganizationName $OrganizationName1
        $NewOrg = Get-NexusIQOrganization -Name $OrganizationName1
    }
    It "Moves an application's organization from $OrganizationName1 to $OrganizationName2" {
        $ReferenceApp | Move-NexusIQApplicationOrganization -OrganizationName $OrganizationName2
        $Result = $ReferenceApp | Get-NexusIQApplication
        $Result.organizationId | Should -Be $NewOrg.id
    }
    It "Moves an application's organization from $OrganizationName1 to $OrganizationName2 using the Name named parameter" {
        $Result = Move-NexusIQApplicationOrganization -OrganizationName $OrganizationName2 -Name $TempAppName -PassThru
        $Result.Count | Should -Not -BeNullOrEmpty -Because "We passed the PassThru parameter"
        $Result.Count | Should -Be 1
        $Result.organizationId | Should -Be $NewOrg.id
    }
    It "Moves an application's organization from $OrganizationName1 to $OrganizationName2 using the PublicId named parameter" {
        $Result = Move-NexusIQApplicationOrganization -OrganizationName $OrganizationName2 -PublicId $TempAppId -PassThru
        $Result.Count | Should -Not -BeNullOrEmpty -Because "We passed the PassThru parameter"
        $Result.Count | Should -Be 1
        $Result.organizationId | Should -Be $NewOrg.id
    }
    It "Moves an application's organization from $OrganizationName1 to $OrganizationName2 using the Id named parameter" {
        $Result = Move-NexusIQApplicationOrganization -OrganizationName $OrganizationName2 -Id $ReferenceApp.id -PassThru
        $Result.Count | Should -Not -BeNullOrEmpty -Because "We passed the PassThru parameter"
        $Result.Count | Should -Be 1
        $Result.organizationId | Should -Be $NewOrg.id
    }
    AfterEach {
        $ReferenceApp | Remove-NexusIQApplication
    }
}
