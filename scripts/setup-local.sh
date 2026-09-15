#!/usr/bin/env bash
# ローカル常駐の初期化: .env symlink、依存同期、LaunchAgent 登録（登録は --launchd 指定時のみ）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ln -sfn local.env .env
/opt/homebrew/bin/uv sync --frozen
test -r "$(jq -r .Ellis voices/voices.json)" || { echo "error: Ellis reference wav not found" >&2; exit 2; }
if [[ "${1:-}" == "--launchd" ]]; then
  test -x "$HOME/.local/libexec/launchd-delay-exec"
  cp launchd/com.ms25.irodori-tts-server.plist "$HOME/Library/LaunchAgents/"
  launchctl bootout "gui/$(id -u)/com.ms25.irodori-tts-server" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.ms25.irodori-tts-server.plist"
  launchctl kickstart -k "gui/$(id -u)/com.ms25.irodori-tts-server"
fi
echo "ok"
