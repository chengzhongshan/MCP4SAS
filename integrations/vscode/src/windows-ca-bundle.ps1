[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [string]$BaseBundle = ''
)

$ErrorActionPreference = 'Stop'
$parent = [System.IO.Path]::GetDirectoryName($OutputPath)
[System.IO.Directory]::CreateDirectory($parent) | Out-Null

$parts = [System.Collections.Generic.List[string]]::new()
if ($BaseBundle -and (Test-Path -LiteralPath $BaseBundle -PathType Leaf)) {
    $parts.Add([System.IO.File]::ReadAllText($BaseBundle))
}

$seen = @{}
$now = Get-Date
foreach ($store in 'Cert:\CurrentUser\Root', 'Cert:\LocalMachine\Root') {
    foreach ($cert in Get-ChildItem -Path $store -ErrorAction SilentlyContinue) {
        if ($cert.NotBefore -gt $now -or $cert.NotAfter -le $now -or $seen[$cert.Thumbprint]) {
            continue
        }
        $seen[$cert.Thumbprint] = $true
        $bytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
        $body = [Convert]::ToBase64String($bytes, [Base64FormattingOptions]::InsertLineBreaks)
        $parts.Add("-----BEGIN CERTIFICATE-----`r`n$body`r`n-----END CERTIFICATE-----`r`n")
    }
}

if ($seen.Count -eq 0) {
    throw 'Windows Trusted Root Certification Authorities stores contain no currently valid certificates.'
}

$temporary = "$OutputPath.$PID.tmp"
[System.IO.File]::WriteAllText($temporary, ($parts -join "`r`n"), [System.Text.Encoding]::ASCII)
Move-Item -LiteralPath $temporary -Destination $OutputPath -Force
