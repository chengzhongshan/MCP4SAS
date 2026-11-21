param([Parameter(Mandatory=$true)][string]$TargetDirectory)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
# A full CPython installer is required: the embeddable ZIP has no venv/pip.
# Source: https://www.python.org/downloads/release/python-31317/
$pythonVersion = '3.13.17'
$pythonHash = '5da012101ba2e17113a9a1cd901e9ce1441086f2b7ecb5de06ec94163899a190'
if ($TargetDirectory -match '["\r\n]') { throw 'Invalid Python installation directory.' }
$pythonTarget = [System.IO.Path]::GetFullPath($TargetDirectory)
$pythonDownload = Join-Path ([System.IO.Path]::GetTempPath()) ('mcp4sas-python-' + [guid]::NewGuid().ToString() + '.exe')
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -UseBasicParsing -Uri "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-amd64.exe" -OutFile $pythonDownload
    if ((Get-FileHash -LiteralPath $pythonDownload -Algorithm SHA256).Hash -ne $pythonHash) { throw 'Python installer checksum mismatch; installer was not run.' }
    $pythonSignature = Get-AuthenticodeSignature -LiteralPath $pythonDownload
    if ($pythonSignature.Status -ne 'Valid' -or $pythonSignature.SignerCertificate.Subject -notmatch 'O=Python Software Foundation(?:,|$)') { throw 'Python installer signature verification failed; installer was not run.' }
    $pythonArguments = '/quiet InstallAllUsers=0 PrependPath=0 Include_launcher=0 Include_test=0 Include_pip=1 TargetDir="' + $pythonTarget + '"'
    $pythonProcess = Start-Process -FilePath $pythonDownload -ArgumentList $pythonArguments -WindowStyle Hidden -Wait -PassThru
    if ($pythonProcess.ExitCode -notin @(0,3010)) { throw "Python installer failed with exit code $($pythonProcess.ExitCode)." }
    if (-not (Test-Path -LiteralPath (Join-Path $pythonTarget 'python.exe'))) { throw 'Python installer completed without the expected executable.' }
    Write-Output "Native Python installed at $pythonTarget"
} finally {
    if (Test-Path -LiteralPath $pythonDownload) { Remove-Item -LiteralPath $pythonDownload }
}
