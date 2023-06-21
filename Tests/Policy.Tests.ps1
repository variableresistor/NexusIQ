[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param ()

BeforeAll {
    Import-Module "$(Split-Path $PSScriptRoot)$([System.IO.Path]::DirectorySeparatorChar)NexusIQ.psd1"
    $AppName = "MyAppId"
    $OrganizationName = "Org1"
}

Describe "Get-NexusIQPolicy" {
    It "Retrieves all policies" {
        $AllPolicies = Get-NexusIQPolicy
        $AllPolicies | Should -Not -BeNullOrEmpty
        "ORGANIZATION" | Should -BeIn $AllPolicies.ownerType -Because "It retrieves organization policies"
        "APPLICATION" | Should -BeIn $AllPolicies.ownerType -Because "It retrieves application policies"
        "ROOT_ORGANIZATION_ID" | Should -BeIn $AllPolicies.ownerId -Because "It retrieves policies configured at the root"
    }
    It "Retrieves policies by Organization name" {
        $Organization = Get-NexusIQOrganization -Name $OrganizationName
        $Policies = Get-NexusIQPolicy -Type Organization -Name $Organization.name
        "ORGANIZATION" | Should -BeIn $Policies.ownerType -Because "It returns at least 1 organization policy"
        "APPLICATION" | Should -Not -BeIn $Policies.ownerType -Because "It filters out inherited application policies"
        "ROOT_ORGANIZATION_ID" | Should -Not -BeIn $Policies.ownerId -Because "It filters out inherited root policies"
        $Policies[0].ownerId | Should -Be $Organization.id
    }
    It "Retrieves policies by Application name" {
        $Application = Get-NexusIQApplication -Name $AppName
        $Policies = Get-NexusIQPolicy -Type Application -Name $AppName
        "ORGANIZATION" | Should -Not -BeIn $Policies.ownerType -Because "It filters out inherited organization policies"
        "APPLICATION" | Should -BeIn $Policies.ownerType -Because "It returns at least 1 application policy"
        "ROOT_ORGANIZATION_ID" | Should -Not -BeIn $Policies.ownerId -Because "It filters out inherited root policies"
    }
}
