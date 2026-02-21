# specloop

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Spec-driven development on autopilot. Claude Code interviews you, writes the spec, builds it, verifies it, and loops until it's right.

## How it works

```
You ──→ Interview ──→ Spec ──→ Actor (build) ──→ Critic (verify) ──┐
                                    ↑                               │
                                    └── REJECT ─────────────────────┘
                                        ACCEPT → done
                                        UNCLEAR → re-interview → retry
```

1. **Branch** — creates a feature branch from your main branch
2. **Interview** — Claude asks you questions to produce a detailed spec
3. **Actor** — Claude implements the spec autonomously (headless)
4. **Critic** — a separate Claude instance reviews the code against the spec with no actor context
5. **Loop** — repeats until the critic accepts, the spec needs clarification, or the loop stalls

The build-review loop is an [evaluator-optimizer](https://www.anthropic.com/engineering/building-effective-agents) workflow, closely related to [CEGIS](https://en.wikipedia.org/wiki/Counterexample-guided_abstraction_refinement) in program synthesis: the actor generates, the critic finds counterexamples, and failures drive refinement.

## Prerequisites

- [gum](https://github.com/charmbracelet/gum) — interactive prompts
- [glow](https://github.com/charmbracelet/glow) — terminal markdown rendering
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — `npm install -g @anthropic-ai/claude-code`

## Install

```bash
git clone https://github.com/satyaborg/specloop.git
cd specloop
make install
```

Or just run it directly:

```bash
./specloop "add Stripe webhook handler"
```

## Usage

```bash
# basic — interview + build + review loop
specloop "add Stripe webhook handler"

# limit to 5 iterations
specloop "add Stripe webhook handler" 5

# limit to 5 iterations, bail after 1 stall
specloop "add Stripe webhook handler" 5 1
```

## Configuration

All configuration is via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `MAX` | `3` | Max build-review iterations |
| `STALL_LIMIT` | `2` | Consecutive stalls before bailing |
| `SPEC_DIR` | `specs` | Directory for spec artifacts |
| `MAIN_BRANCH` | `main` | Branch to diff against |
| `SKIP_INTERVIEW` | `0` | Set to `1` to skip interview (spec must already exist) |
| `MODEL` | *(default)* | Claude model override |

## Outputs

Each run produces artifacts in `specs/`:

| File | Contents |
|------|----------|
| `<slug>.md` | The spec |
| `<slug>-decisions.md` | Tradeoffs and resolved ambiguities |
| `<slug>-review.md` | Latest critic verdict |
| `<slug>-loop.log` | Full actor/critic output log |

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | Accepted — critic approved the implementation |
| `1` | Needs human input — unclear spec or unresolved questions |
| `2` | Stalled — no progress after repeated iterations |

## Security

The actor runs Claude Code with `--dangerously-skip-permissions`, giving it unrestricted shell access in your repo. Review the spec before the build phase starts, and run in repos you're comfortable with an AI modifying.

## License

[MIT](LICENSE)
