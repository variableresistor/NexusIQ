[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param ()

BeforeAll {
    Import-Module (Split-Path $PSScriptRoot) -Scope Local
    $Separator = [System.IO.Path]::DirectorySeparatorChar
    $PublicId = "AppId"
    $IQApp = Get-NexusIQApplication -PublicId $PublicId
}

Describe "Get-NexusIQReport" {
    It "Returns JSON representing Nexus IQ report using pipeline input" {
        $Result = $IQApp | Get-NexusIQReport -Stage source
        $Result | Should -Not -BeNullOrEmpty
        $Result | Should -HaveCount 1
        $Result.stage | Should -Be "source"
        $Result.applicationId | Should -Not -BeNullOrEmpty
        $Result.applicationId.Length | Should -Be 32
        $Result.evaluationDate | Should -BeOfType datetime
        $Result.latestReportHtmlUrl | Should -BeLike "ui/links/application/$PublicId/latestReport/source"
        $Result.embeddableReportHtmlUrl | Should -BeLike "ui/links/application/$PublicId/report/*/embeddable"
        $Result.reportPdfUrl | Should -BeLike "ui/links/application/$PublicId/report/*/pdf"
        $Result.reportDataUrl | Should -BeLike "api/v2/applications/$PublicId/reports/*/raw"
    }
    It "Takes a value from pipeline by PublicId named parameter" {
        $Result = Get-NexusIQReport -Stage source -PublicId $PublicId
        $Result | Should -Not -BeNullOrEmpty
        $Result | Should -HaveCount 1
    }
    It "Takes a value from pipeline by Id named parameter" {
        $Result = Get-NexusIQReport -Stage source -Id $IQApp.id
        $Result | Should -Not -BeNullOrEmpty
        $Result | Should -HaveCount 1
    }
    It "Takes a value from pipeline by Name named parameter" {
        $Result = Get-NexusIQReport -Stage source -Name $IQApp.name
        $Result | Should -Not -BeNullOrEmpty
        $Result | Should -HaveCount 1
    }
}

Describe "Export-NexusIQReport" {
    It "Exports a PDF report" {
        Export-NexusIQReport -PublicId $PublicId -Stage build -ReportType PDF -OutFile "TestDrive:$Separator$PublicId.pdf"
        "TestDrive:$Separator$PublicId.pdf" | Should -Exist
    }
    It "Exports a raw JSON report" {
        Export-NexusIQReport -PublicId $PublicId -Stage build -ReportType RAW -OutFile "TestDrive:$Separator$PublicId.json"
        "TestDrive:$Separator$PublicId.json" | Should -Exist
    }
    It "Takes a value from pipeline by property name, default Id" {
        $IQApp | Export-NexusIQReport -Stage build -ReportType PDF -OutFile "TestDrive:$Separator$PublicId.pdf"
        "TestDrive:$Separator$PublicId.pdf" | Should -Exist
    }
    It "Exports a report using the Name named parameter" {
        Export-NexusIQReport -Name $IQApp.name -Stage build -ReportType PDF -OutFile "TestDrive:$Separator$PublicId.pdf"
        "TestDrive:$Separator$PublicId.pdf" | Should -Exist
    }
    It "Exports a report using Id named parameter" {
        Export-NexusIQReport -Id $IQApp.id -Stage build -ReportType PDF -OutFile "TestDrive:$Separator$PublicId.pdf"
        "TestDrive:$Separator$PublicId.pdf" | Should -Exist
    }
    It "Exports a report using PublicId named parameter" {
        Export-NexusIQReport -PublicId $IQApp.publicId -Stage build -ReportType PDF -OutFile "TestDrive:$Separator$PublicId.pdf"
        "TestDrive:$Separator$PublicId.pdf" | Should -Exist
    }
}
