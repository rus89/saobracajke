#!/bin/bash
# ABOUTME: Kimi Code PostToolUse hook — runs the mirrored test for edited lib/ files.
# ABOUTME: Port of the mirrored-test PostToolUse hook in .claude/settings.json.
INPUT=$(cat)

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
[ "$CWD" = "$PROJECT_ROOT" ] || exit 0

FILE=$(echo "$INPUT" | jq -r '.tool_input.path // .tool_input.file_path // empty')
REL="${FILE#$PROJECT_ROOT/}"
if [[ "$REL" == lib/*.dart ]]; then
  TEST="test/${REL#lib/}"
  TEST="${TEST%.dart}_test.dart"
  if [[ -f "$PROJECT_ROOT/$TEST" ]]; then
    cd "$PROJECT_ROOT" && flutter test --no-pub "$TEST" 2>&1 | tail -15
  fi
fi
exit 0
