# x-impl

A local, agent-agnostic engineering workflow harness. Eight skills, a
bootstrap index, a per-harness tool adapter, and a shell installer. It runs on
Claude Code, Codex CLI, OpenCode and OpenClaw, and it talks to nothing.

## Philosophy

**A thread you follow, not a cage.** These skills describe how work goes well.
They do not seize control of the session, and nothing here shouts at the model
to make it comply.

**An index, not orders.** The bootstrap lists what exists and when each thing is
useful. Picking the right one is still a judgement call.

**User instructions win.** AGENTS.md, CLAUDE.md, and anything the user asks for
directly override these skills. The skills in turn override default habits.
Nothing here owns someone else's process.

**Actions, not tools.** Skill bodies say "dispatch a subagent" and "run a shell
command". `adapters/<harness>.md` maps those to the tools a given harness
actually has. One skill body, four harnesses, no edits.

**Evidence before claims.** Nothing is done, fixed or passing until the command
that proves it has been run in this turn and its output read. A subagent's
report is a claim; a green run from an hour ago proves the tree it ran on.

## The pipeline

```
x-conclave → x-plan → x-build → x-land
```

Join it wherever the work starts; skip what does not apply.

| Skill | For |
|---|---|
| `x-impl` | The index itself, as a loadable skill. |
| `x-conclave` | Settling an open-ended design — autonomously, or by grilling you. |
| `x-plan` | Turning a design into small verifiable tasks. |
| `x-build` | Isolating the workspace and running the work: per task, inline, or several independent problems in parallel. |
| `x-tdd` | Red / green / refactor. |
| `x-debug` | Root cause before fixes. |
| `x-answer` | Handling review feedback technically. |
| `x-land` | Verifying, reviewing, and landing the work. |

`x-impl` is the only skill you invoke yourself. The other seven carry
`user-invocable: false`: the model loads them when the work calls for them, but
they are not slash commands. Claude Code and OpenClaw enforce this. OpenCode
ignores the flag, and Codex has no equivalent, so there they stay reachable by
name.

`x-tdd` and `x-debug` are what `x-build` uses inside each task. `x-answer`
handles whatever a review sends back, from a reviewer subagent, a colleague, or
a PR thread. For a review without a landing, ask for a review only; `x-land` then runs its
review step alone.

### The conclave

`x-conclave` is the piece that differs most from a normal design interview. A
closed council: the questions get deliberated privately, and the session comes
back out with decisions.

The session model builds the decision tree, resolves one branch at a time, looks
the facts up — facts are never asked — and drafts every question with real
options and a recommendation. Then one of two things happens.

**Auto, the default.** The answers come from a **decider**: a subagent pinned to
the strongest reasoning configuration available, returning an answer, a
rationale, a confidence level, and an escalate flag. Only six things get
escalated: irreversible or outward-facing work, spending money, security and
privacy, genuinely ambiguous intent, a conflict with an explicit instruction,
and the decider's own low confidence. Escalations go out once, as a batch, at
the end, each as a yes/no or a pick-one with the recommendation first. Zero
escalations means the session does not stop at all. When nobody can answer, it
proceeds on the recommendation and tags the row `ASSUMED`, which `x-land`
re-surfaces before anything outward-facing.

**Interactive.** Ask to be grilled and you answer every question yourself, one
at a time, each with the recommendation attached. Same tree, same log — it is
simply auto mode with every question escalated.

Either way it ends in a design doc with a decision log, and a `Decided by`
column saying which rows were yours. Overriding one row reopens only that
branch.

## Install

Copy this command to install for your user across all four harnesses:

```sh
curl -fsSL https://raw.githubusercontent.com/WEEFAA/x-impl/master/install.sh | sh
```

Start a fresh session and ask it to **use x-impl**. The eight skills and their
adapters are available immediately. Re-run the command to update. From an
existing checkout, `sh install.sh` performs the same installation offline.

### Installer flags

Append options after `sh -s --` when piping the installer, or after
`sh install.sh` from a checkout.

| Flag | Effect |
|---|---|
| `--global` | Install in your user skill directories. This is the default and leaves your project alone. |
| `--project DIR` | Install the skills into that project's harness directories. |
| `--harness NAME` | Select `claude`, `codex`, `opencode`, or `openclaw`. Default: `all`. |
| `--copy` | Store independent copies instead of symlinks. Project installs that include OpenClaw automatically copy the shared agent skills. |
| `--bootstrap` | With `--project DIR`, add one startup reminder to an existing AGENTS.md or CLAUDE.md. Use this if you want new sessions in that project to load x-impl automatically. Adapters come with every install. |
| `--uninstall` | Remove managed skills and startup reminders for the selected scope. Saved work stays on disk. |
| `--dry-run` | Preview the selected install or uninstall without writing files. |
| `-h`, `--help` | Show installer usage. |

### Where files go

Downloaded versions live under `~/.x-impl/releases/`. The installer points
`~/.x-impl/current` at the selected version. To uninstall the default setup,
run `sh ~/.x-impl/current/install.sh --uninstall`. For a project installation,
supply the same scope and harness you used to install.

Designs, plans, ledgers, and review diffs live on the host under
`${XDG_STATE_HOME:-$HOME/.local/state}/x-impl/`, grouped by repository.
Linked worktrees share that state, so landing can finish after a worktree is
removed. Set `X_IMPL_STATE_DIR` to an absolute directory to move it. A temporary
directory works for disposable runs, but the OS can clear it between sessions.
Existing plans and ledgers can still be resumed by their original paths.

The download defaults to the latest checksummed release. Before the first
release, the installer uses Git to fetch `master` and stores it by commit.
`X_IMPL_VERSION` pins a release, `X_IMPL_HOME` moves the download directory,
and `X_IMPL_REPO` selects a fork. Set these variables in the installer's
environment.

## Harnesses

Use the command for your harness if you only want to install there.

### Claude Code

```sh
curl -fsSL https://raw.githubusercontent.com/WEEFAA/x-impl/master/install.sh | sh -s -- --harness claude
```

Installs in `~/.claude/skills/`. Project installs use `.claude/skills/`. [Harness details](skills/x-impl/adapters/claude.md).

### Codex CLI

```sh
curl -fsSL https://raw.githubusercontent.com/WEEFAA/x-impl/master/install.sh | sh -s -- --harness codex
```

Installs in `~/.agents/skills/`. Project installs use `.agents/skills/`. [Harness details](skills/x-impl/adapters/codex.md).

### OpenCode

```sh
curl -fsSL https://raw.githubusercontent.com/WEEFAA/x-impl/master/install.sh | sh -s -- --harness opencode
```

Uses the same `.agents/skills/` location as Codex. Design decisions run inline until you configure a dedicated decider with your chosen reasoning model. [Decider setup for your OpenCode version](skills/x-impl/adapters/opencode.md#the-decider).

### OpenClaw

```sh
curl -fsSL https://raw.githubusercontent.com/WEEFAA/x-impl/master/install.sh | sh -s -- --harness openclaw
```

Global installs link into `~/.agents/skills/`. Project installs copy into `.agents/skills/` so the skill and its adapters stay inside the workspace. If you use a skill allowlist, include the installed `x-*` names. [Harness details](skills/x-impl/adapters/openclaw.md).

## Privacy

x-impl sends nothing anywhere, and the skills themselves never reach the
network at all.

- No telemetry, analytics, usage reporting, or version beacons of any kind.
- No server, no background process, no browser companion, no auto-update, no
  marketplace manifests.
- No URLs anywhere in the skills, the adapters, or the index.
- No runtime dependencies. The installer is POSIX `sh` and touches only the
  paths named above.

The one-line installer contacts GitHub to download the requested version and
verify released archives. Running from a checkout is offline. Harness-specific
telemetry details are in the linked adapters.

## Layout

```
x-impl.md            the bootstrap index
skills/x-impl/adapters/  action vocabulary + one file per harness
skills/x-*/          the eight skills
install.sh           POSIX sh installer
scripts/             release preflight and build (not shipped)
.github/workflows/   the release workflow (not shipped)
docs/authoring.md    writing and editing skills in this style
docs/porting.md      wiring x-impl into another harness
```

## Releasing

Releases are cut from `master`, by tag.

```sh
sh scripts/release-check.sh      # preflight, locally, first
git tag v1.2.3
git push origin v1.2.3
```

`release-check.sh` parses `install.sh`, checks every skill's frontmatter,
resolves the relative paths skills point at, rejects any URL that is not one of
x-impl's own release URLs in `install.sh` or this README, and runs the
installer end to end in a scratch directory — install, re-install, uninstall —
so a broken release fails on your machine rather than in CI.

Pushing a `v*` tag runs `.github/workflows/release.yml`. It refuses the tag
unless it is `vMAJOR.MINOR.PATCH` (an optional `-suffix` marks a prerelease)
*and* its commit is an ancestor of `origin/master`. Then it runs the same
preflight, builds `dist/`, and publishes a GitHub release:

```
x-impl-v1.2.3.tar.gz   README, LICENSE, x-impl.md, install.sh, docs/, skills/
NOTES.md               commits since the previous v* tag
SHA256SUMS             verify with `shasum -a 256 -c SHA256SUMS`
```

The tarball is built with `git archive`, so the same tag produces the same
bytes on any machine. The workflow will not overwrite a release that already
exists — delete it by hand, or cut a new tag.

Build the artifacts locally with `sh scripts/release-build.sh v1.2.3`.

## Writing your own

The conventions these eight follow — the frontmatter contract, trigger-first
descriptions, the action vocabulary, the announce rule, picking the form that
matches the failure — are in `docs/authoring.md`. Read it before adding a ninth
skill, and check first whether what you want is a section of an existing one.

## Licence

MIT. See `LICENSE`.
