# Adapter: OpenCode

OpenCode has shipped two generations with different built-in tool sets. Check
your actual tool list first; this table covers both.

## Action map

| Action | v1 | v2 |
|---|---|---|
| load skill `<name>` | `skill` | `skill` |
| read a file | `read` | `read` |
| write a file | `apply_patch` | `write`, or `patch` with `patchText` |
| edit a file | `apply_patch` | `edit`, or `patch` |
| run a shell command | `bash` | `shell` |
| search | `grep`, `glob` | `grep`, `glob` |
| fetch a web page | `webfetch` | `webfetch`, `websearch` |
| dispatch a subagent | `task` with `subagent_type` | `subagent` with `agent` |
| dispatch a high-reasoning decider | `task` with a `decider` agent | `subagent` with `agent: "decider"` |
| track a todo list | `todowrite` | no todo tool — use a scratch markdown file |
| create a worktree | Git via the shell | Code Mode worktree tools when exposed, otherwise Git |

## The decider

`x-conclave`'s auto mode needs a decider. OpenCode picks a subagent's model from
the agent definition, not from the dispatch call, so the decider is a named
agent with a pinned model rather than a per-call override.

To enable the dedicated decider on OpenCode V2, copy the bundled
`adapters/opencode/decider.md` into your OpenCode agents directory. Set
`model:` to a reasoning model and variant available through your provider.
On V1, replace the template's `permissions` list with the V1 frontmatter
mapping `permission: {"*": deny, read: allow, grep: allow, glob: allow}`.
Dispatch the configured agent by name with
`skills/x-conclave/prompts/decider.md` filled in.

**No explicit decider model, agent, or dispatch tool:** run the decider pass
inline, separately labelled, with the same
answer/rationale/confidence/escalate contract, and note in the design doc that
it ran inline. Do not silently fall back to a general subagent on the session
model — that is the questioner grading its own questions.

## Worktrees

Follow **Isolate** in the installed `x-build` skill. Reuse an existing linked
worktree. If one is needed, prefer the session's native worktree capability
when available, otherwise use the skill's Git fallback.

## How the bootstrap gets loaded

1. **Skill discovery.** `install.sh` links each `skills/x-*` directory into
   `.agents/skills/` (or `~/.agents/skills/` with `--global`). OpenCode reads
   `.agents/skills`, `.claude/skills` and `.opencode/skills`, so one link set
   covers it alongside Codex.
2. `--project DIR --bootstrap` adds a reminder to an existing AGENTS.md.

A local plugin could inject the index at session start. The plugin API for that
is version-dependent and unconfirmed here, so nothing is shipped — see
`docs/porting.md`.

## Telemetry

OpenCode does not document a telemetry opt-out. x-impl itself sends nothing
anywhere, but that says nothing about the harness around it. Confirm what the
harness does before running it on a machine where that matters.
