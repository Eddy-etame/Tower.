#Requires -Version 5.1
<#
  Project 001 - ZERO-TOUCH bootstrap (Windows).

  Installs the toolchain (Rokit -> rojo/stylua/selene/wally), installs Roblox Studio if it is
  missing, installs the Rojo Studio plugin, builds the place, and opens it in Studio ready to test.
  A tester runs ONE command and presses Play. No manual prerequisites.

  Usage (from anywhere):
    powershell -ExecutionPolicy Bypass -File scripts\bootstrap.ps1            # install + build + open in Studio
    powershell -ExecutionPolicy Bypass -File scripts\bootstrap.ps1 -Serve     # + start `rojo serve` for live sync
    powershell -ExecutionPolicy Bypass -File scripts\bootstrap.ps1 -NoLaunch  # install + build only (CI / headless)

  Honest ceiling (not something a script can remove): Roblox Studio needs you to sign in to a
  Roblox account ONCE, the first time it opens. Everything else is automatic.

  NOTE: this file is intentionally ASCII-only. Windows PowerShell 5.1 reads .ps1 as the system ANSI
  codepage, so non-ASCII characters (em-dashes, arrows) corrupt string parsing. Keep it ASCII.
#>
param(
    [switch]$Serve,
    [switch]$NoLaunch
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue' # makes Invoke-WebRequest far faster

function Say($m) { Write-Host "[bootstrap] $m" -ForegroundColor Cyan }
function Ok($m) { Write-Host "[bootstrap] $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[bootstrap] $m" -ForegroundColor Yellow }
function Die($m) { Write-Host "[bootstrap] $m" -ForegroundColor Red; exit 1 }

# --- project root (this script lives in <root>\scripts) ---
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
Say "Project 001 root: $Root"

$rokitBin = Join-Path $env:USERPROFILE ".rokit\bin"

# ---------------------------------------------------------------- 1. Rokit + pinned tools
function Resolve-Rokit {
    $cmd = Get-Command rokit -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $local = Join-Path $rokitBin "rokit.exe"
    if (Test-Path $local) { return $local }
    return $null
}

$rokit = Resolve-Rokit
if (-not $rokit) {
    Say "Rokit (toolchain manager) not found. Installing the latest release..."
    $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/rojo-rbx/rokit/releases/latest" `
        -Headers @{ 'User-Agent' = 'runtime-studio-bootstrap' }
    $asset = $rel.assets | Where-Object { $_.name -match 'windows-x86_64\.zip$' } | Select-Object -First 1
    if (-not $asset) { Die "No Windows Rokit release asset found. Install Rokit manually: https://github.com/rojo-rbx/rokit" }
    $zip = Join-Path $env:TEMP "rokit-dl.zip"
    $ex = Join-Path $env:TEMP "rokit-dl"
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip
    if (Test-Path $ex) { Remove-Item $ex -Recurse -Force }
    Expand-Archive -Path $zip -DestinationPath $ex -Force
    $exe = Get-ChildItem $ex -Filter rokit.exe -Recurse | Select-Object -First 1
    if (-not $exe) { Die "Rokit archive did not contain rokit.exe." }
    & $exe.FullName self-install
    $rokit = Join-Path $rokitBin "rokit.exe"
    if (-not (Test-Path $rokit)) { Die "Rokit self-install did not produce $rokit." }
    Ok "Rokit installed."
}

# make sure THIS session can see rokit's tool shims (self-install only updates future sessions)
if ($env:PATH -notlike "*$rokitBin*") { $env:PATH = "$rokitBin;$env:PATH" }

Say "Installing pinned tools from rokit.toml (rojo / stylua / selene / wally)..."
& $rokit install --no-trust-check
if ($LASTEXITCODE -ne 0) { Die "rokit install failed (exit $LASTEXITCODE)." }

function Tool($name) {
    $p = Join-Path $rokitBin "$name.exe"
    if (Test-Path $p) { return $p }
    $c = Get-Command $name -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    return $null
}
$rojo = Tool 'rojo'
if (-not $rojo) { Die "rojo not available after 'rokit install'." }
Ok "Toolchain ready."

# ---------------------------------------------------------------- 2. Roblox Studio
function Find-Studio {
    $versions = Join-Path $env:LOCALAPPDATA "Roblox\Versions"
    if (Test-Path $versions) {
        $exe = Get-ChildItem $versions -Filter RobloxStudioBeta.exe -Recurse -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($exe) { return $exe.FullName }
    }
    return $null
}

$studio = Find-Studio
if (-not $studio) {
    Say "Roblox Studio not found. Downloading the official installer..."
    $launcher = Join-Path $env:TEMP "RobloxStudioLauncherBeta.exe"
    try {
        Invoke-WebRequest -Uri "https://setup.rbxcdn.com/RobloxStudioLauncherBeta.exe" -OutFile $launcher
        Say "Running the Studio installer (it downloads the current Studio, about 1-2 minutes)..."
        Start-Process -FilePath $launcher -Wait
    } catch {
        Warn "Automatic Studio download failed: $($_.Exception.Message)"
    }
    # the launcher installs asynchronously - poll for the executable to appear
    $deadline = (Get-Date).AddMinutes(4)
    while ((-not $studio) -and ((Get-Date) -lt $deadline)) {
        Start-Sleep -Seconds 5
        $studio = Find-Studio
    }
    if ($studio) {
        Ok "Roblox Studio installed."
    } else {
        Warn "Studio did not finish installing automatically."
        Warn "Install it once from https://create.roblox.com/ (and sign in to a Roblox account), then re-run this script."
    }
}

if ($studio) {
    Say "Installing the Rojo Studio plugin (live-sync bridge)..."
    try {
        & $rojo plugin install
        if ($LASTEXITCODE -ne 0) { Warn "rojo plugin install exited $LASTEXITCODE (non-fatal)." }
    } catch {
        Warn "rojo plugin install failed (non-fatal): $($_.Exception.Message)"
    }
}

# ---------------------------------------------------------------- 3. Build
Say "Building Project001.rbxl from src/ ..."
& $rojo build -o Project001.rbxl
if ($LASTEXITCODE -ne 0) { Die "rojo build failed (exit $LASTEXITCODE)." }
Ok "Built Project001.rbxl."

if ($NoLaunch) { Ok "Done (build only)."; exit 0 }

# ---------------------------------------------------------------- 4. Launch
$place = Join-Path $Root "Project001.rbxl"

if ($Serve) {
    Say "Starting 'rojo serve' for live sync (keep it running; in Studio open the Rojo panel, then Connect)..."
    Start-Process -FilePath $rojo -ArgumentList 'serve' -WorkingDirectory $Root
}

if ($studio) {
    Say "Opening the place in Roblox Studio. Press Play (F5) to test. Sign in to Roblox once if prompted."
    Start-Process -FilePath $place # .rbxl file association opens Studio
    Ok "Launched. Expected Output on Play: both '[Project001] booted' lines, ZERO red errors."
} else {
    Warn "Studio isn't installed yet. Once it is, double-click Project001.rbxl (or re-run this script) to test."
}
