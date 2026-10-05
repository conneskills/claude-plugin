#!/usr/bin/env bash
# check-aidlc-evidence.sh
#
# AI-DLC evidence gate for conneskills-platform repositories.
#
# Policy: PRO-378#document-policy — every code/product change in the 4 repos of
# `conneskills-platform` must run through the AI-DLC workflow (`/aidlc`) with a
# scope proportional to the change, and must carry evidence (`.aidlc/` state,
# approved plan, build/test verification) before it can be merged.
#
# This script enforces that at PR time: when the pull request touches code
# paths, its body must reference the AI-DLC workflow/plan, or explicitly
# declare an exemption (`AI-DLC-Exempt: <reason>`). Documentation/config-only
# changes pass automatically.
#
# Usage:
#   bash scripts/check-aidlc-evidence.sh [base-ref] [--body-file PATH]
#
# Inputs (in priority order):
#   --body-file PATH   Read the PR body from PATH.
#   PR_BODY            Read the PR body from this env var (used by CI).
#   AIDLC_CHANGED_FILES  Newline-separated changed-file list (skips git diff).
#   base-ref           First positional arg, else GITHUB_BASE_REF, else main.
#
# Exit code: 0 = evidence present or change exempt, 1 = missing evidence.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

BASE_REF="${GITHUB_BASE_REF:-main}"
BODY_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --body-file)
      BODY_FILE="${2:-}"
      shift 2
      ;;
    --help|-h)
      sed -n '1,30p' "$0"
      exit 0
      ;;
    *)
      BASE_REF="$1"
      shift
      ;;
  esac
done

# --- changed files ----------------------------------------------------------
changed=()
if [[ -n "${AIDLC_CHANGED_FILES:-}" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && changed+=("$line")
  done <<<"$AIDLC_CHANGED_FILES"
else
  if ! git rev-parse --verify --quiet "origin/$BASE_REF" >/dev/null; then
    git fetch --no-tags --quiet origin "$BASE_REF" 2>/dev/null || true
  fi
  if git rev-parse --verify --quiet "origin/$BASE_REF" >/dev/null; then
    range="origin/$BASE_REF...HEAD"
  else
    range="HEAD~1...HEAD"
  fi
  while IFS= read -r line; do
    [[ -n "$line" ]] && changed+=("$line")
  done < <(git diff --name-only --diff-filter=ACMRT "$range" || true)
fi

# --- classify ---------------------------------------------------------------
is_code_path() {
  case "$1" in
    *.md|*.mdx|*.markdown|*.txt|*.rst) return 1 ;;
    docs/*|documentation/*|.github/*) return 1 ;;
    LICENSE|LICENSE.*|NOTICE|.gitignore|.gitattributes|.editorconfig) return 1 ;;
    *) return 0 ;;
  esac
}

code_files=()
for f in "${changed[@]}"; do
  if is_code_path "$f"; then
    code_files+=("$f")
  fi
done

echo "AI-DLC evidence gate"
echo "  base ref:     $BASE_REF"
echo "  changed:      ${#changed[@]} file(s)"
echo "  code change:  ${#code_files[@]} file(s)"

if [[ "${#changed[@]}" -eq 0 ]]; then
  echo "OK: no changed files detected — nothing to enforce."
  exit 0
fi

if [[ "${#code_files[@]}" -eq 0 ]]; then
  echo "OK: documentation/config-only change — AI-DLC workflow not required."
  exit 0
fi

# --- read PR body -----------------------------------------------------------
body=""
if [[ -n "$BODY_FILE" ]]; then
  if [[ ! -f "$BODY_FILE" ]]; then
    echo "ERROR: --body-file '$BODY_FILE' does not exist." >&2
    exit 2
  fi
  body="$(cat "$BODY_FILE")"
elif [[ -n "${PR_BODY:-}" ]]; then
  body="$PR_BODY"
else
  echo "ERROR: no PR body provided. Pass --body-file, set PR_BODY, or run in CI." >&2
  exit 2
fi

# Strip HTML comments so the PR template's guidance/example tokens do not count
# as evidence.
clean_body="$(printf '%s' "$body" | perl -0pe 's/<!--.*?-->//gs' 2>/dev/null || printf '%s' "$body")"

# --- evaluate ---------------------------------------------------------------
# Accepted evidence tokens (must be non-empty):
#   - a path into `.aidlc/` state
#   - a `Workflow:` / `Plan:` / `Verification:` line with a real value
#   - an issue reference such as PRO-394
evidence_re='(\.aidlc/|Workflow:[[:space:]]*[^[:space:]<]|Plan:[[:space:]]*[^[:space:]<]|Verificaci[oó]n:[[:space:]]*[^[:space:]<]|Verification:[[:space:]]*[^[:space:]<]|PRO-[0-9]+)'

# Declared exemption: `AI-DLC-Exempt: <reason>` with a reason of >= 5 chars.
exempt_re='AI-DLC-Exempt:[[:space:]]*[^[:space:]].{4,}'

if printf '%s' "$clean_body" | grep -Eq "$exempt_re"; then
  echo "OK: exemption declared (AI-DLC-Exempt)."
  exit 0
fi

if printf '%s' "$clean_body" | grep -Eq "$evidence_re"; then
  echo "OK: AI-DLC evidence found for the code change."
  exit 0
fi

echo ""
echo "FAIL: this PR changes code paths but carries no AI-DLC evidence."
echo ""
echo "  Code files changed:"
for f in "${code_files[@]}"; do
  echo "    - $f"
done
echo ""
echo "  Add an '## AI-DLC Evidence' section to the PR body referencing the"
echo "  workflow/plan and the build/test verification, for example:"
echo "    - Workflow: .aidlc/scopes/<scope>.md"
echo "    - Plan: approved — PRO-### #document-plan"
echo "    - Verification: <command> -> green"
echo ""
echo "  If the change is exempt (docs/config-only or incident/rollback with"
echo "  retroactive AI-DLC within 24h), declare it explicitly:"
echo "    AI-DLC-Exempt: <reason>"
echo ""
echo "  Policy: PRO-378#document-policy"
exit 1
