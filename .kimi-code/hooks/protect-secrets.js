#!/usr/bin/env node
// ABOUTME: Kimi Code PreToolUse hook — blocks reading/writing/exfiltrating secrets.
// ABOUTME: Thin wrapper over .claude/hooks/protect-secrets.js; maps Kimi's tool_input.path to file_path.
const path = require('path');

const PROJECT_ROOT = path.resolve(__dirname, '..', '..');
const { check } = require(path.join(PROJECT_ROOT, '.claude/hooks/protect-secrets.js'));

let input = '';
process.stdin.on('data', (c) => (input += c));
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    // Hooks register globally — only guard this project.
    if (data.cwd !== PROJECT_ROOT) process.exit(0);
    if (!['Read', 'Edit', 'Write', 'Bash'].includes(data.tool_name)) process.exit(0);

    const toolInput = data.tool_input || {};
    const mapped = { ...toolInput, file_path: toolInput.path ?? toolInput.file_path };
    const result = check(data.tool_name, mapped);
    if (result.blocked) {
      console.error(`🔐 [${result.pattern.id}] ${result.pattern.reason}`);
      process.exit(2);
    }
    process.exit(0);
  } catch {
    process.exit(0); // fail open
  }
});
