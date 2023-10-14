[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
    Justification='Suppress false positives in Pester code blocks')]
param ()

BeforeAll {
    Import-Module (Split-Path $PSScriptRoot) -Scope Local
}

Describe "Save-NexusIQCli" {
    BeforeAll {
        $CliName = @{
            Windows = "nexus-iq-cli.exe"
            Linux   = "nexus-iq-cli"
            Mac     = "nexus-iq-cli"
        }
        $Platform = "Windows"
        $SaveDir = "$env:APPDATA$([System.IO.Path]::DirectorySeparatorChar)NexusIQ"
        $CliPath = "$SaveDir$([System.IO.Path]::DirectorySeparatorChar)$($CliName.Item($Platform))"

        if (Test-Path $CliPath) { Remove-Item $CliPath }
    }

    It "Extracts the file to the AppData directory" {
        $Result = Save-NexusIQCli -Platform $Platform -PassThru
        $CliPath | Should -Exist
        $Result | Should -Not -BeNullOrEmpty
    }
}
