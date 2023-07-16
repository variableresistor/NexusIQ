# Nexus IQ PowerShell Module
PowerShell module to interact with the Nexus IQ REST API. Essentially a wrapper for built-in Nexus IQ REST API functionality. Documentation for the REST API can be found [here](https://help.sonatype.com/iqserver/automating/rest-apis). Thanks to [Atlassian.BitBucket](https://github.com/beyondcomputing-org/Atlassian.Bitbucket) for code samples.

## Installation
Run the following command in PowerShell session to install the module from the PowerShell Gallery. If following the instructions above, the below command should not require elevation.

```powershell
Install-Module -Name NexusIQ -Scope CurrentUser
```

## Authentication
The module provides machine / user encrypted persistance between sessions. Instructions on generating your API token here: [User Token REST API - v2](https://help.sonatype.com/iqserver/automating/rest-apis/user-token-rest-api---v2) and run
```powershell
Connect-NexusIQ -BaseUrl https://nexusiq.mycompany.com
```

Alternatively, generate the token through the web UI by logging in with a username and password (not SSO), then select "Manage User Token".

## Update
If you already have the module installed, run the following command to update the module from the PowerShell Gallery to the latest version.

```powershell
Update-Module -Name NexusIQ
```

## Developing
It's not really fleshed out yet, but a few things that need to be done to develop locally:
* Change the parameters in all the Pester test files to some arbitrary values
* Import the .\Base.psm1 before trying to troubleshoot your contribution. This is so the module files can be
organized neatly into separate files.
* Use Connect-NexusIQ to point to your local Nexus IQ instance

It also requires Pester v5 or higher:
```powershell
Install-Module -Name Pester -MinimumVersion 5.3 -Scope CurrentUser
```

I'd also recommend changing your Visual Studio Code settings to  move the secondard sidebar to the left. and these settings if you're used to PowerShell ISE:

```json
{
    "powershell.codeFormatting.openBraceOnSameLine": false,
    "terminal.integrated.cursorBlinking": true,
    "terminal.integrated.cursorStyle": "line",
    "powershell.pester.useLegacyCodeLens": false, // Pester v5
    "powershell.sideBar.CommandExplorerVisibility": false, // If the command explorer is annoying
    "editor.tokenColorCustomizations": {
        "[PowerShell ISE]": {
            "comments": "#006400",
            "types": "#006161",
            "strings": "#8b0000",
            "variables": "#FF4500",
            "keywords": "#00008b",
            "functions": "#0000FF",
            "numbers": "#800080",
            "textMateRules": [
                {
                    "scope": ["variable.parameter","meta.scriptblock.powershell","meta.group.simple.subexpression.powershell"],
                    "settings": {
                        "foreground": "#000080"
                    }
                },
                {
                    "scope": ["keyword.operator"],
                    "settings": {
                        "foreground": "#696969"
                    }
                },
                {
                    "scope": "support.function.attribute.powershell",
                    "settings": {
                        "foreground": "#00BFFF"
                    }
                },
                {
                    "scope": ["variable.other.member.powershell","variable.parameter.attribute.powershell","interpolated.complex.source.powershell"],
                    "settings": {
                        "foreground": "#000000"
                    }
                },
                {
                    "scope": "meta.function.powershell",
                    "settings": {
                        "foreground": "#00008B"
                    }
                },
                {
                    "scope": ["storage.modifier.scope.powershell","constant.language","support.constant.variable.powershell","variable.language.powershell"],
                    "settings": {
                        "foreground": "#FF4500"
                    }
                },
                {
                    "scope": "storage.type.powershell",
                    "settings": {
                        "foreground": "#006161"
                    }
                },
                {
                    "scope": ["comment"],
                    "settings": {
                        "fontStyle": ""
                    }
                },
                {
                    "scope": "keyword.control.requires.powershell",
                    "settings": {
                        "foreground": "#006400",
                        "fontStyle": "italic"
                    }
                }
            ]
        }
    },

    // Other
    "files.associations": {
        "*.yml": "azure-pipelines"
    }
}

```

Then add this to your Visual Studio Code's PowerShell Profile:

```powershell
$Host.PrivateData.VerboseForegroundColor = "Cyan"
$Host.PrivateData.WarningForegroundColor = "DarkYellow"
```
