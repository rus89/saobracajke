#!/usr/bin/env node
// ABOUTME: Kimi Code PreToolUse hook — blocks dangerous Bash commands.
// ABOUTME: Thin wrapper over .claude/hooks/block-dangerous-commands.js (same rules, Kimi payload).
const path = require('path');

const PROJECT_ROOT = path.resolve(__dirname, '..', '..');
const { checkCommand } = require(path.join(PROJECT_ROOT, '.claude/hooks/block-dangerous-commands.js'));

let input = '';
process.stdin.on('data', (c) => (input += c));
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    // Hooks register globally — only guard this project.
    if (data.cwd !== PROJECT_ROOT || data.tool_name !== 'Bash') process.exit(0);

    const result = checkCommand(data.tool_input?.command || '');
    if (result.blocked) {
      console.error(`⛔ [${result.pattern.id}] ${result.pattern.reason}`);
      process.exit(2);
    }
    process.exit(0);
  } catch {
    process.exit(0); // fail open
  }
});
