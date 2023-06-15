[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param (
    [ValidateNotNullOrEmpty()]
    [string]$AppName = "MyAppId",

    [ValidateNotNullOrEmpty()]
    [string]$OrganizationName = "Org1"
)
BeforeAll {
    Import-Module "$(Split-Path $PSScriptRoot)\NexusIQ.psd1"
}

Describe "Get-NexusIQPolicy" {
    It "Retrieves all policies" {
        $AllPolicies = Get-NexusIQPolicy
        $AllPolicies | Where-Object -Property ownerType -EQ "ORGANIZATION" | Should -Not -BeNullOrEmpty -Because "It retrieves organization policies"
        $AllPolicies | Where-Object -Property ownerType -EQ "APPLICATION" | Should -Not -BeNullOrEmpty -Because "It retrieves application policies"
        $AllPolicies | Where-Object -Property ownerType -EQ "ROOT_ORGANIZATION_ID" | Should -Not -BeNullOrEmpty -Because "It retrieves policies configured at the root"
    }
    It "Retrieves policies by Organization name" {
        $Organization = Get-NexusIQOrganization -Name $OrgName
        $Policies = Get-NexusIQPolicy -OrganizationName $Organization.name
        $Policies | Where-Object -Property ownerType -EQ "ORGANIZATION" | Should -Not -BeNullOrEmpty -Because "It returns at least 1 organization policy"
        $Policies | Where-Object -Property ownerType -EQ "APPLICATION" |-BeNullOrEmpty -Because "It filters out inherited application policies"
        $Policies | Where-Object -Property ownerType -EQ "ROOT_ORGANIZATION_ID" | Should -BeNullOrEmpty -Because "It filters out inherited root policies"
        $Policies[0].id | Should -Be $Organization.id
        $Organization.id | Should -BeIn $Policies.id
    }
    It "Retrieves policies by Application name" {
        $Application = Get-NexusIQApplication -Name $AppName
        $Policies = Get-NexusIQPolicy -ApplicationName $AppName
        $Policies | Where-Object -Property ownerType -EQ "ORGANIZATION" | Should -BeNullOrEmpty -Because "It filters out inherited organization policies"
        $Policies | Where-Object -Property ownerType -EQ "APPLICATION" | Should -Not -BeNullOrEmpty -Because "It returns at least 1 application policy"
        $Policies | Where-Object -Property ownerType -EQ "ROOT_ORGANIZATION_ID" | Should -BeNullOrEmpty -Because "It filters out inherited root policies"
    }
}
