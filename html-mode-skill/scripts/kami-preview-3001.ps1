# html-mode-skill: start and verify preview on port 3001 (Windows Chinese-path safe)
param(
    [Parameter(Mandatory = $true)]
    [string]$HtmlDirectory,
    [int]$Port = 3001
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $HtmlDirectory)) {
    Write-Error "Directory not found: $HtmlDirectory"
}
$dir = (Resolve-Path -LiteralPath $HtmlDirectory).Path
$indexPath = Join-Path $dir 'index.html'
if (-not (Test-Path -LiteralPath $indexPath)) {
    Write-Error "Missing index.html in $dir"
}

$logPath = Join-Path $dir '.preview.log'
$statusPath = Join-Path $dir '.preview-status.json'

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
}

function Stop-PortListener {
    param([int]$P)
    try {
        Get-NetTCPConnection -LocalPort $P -ErrorAction SilentlyContinue |
            ForEach-Object {
                Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
            }
    } catch { }
    Start-Sleep -Milliseconds 400
}

function Wait-PortReady {
    param([int]$P, [int]$TimeoutSec = 25)
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        try {
            $client = New-Object System.Net.Sockets.TcpClient
            $client.Connect('127.0.0.1', $P)
            $client.Close()
            return $true
        } catch {
            Start-Sleep -Milliseconds 250
        }
    }
    return $false
}

function Test-PreviewHttp {
    param([int]$P)
    try {
        $r = Invoke-WebRequest -Uri "http://127.0.0.1:$P/" -UseBasicParsing -TimeoutSec 8
        return ($r.StatusCode -eq 200)
    } catch {
        return $false
    }
}

function Find-ServePy {
    $candidates = @(
        (Join-Path $env:USERPROFILE '.cursor\scripts\kami-serve.py'),
        (Join-Path $env:USERPROFILE '.cursor\skills\rough-idea-to-plan\scripts\kami-serve.py'),
        (Join-Path $PSScriptRoot 'kami-serve.py')
    )
    foreach ($p in $candidates) {
        if (Test-Path -LiteralPath $p) { return $p }
    }
    return $null
}

'' | Set-Content -LiteralPath $logPath -Encoding UTF8 -Force
Write-Log "HtmlDirectory=$dir"
Write-Log "Port=$Port"

Stop-PortListener -P $Port

$servePy = Find-ServePy
if (-not $servePy) {
    Write-Log 'ERROR: kami-serve.py not found'
    Write-Error 'kami-serve.py missing. Copy from rough-idea-to-plan/scripts to ~/.cursor/scripts/'
}

$python = $null
if (Get-Command python -ErrorAction SilentlyContinue) { $python = 'python' }
elseif (Get-Command py -ErrorAction SilentlyContinue) { $python = 'py' }
else {
    Write-Log 'ERROR: python not on PATH'
    Write-Error 'Python 3 required on PATH: https://www.python.org/downloads/'
}

# Do NOT pass Unicode paths in ArgumentList; use WorkingDirectory + "."
$previewArgs = if ($python -eq 'py') {
    @('-3', $servePy, '.', "$Port")
} else {
    @($servePy, '.', "$Port")
}

Write-Log "Start: $python $($previewArgs -join ' ')"

$proc = Start-Process -FilePath $python -ArgumentList $previewArgs -WorkingDirectory $dir -WindowStyle Hidden -PassThru
Write-Log "PID=$($proc.Id)"

if (-not (Wait-PortReady -P $Port)) {
    Write-Log 'ERROR: port not listening'
    @{ ok = $false; port = $Port; url = "http://localhost:$Port"; error = 'port_not_listening' } |
        ConvertTo-Json | Set-Content -LiteralPath $statusPath -Encoding UTF8
    Write-Error "Port $Port not ready in 25s. See $logPath"
}

if (-not (Test-PreviewHttp -P $Port)) {
    Write-Log 'ERROR: HTTP check failed'
    @{ ok = $false; port = $Port; url = "http://localhost:$Port"; error = 'http_check_failed' } |
        ConvertTo-Json | Set-Content -LiteralPath $statusPath -Encoding UTF8
    Write-Error "No HTTP 200 from http://127.0.0.1:$Port/ . See $logPath"
}

$status = @{
    ok = $true
    port = $Port
    url = "http://localhost:$Port"
    pid = $proc.Id
    directory = $dir
    index = $indexPath
}
$status | ConvertTo-Json | Set-Content -LiteralPath $statusPath -Encoding UTF8
Write-Log 'OK: preview ready'

Write-Host "Kami preview: http://localhost:$Port"
Write-Host "Serving: $dir"
Write-Host "Status: $statusPath"
