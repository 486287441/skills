# Kami static preview — port 3000; uses kami-serve.py (one-click save API) when available
param(
    [Parameter(Mandatory = $true)]
    [string]$Directory,
    [int]$Port = 3000
)

$ErrorActionPreference = 'Stop'
$dir = (Resolve-Path -LiteralPath $Directory).Path

function Stop-PortListener {
    param([int]$P)
    try {
        Get-NetTCPConnection -LocalPort $P -ErrorAction SilentlyContinue |
            ForEach-Object {
                Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
            }
    } catch { }
    Start-Sleep -Milliseconds 300
}

Stop-PortListener -P $Port

function Wait-PortReady {
    param([int]$P, [int]$TimeoutSec = 20)
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        try {
            $client = New-Object System.Net.Sockets.TcpClient
            $client.Connect('127.0.0.1', $P)
            $client.Close()
            return $true
        } catch {
            Start-Sleep -Milliseconds 200
        }
    }
    return $false
}

function Start-Preview {
    param([string]$Exe, [string[]]$PreviewArgs, [string]$WorkDir, [int]$P)
    Start-Process -FilePath $Exe -ArgumentList $PreviewArgs -WorkingDirectory $WorkDir -WindowStyle Minimized
    if (-not (Wait-PortReady -P $P)) {
        Write-Error "Port $P not listening after 20s. Is Python installed? Check minimized console for errors."
        exit 1
    }
}

$servePy = Join-Path $env:USERPROFILE '.cursor\scripts\kami-serve.py'
if (-not (Test-Path $servePy)) {
    $bundled = Join-Path $env:USERPROFILE '.cursor\skills\rough-idea-to-plan\scripts\kami-serve.py'
    if (Test-Path $bundled) { $servePy = $bundled }
}

if ((Test-Path $servePy) -and (Get-Command python -ErrorAction SilentlyContinue)) {
    Start-Preview -Exe 'python' -PreviewArgs @($servePy, $dir, "$Port") -WorkDir $dir -P $Port
    Write-Host "Kami preview: http://localhost:$Port"
    Write-Host "Serving: $dir"
    exit 0
}

if ((Test-Path $servePy) -and (Get-Command py -ErrorAction SilentlyContinue)) {
    Start-Preview -Exe 'py' -PreviewArgs @('-3', $servePy, $dir, "$Port") -WorkDir $dir -P $Port
    Write-Host "Kami preview: http://localhost:$Port"
    Write-Host "Serving: $dir"
    exit 0
}

if (Get-Command python -ErrorAction SilentlyContinue) {
    Start-Preview -Exe 'python' -PreviewArgs @('-m', 'http.server', "$Port") -WorkDir $dir -P $Port
    Write-Host "Kami preview: http://localhost:$Port (no save API — use copy JSON)"
    Write-Host "Serving: $dir"
    exit 0
}

if (Get-Command py -ErrorAction SilentlyContinue) {
    Start-Preview -Exe 'py' -PreviewArgs @('-3', '-m', 'http.server', "$Port") -WorkDir $dir -P $Port
    Write-Host "Kami preview: http://localhost:$Port (no save API — use copy JSON)"
    Write-Host "Serving: $dir"
    exit 0
}

if (Get-Command npx -ErrorAction SilentlyContinue) {
    Start-Preview -Exe 'npx' -PreviewArgs @('--yes', 'serve', '-l', "$Port", '.') -WorkDir $dir -P $Port
    Write-Host "Kami preview: http://localhost:$Port (npx serve, no save API)"
    Write-Host "Serving: $dir"
    exit 0
}

Write-Error 'Need python or npx on PATH. Install Python 3: https://www.python.org/downloads/'
exit 1
