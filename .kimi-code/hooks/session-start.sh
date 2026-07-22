#!/bin/bash
# ABOUTME: Kimi Code UserPromptSubmit hook — runs analyze + tests on each prompt.
# ABOUTME: Port of .claude/hooks/session_start.sh with valid flutter analyze flags
# ABOUTME: (the original uses --fatal-lints/--fatal-build, which no longer exist).
INPUT=$(cat)

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
[ "$CWD" = "$PROJECT_ROOT" ] || exit 0

cd "$PROJECT_ROOT" && flutter analyze --fatal-infos --fatal-warnings && flutter test --no-pub
