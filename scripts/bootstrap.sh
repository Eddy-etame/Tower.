#!/usr/bin/env bash
# Project 001 - zero-touch bootstrap (macOS / Linux, best-effort companion to bootstrap.ps1).
#
# Installs the toolchain (Rokit -> rojo/stylua/selene/wally), builds the place, and opens it in
# Roblox Studio on macOS. Roblox Studio runs only on Windows and macOS - on Linux this builds only.
#
# Usage (from anywhere):
#   bash scripts/bootstrap.sh            # install toolchain + build + open in Studio (macOS)
#   bash scripts/bootstrap.sh --serve    # + start `rojo serve` for live sync
#   bash scripts/bootstrap.sh --no-launch
#
# Honest ceiling: Roblox Studio needs a one-time Roblox sign-in the first time it opens.
set -euo pipefail

SERVE=0; NOLAUNCH=0
for a in "$@"; do
  case "$a" in
    --serve) SERVE=1 ;;
    --no-launch) NOLAUNCH=1 ;;
  esac
done

say()  { printf '\033[36m[bootstrap]\033[0m %s\n' "$1"; }
ok()   { printf '\033[32m[bootstrap]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[bootstrap]\033[0m %s\n' "$1"; }
die()  { printf '\033[31m[bootstrap]\033[0m %s\n' "$1"; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
say "Project 001 root: $ROOT"

OS="$(uname -s)"
ARCH="$(uname -m)"
ROKIT_BIN="$HOME/.rokit/bin"
export PATH="$ROKIT_BIN:$PATH"

# ---------------------------------------------------------------- 1. Rokit + pinned tools
if ! command -v rokit >/dev/null 2>&1 && [ ! -x "$ROKIT_BIN/rokit" ]; then
  say "Rokit (toolchain manager) not found - installing the latest release..."
  case "$OS" in
    Darwin) plat="macos" ;;
    Linux)  plat="linux" ;;
    *) die "Unsupported OS: $OS" ;;
  esac
  case "$ARCH" in
    arm64|aarch64) rarch="aarch64" ;;
    x86_64|amd64)  rarch="x86_64" ;;
    *) die "Unsupported arch: $ARCH" ;;
  esac
  url="$(curl -fsSL https://api.github.com/repos/rojo-rbx/rokit/releases/latest \
        | grep -o "https://[^\"]*rokit-[^\"]*${plat}-${rarch}\.zip" | head -n1)"
  [ -n "$url" ] || die "Could not find a Rokit release for ${plat}-${rarch}. Install manually: https://github.com/rojo-rbx/rokit"
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/rokit.zip"
  unzip -o -q "$tmp/rokit.zip" -d "$tmp"
  rk="$(find "$tmp" -name rokit -type f | head -n1)"
  [ -n "$rk" ] || die "Rokit archive did not contain the rokit binary."
  chmod +x "$rk"
  "$rk" self-install
  ok "Rokit installed."
fi

ROKIT="$(command -v rokit || echo "$ROKIT_BIN/rokit")"
say "Installing pinned tools from rokit.toml (rojo / stylua / selene / wally)..."
"$ROKIT" install --no-trust-check
ROJO="$ROKIT_BIN/rojo"; [ -x "$ROJO" ] || ROJO="$(command -v rojo)"
[ -n "$ROJO" ] || die "rojo not available after 'rokit install'."
ok "Toolchain ready."

# ---------------------------------------------------------------- 2. Roblox Studio (macOS only)
STUDIO_APP="/Applications/RobloxStudio.app"
if [ "$OS" = "Darwin" ]; then
  if [ ! -d "$STUDIO_APP" ]; then
    if command -v brew >/dev/null 2>&1; then
      say "Roblox Studio not found - installing via Homebrew cask..."
      brew install --cask roblox-studio || warn "Homebrew cask install failed - install once from https://create.roblox.com/"
    else
      warn "Roblox Studio not found. Install it once from https://create.roblox.com/ (and sign in), then re-run."
    fi
  fi
  if [ -d "$STUDIO_APP" ]; then
    say "Installing the Rojo Studio plugin..."
    "$ROJO" plugin install || warn "rojo plugin install failed (non-fatal)."
  fi
elif [ "$OS" = "Linux" ]; then
  warn "Roblox Studio does not run on Linux - this will build the place but cannot launch it."
fi

# ---------------------------------------------------------------- 3. Build
say "Building Project001.rbxl from src/ ..."
"$ROJO" build -o Project001.rbxl
ok "Built Project001.rbxl."

[ "$NOLAUNCH" = "1" ] && { ok "Done (build only)."; exit 0; }

# ---------------------------------------------------------------- 4. Launch
if [ "$SERVE" = "1" ]; then
  say "Starting 'rojo serve' for live sync (keep it running; in Studio open the Rojo panel -> Connect)..."
  ("$ROJO" serve >/dev/null 2>&1 &)
fi

if [ "$OS" = "Darwin" ] && [ -d "$STUDIO_APP" ]; then
  say "Opening the place in Roblox Studio. Press Play to test. Sign in to Roblox once if prompted."
  open -a "$STUDIO_APP" "$ROOT/Project001.rbxl"
  ok "Launched. Expected Output on Play: both '[Project001] booted' lines, ZERO red errors."
else
  warn "Studio not available here - once installed, open Project001.rbxl to test."
fi
