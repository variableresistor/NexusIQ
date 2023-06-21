[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param ()

BeforeAll {
    Import-Module "$(Split-Path $PSScriptRoot)$([System.IO.Path]::DirectorySeparatorChar)NexusIQ.psd1"
    $AppId = "MyAppId"
}

Describe "Get-NexusIQReport" {
    It "Returns JSON representing Nexus IQ report" {
        $Result = Get-NexusIQReport -ApplicationId $AppId -Stage source
        $Result | Should -Not -BeNullOrEmpty
        $Result | Should -HaveCount 1
        $Result.stage | Should -Be "source"
        $Result.applicationId | Should -Not -BeNullOrEmpty
        $Result.applicationId.Length | Should -Be 32
        $Result.evaluationDate | Should -BeOfType datetime
        $Result.latestReportHtmlUrl | Should -BeLike "ui/links/application/$AppId/latestReport/source"
        $Result.embeddableReportHtmlUrl | Should -BeLike "ui/links/application/$AppId/report/*/embeddable"
        $Result.reportPdfUrl | Should -BeLike "ui/links/application/$AppId/report/*/pdf"
        $Result.reportDataUrl | Should -BeLike "api/v2/applications/$AppId/reports/*/raw"
    }
    It "Takes a value from pipeline by property name" {
        $Result = Get-NexusIQApplication -ApplicationId $AppId | Get-NexusIQReport -Stage source
        $Result | Should -Not -BeNullOrEmpty
        $Result | Should -HaveCount 1
    }
}

Describe "Export-NexusIQReport" {
    It "Exports a PDF report" {
        Export-NexusIQReport -ApplicationId $AppId -Stage build -ReportType PDF -OutFile "TestDrive:\$AppId.pdf"
        "TestDrive:\$AppId.pdf" | Should -Exist
    }
    It "Exports a raw JSON report" {
        Export-NexusIQReport -ApplicationId $AppId -Stage build -ReportType RAW -OutFile "TestDrive:\$AppId.json"
        "TestDrive:\$AppId.json" | Should -Exist
    }
    It "Takes a value from pipeline by property name" {
        Get-NexusIQApplication -ApplicationId $AppId | Export-NexusIQReport -Stage build -ReportType PDF -OutFile "TestDrive:\$AppId.pdf"
        "TestDrive:\$AppId.pdf" | Should -Exist
    }
}
