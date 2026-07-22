#!/bin/bash
# ABOUTME: Kimi Code PreToolUse hook — blocks Edit/Write on protected files.
# ABOUTME: Port of .claude/hooks/protect-files.sh; reads Kimi's tool_input.path.
INPUT=$(cat)

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
# Hooks register globally in ~/.kimi-code/config.toml — only guard this project.
[ "$CWD" = "$PROJECT_ROOT" ] || exit 0

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // .tool_input.file_path // empty')

PROTECTED_PATTERNS=(".env" "package-lock.json" ".git/" "pubspec.lock")

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: $FILE_PATH matches protected pattern '$pattern'" >&2
    exit 2
  fi
done

exit 0
