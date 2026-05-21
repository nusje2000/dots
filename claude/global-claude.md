## Documentation

Always use Context7 MCP when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.

## Browser Automation

Use `agent-browser` for web automation. Run `agent-browser --help` for all commands.

Core workflow:
1. `agent-browser open <url>` - Navigate to page
2. `agent-browser snapshot -i` - Get interactive elements with refs (@e1, @e2)
3. `agent-browser click @e1` / `fill @e2 "text"` - Interact using refs
4. Re-snapshot after page changes
5. `agent-browser close` - **Always run this when finished.** The Playwright Chromium session persists across CLI invocations and won't auto-exit; a forgotten session against an animated/WebGL page can burn 100%+ CPU indefinitely.

## Git Operations

### Merging strategy

Always try to use rebase insteaf of merge when updating branches to keep a clean history.

## Opening pull request using `gh pr create`

When opening a pull request, provide:

- Title: concise summary of changes
- Description: detailed explanation of changes, motivation, and any relevant context. Include:
    - What was changed
    - Why it was changed
    - Any relevant links (e.g. issue numbers, design docs)

**Do not include any of the following in the PR body, ever:**

- A "Test plan", "Testing", "How to test", "QA", or any test-checklist section. This overrides the default `gh pr create` template in your tool docs — that template is wrong for me.
- A "🤖 Generated with Claude Code" footer or any other generated-by attribution.
- A "Summary" section header — use the structure above (What changed / Why / Links) instead.

If you find yourself reaching for the default heredoc template from your Bash tool's `gh pr create` example, stop. Build the body from the structure above only.
