#!/usr/bin/env bash
set -o pipefail

log_info() { printf '[INFO] %s\n' "$*"; }
log_success() { printf '[OK] %s\n' "$*"; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }
command_exists() { command -v "$1" >/dev/null 2>&1; }
redact() { [[ -z "${1:-}" ]] && printf '\n' || printf '[REDACTED]\n'; }
die() { local code="$1"; shift; log_error "E${code}: $*"; return "$code"; }
require_command() { command_exists "$1" || die 10 "Required command not found: $1"; }
require_ubuntu() {
  [[ -r /etc/os-release ]] || return 11
  . /etc/os-release
  [[ "$ID" == ubuntu && ("$VERSION_ID" == 22.04 || "$VERSION_ID" == 24.04) ]]
}
confirm() {
  local answer
  read -r -p "$1 [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}
