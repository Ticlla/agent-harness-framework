#!/usr/bin/env bash
# install.sh — install / uninstall / inspect Agent Harness Framework skills.
#
# Default action: copy the framework skills into ~/.claude/skills (self-contained;
# the repo can be moved or deleted afterwards and the skills keep working). The
# default set is the five meta-skills plus `prompt-engineering` (a vendored
# advisory skill that meta-skills consult on demand; see
# skills/prompt-engineering/PROVENANCE.md).
#
# Usage:
#   scripts/install.sh install   [--target claude|cursor|<path>] [--link] [--skills a,b,c] [-y]
#   scripts/install.sh uninstall [--target claude|cursor|<path>] [--skills a,b,c] [-y]
#   scripts/install.sh status    [--target claude|cursor|<path>]
#   scripts/install.sh [--help|-h]
#
# Options:
#   --target claude|cursor|<path>   Where to install. claude=~/.claude/skills (default),
#                                   cursor=~/.cursor/skills, or any directory path.
#   --link                          Symlink skills to this repo instead of copying them.
#                                   Tracks `git pull` live, but the repo must stay in place.
#   --skills a,b,c                  Comma-separated subset. Default: designer,implementer,
#                                   validator,enhancer,skill-creator,prompt-engineering.
#   -y                              Skip confirmation prompts (uninstall).
#   --help, -h                      Show this help.
#
# Examples:
#   scripts/install.sh                                   # copy all into ~/.claude/skills
#   scripts/install.sh install --target cursor          # copy all into ~/.cursor/skills
#   scripts/install.sh install --link                   # symlink into ~/.claude/skills
#   scripts/install.sh uninstall -y                     # remove all from ~/.claude/skills
#   scripts/install.sh status                           # show what is installed where
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_SKILLS="designer,implementer,validator,enhancer,skill-creator,prompt-engineering"

# --- helpers ----------------------------------------------------------------

color() { printf '\033[%sm%s\033[0m' "$1" "${2-}"; }
say()  { printf '%s\n' "$*"; }
info() { printf '%s %s\n' "$(color '1;34' '•')" "$*"; }
ok()   { printf '%s %s\n' "$(color '1;32' '✓')" "$*"; }
warn() { printf '%s %s\n' "$(color '1;33' '!')" "$*" >&2; }
die()  { printf '%s %s\n' "$(color '1;31' '✗')" "$*" >&2; exit 1; }

resolve_target() {
  case "$1" in
    claude) printf '%s' "$HOME/.claude/skills" ;;
    cursor) printf '%s' "$HOME/.cursor/skills" ;;
    *)      printf '%s' "$1" ;;
  esac
}

# Print "link" if $1/<skill> is a symlink resolving into $REPO/skills,
# "copy" if it is a real dir we manage (marked with our .ahf-installed sentinel),
# "foreign" if something exists that is not ours, "missing" otherwise.
classify() {
  local target="$1" skill="$2" p="$1/$2"
  if [ -L "$p" ]; then
    local real; real="$(cd "$p" 2>/dev/null && pwd -P)" || true
    case "$real" in "$REPO"/skills/*) echo "link"; return ;; esac
  fi
  if [ -d "$p" ] && [ -e "$p/.ahf-installed" ]; then
    echo "copy"; return
  fi
  if [ -e "$p" ] || [ -L "$p" ]; then echo "foreign"; else echo "missing"; fi
}

confirm() {
  [ "${ASSUME_YES:-0}" = 1 ] && return 0
  local reply
  printf '%s [y/N]: ' "$1" >&2
  read -r reply
  case "$reply" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

# --- actions ----------------------------------------------------------------

do_install() {
  local target; target="$(resolve_target "$TARGET")"
  mkdir -p "$target"
  info "Installing into: $target  (method: $METHOD)"

  # Informational only — installing skills does not need Python, but skill-creator
  # scripts (init/package/quick_validate) do. Surface the gap before the user hits it.
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      warn "Windows shell detected: install.sh works here, but skill-creator scripts need Python 3 — use 'python' or 'py -3' (python3 is rarely on PATH on Windows)."
      ;;
  esac
  if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1 && ! command -v py >/dev/null 2>&1; then
    warn "No Python 3 found on PATH: skill-creator init/package/validate scripts will fail until Python 3 is installed."
  fi

  local skill src dst rc=0
  for skill in "${SKILLS[@]}"; do
    src="$REPO/skills/$skill"
    dst="$target/$skill"
    if [ ! -r "$src/SKILL.md" ]; then
      warn "source skill not found, skipping: $skill (looked in $src)"
      rc=1; continue
    fi
    rm -rf "$dst" 2>/dev/null || warn "could not clear existing $dst"
    if [ "$METHOD" = link ]; then
      ln -sfn "$src" "$dst"
      ok "linked  $skill"
    else
      cp -R "$src" "$dst"
      : > "$dst/.ahf-installed"   # sentinel so uninstall recognises our copy
      ok "copied  $skill"
    fi
  done
  say ""
  info "Done. ${#SKILLS[@]} skill(s) processed at $target ($METHOD)."
  if [ "$METHOD" = link ]; then
    say "  Note: --link tracks this repo live; keep $REPO in place."
  else
    say "  Update later with: git pull && scripts/install.sh install --target ${TARGET}"
  fi
  return $rc
}

do_uninstall() {
  local target; target="$(resolve_target "$TARGET")"
  info "Target: $target"
  local skill kind to_remove=()
  for skill in "${SKILLS[@]}"; do
    kind="$(classify "$target" "$skill")"
    case "$kind" in
      missing) printf '  %s %s (not present)\n' "$(color '0;90' '-')" "$skill" ;;
      link|copy) to_remove+=("$skill"); printf '  %s %s (%s)\n' "$(color '1;33' '?')" "$skill" "$kind" ;;
      foreign)
        warn "$skill exists at target but is not managed by this installer — leaving it untouched."
        ;;
    esac
  done
  if [ ${#to_remove[@]} -eq 0 ]; then
    ok "Nothing to remove."
    return 0
  fi
  say ""
  if ! confirm "Remove the ${#to_remove[@]} skill(s) above from $target?"; then
    info "Aborted (nothing changed)."; return 0
  fi
  for skill in "${to_remove[@]}"; do
    rm -rf "$target/$skill"
    ok "removed $skill"
  done
  say ""
  info "Done. ${#to_remove[@]} skill(s) removed."
}

do_status() {
  local target; target="$(resolve_target "$TARGET")"
  info "Target: $target"
  local skill kind
  for skill in "${SKILLS[@]}"; do
    kind="$(classify "$target" "$skill")"
    case "$kind" in
      link)    printf '  %s %-16s link → %s\n' "$(color '1;32' '✓')" "$skill" "$REPO/skills/$skill" ;;
      copy)    printf '  %s %-16s copy\n'                "$(color '1;32' '✓')" "$skill" ;;
      missing) printf '  %s %-16s not installed\n'       "$(color '0;90' '×')" "$skill" ;;
      foreign) printf '  %s %-16s present but not managed by this installer\n' "$(color '1;33' '!')" "$skill" ;;
    esac
  done
}

# --- arg parsing ------------------------------------------------------------

ACTION="install"
TARGET="claude"
METHOD="copy"
ASSUME_YES=0
SKILLS=()

show_help() { sed -n '3,28p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

while [ $# -gt 0 ]; do
  case "$1" in
    install|uninstall|status) ACTION="$1" ;;
    --target) TARGET="${2:?--target needs a value}"; shift ;;
    --link)   METHOD="link" ;;
    --skills) IFS=',' read -r -a SKILLS <<< "${2:?--skills needs a value}"; shift ;;
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help) show_help ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

[ ${#SKILLS[@]} -eq 0 ] && IFS=',' read -r -a SKILLS <<< "$DEFAULT_SKILLS"

case "$ACTION" in
  install)   do_install ;;
  uninstall) do_uninstall ;;
  status)    do_status ;;
esac
