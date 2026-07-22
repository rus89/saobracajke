#!/bin/bash
# ABOUTME: Kimi Code UserPromptSubmit hook — runs analyze + tests once per session
# ABOUTME: via a stamp file (SessionStart event drops stdout, so it can't be used).
INPUT=$(cat)

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
[ "$CWD" = "$PROJECT_ROOT" ] || exit 0

# Once per session: silent if this session_id was already checked (or is absent).
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
[ -n "$SESSION_ID" ] || exit 0
STAMP_DIR="$HOME/.cache/saobracajke/session-stamps"
STAMP="$STAMP_DIR/$SESSION_ID"
[ -f "$STAMP" ] && exit 0

cd "$PROJECT_ROOT" || exit 0

if ! ANALYZE=$(flutter analyze --fatal-infos --fatal-warnings 2>&1); then
  echo "saobracajke session check: flutter analyze FAILED:"
  echo "$ANALYZE" | tail -30
elif ! TESTS=$(flutter test --no-pub 2>&1); then
  echo "saobracajke session check: analyze clean, but flutter test FAILED:"
  echo "$TESTS" | tail -40
else
  echo "saobracajke session check: analyze clean; flutter test: $(echo "$TESTS" | tail -1)"
fi

mkdir -p "$STAMP_DIR" && touch "$STAMP"
# Prune stamps older than 30 days so the dir doesn't grow unbounded.
find "$STAMP_DIR" -type f -mtime +30 -delete 2>/dev/null || true
exit 0
