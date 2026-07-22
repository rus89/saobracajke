#!/bin/bash
# ABOUTME: Kimi Code PostToolUse hook — runs flutter analyze after Edit/Write.
# ABOUTME: Port of the flutter-analyze PostToolUse hook in .claude/settings.json.
INPUT=$(cat)

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
[ "$CWD" = "$PROJECT_ROOT" ] || exit 0

cd "$PROJECT_ROOT" && flutter analyze --no-pub 2>&1 | head -20
exit 0
