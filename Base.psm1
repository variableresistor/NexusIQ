"Import Microsoft.PowerShell.Commands.WebRequestMethod" | Out-Null

filter Invoke-NexusIQAPI
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Path,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = "Get",
        # Use the api or rest extension
        [ValidateSet("api","rest","ui")]
        [string]$RequestType = "api",
        [Hashtable]$Parameters,
        $Body,
        [string]$ContentType,
        # Optionally where to output the result
        [string]$OutFile
    )
    $Settings = Get-NexusIQSettings
    $StringBuilder = [System.Text.StringBuilder]::new("$($Settings.BaseUrl)$RequestType")
    if ($RequestType -eq "api") { $StringBuilder.Append("/$($Settings.APIVersion.ToString())") | Out-Null }
    $StringBuilder.Append("/$Path") | Out-Null

    if ($Parameters)
    {
        $Separator = "?"
        $Parameters.Keys | ForEach-Object {
            $StringBuilder.Append(("{0}{1}={2}" -f $Separator,$_,[System.Web.HttpUtility]::UrlEncode($Parameters."$_".ToString()))) | Out-Null
            $Separator = "&"
        }
    }
    $Uri = $StringBuilder.ToString()
    Write-Verbose "Invoking Url $Uri"

    $Splat = @{
        Uri=$Uri
        Method=$Method
    }
    if ($PSEdition -eq "Core")
    {
        $Splat.Add("NoProxy",([switch]::Present))
        $Splat.Add("Authentication","Basic")
        $Splat.Add("Credential",$Settings.Credential)
    }
    else
    {
        $Pair = "$($Settings.Username):$($Settings.Credential.GetNetworkCredential().Password)"
        $EncodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Pair))
        $Headers = @{ Authorization = "Basic $EncodedCreds" }
        $Splat.Add("Headers",$Headers)
    }

    if ($ContentType) { $Splat.Add("ContentType",$ContentType) }
    # Either output to a file or save the response to the "Response" variable
    if ($PSBoundParameters.ContainsKey("Outfile")) { ($Splat.Add("OutFile",$OutFile) ) }
    else  { $Splat.Add("OutVariable","Response") }
    if ($Body) { $Splat.Add("Body",$Body) }

    Invoke-RestMethod @Splat | Out-Null
    if ($Response)
    {
        Write-Verbose "Unravel the response so it outputs each item to the pipeline instead of all at once"
        for ([UInt16]$i = 0; $i -lt $Response.Count; $i++) { $Response[$i] }
    }
}

class NexusIQSettings
{
    static [String]$SaveDir = "$env:APPDATA$([System.IO.Path]::DirectorySeparatorChar)NexusIQ"
    static [String]$SavePath = "$([NexusIQSettings]::SaveDir)$([System.IO.Path]::DirectorySeparatorChar)Auth.xml"

    # Parameters
    [String]$BaseUrl
    [PSCredential]$Credential
    [NexusIQAPIVersion]$APIVersion

    NexusIQSettings([PSCredential]$Credential,[uri]$BaseUrl,[NexusIQAPIVersion]$APIVersion)
    {
        $this.BaseUrl = $BaseUrl
        $this.Credential = $Credential
        $this.APIVersion = $APIVersion
    }
}

enum NexusIQAPIVersion
{
    v1
    v2
}
