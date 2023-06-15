[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param ()
BeforeAll {
    Import-Module "$(Split-Path $PSScriptRoot)\NexusIQ.Scan.psm1"
}

Describe "Save-NexusIQCli" {
    BeforeAll {
        $CliName = @{
            Windows = "nexus-iq-cli.exe"
            Linux   = "nexus-iq-cli"
            Mac     = "nexus-iq-cli"
        }
        $Platform = "Windows"
        $SaveDir = $(if ($env:OS -eq "Windows_NT") { "$env:APPDATA\PoshNexusIQ" } else { "$env:APPDATA/PoshNexusIQ" })
        $CliPath = $(if ($env:OS -eq "Window_NT") { "$SaveDir\$($CliName.Item($Platform))" } else { "$SaveDir/$($CliName.Item($Platform))"})

        if (Test-Path $CliPath) { Remove-Item $CliPath }
    }

    It "Extracts the file to the AppData directory" {
        $Result = Save-NexusIQCli -Platform $Platform -PassThru
        $CliPath | Should -Exist
        $Result | Should -Not -BeNullOrEmpty
    }
}
