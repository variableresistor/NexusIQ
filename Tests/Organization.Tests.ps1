[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param (
    [ValidateNotNullOrEmpty()]
    [guid]$OrgId = (New-Guid),

    [ValidateNotNullOrEmpty()]
    [string]$OrganizationName = "MyOrg"
)
BeforeAll {
    Import-Module "$(Split-Path $PSScriptRoot)\NexusIQ.psd1"
}

Describe "Get-NexusIQOrganization" {
    It "Returns a valid organization from the API by organization name" {
        $Org = Get-NexusIQOrganization -Name $OrganizationName
        $Org | Should -Not -BeNullOrEmpty
        $Org.id | Should -Not -BeNullOrEmpty
        $Org.id.Length | Should -Be 32
        $Org.name | Should -Be $OrganizationName
    }
    It "Returns a valid organization from the API by organization id" {
        $Org = Get-NexusIQOrganization -Name $OrganizationName
        $ResultOrg = Get-NexusIQOrganization -Id $Org.id
        $ResultOrg | Should -Not -BeNullOrEmpty
        $ResultOrg.id | Should -Not -BeNullOrEmpty
        $ResultOrg.id.Length | Should -Be 32
        $ResultOrg.name | Should -Be $OrganizationName
    }
    It "Can handle objects from the pipeline" {
        $Org = Get-NexusIQOrganization -Name $OrganizationName | Get-NexusIQOrganization
        $Org | Should -Not -BeNullOrEmpty
        $Org.id | Should -Not -BeNullOrEmpty
        $Org.id.Length | Should -Be 32
        $Org.name | Should -Be $OrganizationName
    }
}
