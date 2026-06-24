## How we work together

Be brutally honest, direct, and skip the preamble. Be a bit nerdy, feel free to shame on bad practices and call them out. I want to
learn and improve and I always strive to get the best results, even if this is outside of my comfort zone.

## Documentation

Always use Context7 MCP when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.

## Naming conventions

When naming variables, functions, classes, and other identifiers, follow these guidelines:
- Use descriptive names that clearly indicate the purpose of the variable. Avoid using single-letter names or abbreviations. e.g. `userCount` instead of `uc`.
- Avoid using reserved keywords or names that may cause confusion. e.g. avoid naming a variable `class` or `function`.

## Code comments
A comment earns its place only if it is **coupled to the code it sits on** and stays true as the codebase moves. Before writing one, ask: does this describe something intrinsic to *this* code, or just a fact that happens to be true right now elsewhere?

- **Explain the why, not the what.** If the why is self-explanatory from the code or a clear name, write no comment. Never restate the method/variable name (e.g. a factory state named `complete()` does not need "marks it complete").
- **Don't narrate incidental architecture.** A comment that describes a pattern, a sibling class, or a wider design decision that isn't enforced by the code in front of it is slop — it rots silently when that other thing changes. Pattern labels like "(class-table inheritance)" add jargon, not actionable information; leave them out.
- **No conversational or historical framing.** Comments must be standalone for a future reader. Drop references to "the recent refactor", "so X can keep working", the agent conversation, or why the change was made rather than what the code now does.
- **Keep coupled why-comments.** A comment directly above a surprising line (a double-save working around a hook, an in-memory object created before persistence, a non-obvious relationship key) is exactly what to keep — concise and to the point.
- Prefer PHPDoc blocks over inline comments; use curly braces and the conventions in the PHP rules below. Enum docblocks are the documented exception above (load-bearing for the API spec).

## Browser Automation

Use `agent-browser` for web automation. Run `agent-browser --help` for all commands.

Core workflow:
1. `agent-browser open <url>` - Navigate to page
2. `agent-browser snapshot -i` - Get interactive elements with refs (@e1, @e2)
3. `agent-browser click @e1` / `fill @e2 "text"` - Interact using refs
4. Re-snapshot after page changes
5. `agent-browser close` - **Always run this when finished.** The Playwright Chromium session persists across CLI invocations and won't auto-exit; a forgotten session against an animated/WebGL page can burn 100%+ CPU indefinitely.

## Figma (`use_figma` / Plugin API)

### Writes can be silently rolled back — verify centrally, never trust self-reports

`use_figma` writes are **not reliably durable**, and the failure is silent. Observed on a real
build: three subagents created 12 components, each verified them present with a read-back, and
each correctly reported success. A later rollback reverted the file to an earlier checkpoint and
**all 12 were destroyed**. The node-ID counter had jumped (`8:x` → `13:x`), confirming IDs were
allocated and then discarded.

Rules that follow:

- **A successful read-back does NOT prove durability.** An agent's own verification can be
  invalidated by a later rollback. Never treat "the agent said it built it" as fact.
- **After any batch of writes — especially parallel ones — re-verify centrally** with a read-only
  inventory that walks `figma.root.children`, calls `await page.loadAsync()`, and lists
  `page.findAllWithCriteria({types:['COMPONENT','COMPONENT_SET']})`. Compare against an expected
  list. That inventory is the only source of truth.
- **Re-dispatch whatever is missing.** Structure the work as dispatch → verify → repair, never
  dispatch → trust.

### `Plugin execution failed due to an internal error` means STATE UNKNOWN — never blind-retry

This error does **not** mean "nothing happened" — mutations frequently apply anyway. Probe with a
read-only call to see what actually landed, then decide. A blind retry on this error created 4
duplicate component sets in one session. Other error classes (validation, bad property values) do
appear to be genuinely atomic.

### On parallelising subagents

The `figma-generate-library` skill says *never parallelise `use_figma`*; the `figma-use` skill says
*fan out per page for multi-page work*. They contradict each other. Evidence from a real run: one
wave of 3 parallel agents lost everything past a checkpoint, while another wave of 3 parallel
agents — same concurrency — lost nothing. Parallelism is **not** deterministically fatal, but it is
not safe either.

- **Foundations (variables, styles) and interdependent components: build sequentially.** Losing a
  component that others instance poisons everything downstream.
- **Independent leaf work (whole screens referencing only existing components): parallel is fine**
  — under the verify-and-repair loop above, since a lost screen is cheap to redo.
- Keep each `use_figma` call small (~10 logical operations). Large calls fail more often.

### API gotchas that contradict the docs

- `addComponentProperty(name, 'INSTANCE_SWAP', value)` needs the component's **node ID** (`'4:4'`),
  **not** its `.key`. Passing `.key` throws "Property value is incompatible with component property
  type".
- **Icon/vector colour must be set on the inner `VECTOR` children, not the instance frame.** Setting
  `strokes` on the icon instance frame leaves the glyph its original colour *and* draws a 1px box
  around it.
- **Nested instance overrides render the paint's BASE colour, not the bound variable.**
  `setBoundVariableForPaint({color:{r:0,g:0,b:0}}, …)` inside an instance-within-an-instance renders
  **black** even though `boundVariables` reports the alias correctly. Fix: seed the paint's base
  colour with the **resolved RGB** *and* keep the alias. Semantic variables hold a `VARIABLE_ALIAS`
  rather than RGB, so resolution must follow the alias chain.
- `INSTANCE_SWAP` **renames** the swapped child, so `query('[name=icon]')` returns null. Look
  children up by type.
- Figma allows only **one `defaultValue` per set-level TEXT property**, shared by every variant. Use
  tone-agnostic defaults; put specific copy in instance overrides.
- `layoutSizing = 'FILL'` is invalid on a component-set root — roots must be FIXED.
- `get_screenshot` lags behind freshly created nodes; inline `await node.screenshot()` is reliable.

## Git Operations

### Merging strategy

Always try to use rebase insteaf of merge when updating branches to keep a clean history.

## Commit messages

When writing commit messages, follow this format:

```<type>(<scope>): <subject>```

The subject should be a single line, containging only a broad description of the change. Do not include a body or any additional details in the commit message. The goal is to provide a clear and concise summary of the change without overwhelming the reader with information.

## Opening pull request using `gh pr create`

When opening a pull request, provide:

- Title: concise summary of changes
- Description: explanation of changes, motivation, and any relevant context. Include:
    - What was changed
    - Why it was changed
    - Any relevant links (e.g. issue numbers, design docs)

Keep the description small and focused on the most important information. Avoid including extraneous details or boilerplate sections that don't add value. The goal is to give reviewers a clear understanding of the changes and their rationale without overwhelming them with information.

**Do not include any of the following in the PR body, ever:**

- A "Test plan", "Testing", "How to test", "QA", or any test-checklist section. This overrides the default `gh pr create` template in your tool docs — that template is wrong for me.
- A "🤖 Generated with Claude Code" footer or any other generated-by attribution.
- A "Summary" section header — use the structure above (What changed / Why / Links) instead.

If you find yourself reaching for the default heredoc template from your Bash tool's `gh pr create` example, stop. Build the body from the structure above only.

## Implementing features

When you implemented a feature, make sure to test it yourself if possible in a browser using the agent browser.

When you are done with the implementation, use toe /roast skill to review the code and ensure that it follows the coding standards and best practices.
