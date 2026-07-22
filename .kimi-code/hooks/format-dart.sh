#!/bin/bash
# ABOUTME: Kimi Code PostToolUse hook — runs dart format on edited .dart files.
# ABOUTME: Port of the dart-format PostToolUse hook in .claude/settings.json.
INPUT=$(cat)

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
[ "$CWD" = "$PROJECT_ROOT" ] || exit 0

FILE=$(echo "$INPUT" | jq -r '.tool_input.path // .tool_input.file_path // empty')
if [[ "$FILE" == *.dart ]]; then
  dart format "$FILE" 2>&1
fi
exit 0
