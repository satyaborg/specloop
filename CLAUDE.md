# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

specloop is a single Bash script (`./specloop`) that wraps Claude Code to do spec-driven development. It interviews the user, writes a spec, then runs an autonomous actor-critic loop (build → review → fix) until the critic accepts or the loop stalls. The critic has zero context from the actor — only the spec and the diff.

## Commands

```bash
# Install to /usr/local/bin
make install

# Run directly
./specloop "feature description"
./specloop "feature description" 5      # max 5 iterations
./specloop "feature description" 5 1    # bail after 1 stall

# Lint
shellcheck specloop
```

## Architecture

The entire tool is one file: `specloop` (Bash). There are no modules, no build step, no tests.

### Flow

1. **Branch** — creates `specloop/<slug>` from `MAIN_BRANCH`
2. **Interview** — interactive Claude session using `AskUserQuestion` tool; writes `specs/<slug>.md` and `specs/<slug>-decisions.md`
3. **Actor** — headless `claude -p` with `Read,Write,Bash` tools; implements the spec or applies fix instructions
4. **Critic** — headless `claude -p` with `Read,Bash,Write` tools; reviews `git diff $MAIN_BRANCH` against the spec; writes `specs/<slug>-review.md`
5. **Loop** — parses verdict (`ACCEPT`/`REJECT`/`UNCLEAR`), tracks stall count, loops or exits

### Key functions

- `interview()` — runs Claude interactively (not `-p`); takes mode `"initial"` or `"clarify"`
- `run_headless()` — runs `claude -p` with tool allowlists; tees output to the log
- `build_actor_prompt()` — generates different prompts for initial build vs fix iterations
- `save_state()` / resume logic — persists iteration state to `specs/<slug>-state.json` for resumability

### Artifacts (in `specs/`)

| File | Purpose |
|------|---------|
| `<slug>.md` | The spec |
| `<slug>-decisions.md` | Resolved tradeoffs |
| `<slug>-review.md` | Latest critic verdict |
| `<slug>-loop.log` | Full actor/critic output |
| `<slug>-state.json` | Loop state for resume |

### Environment variables

`MAX`, `STALL_LIMIT`, `SPEC_DIR`, `MAIN_BRANCH`, `SKIP_INTERVIEW`, `MODEL` — see script header or README for defaults.

### Exit codes

- `0` — accepted
- `1` — needs human input (unclear spec)
- `2` — stalled or max iterations

### Dependencies

`gum`, `glow`, `claude` (Claude Code CLI). The script auto-installs `gum` and `glow` via Homebrew if missing.
