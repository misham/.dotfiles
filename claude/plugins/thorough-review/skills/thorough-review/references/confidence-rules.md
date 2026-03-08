# Confidence Scoring Rules

## Confidence Scoring

Each finding gets a confidence score (0-100). Only findings scoring >= 75 are reported. Scores are shown in the output so users can calibrate trust.

| Score Range | Meaning |
|-------------|---------|
| 0-25 | Likely false positive — do not report |
| 26-50 | Minor nitpick — do not report |
| 51-74 | Valid but low confidence — do not report |
| 75-89 | Important finding — report |
| 90-100 | Critical finding — report |

## Confidence Penalties (subtract from base score)

| Condition | Penalty |
|-----------|---------|
| Finding relies on a function definition not yet read | -20 |
| Finding is purely stylistic and not covered by CLAUDE.md or project linter | -30 |
| Fix involves changing a library dependency | -50 |
| Finding is about code not in the current changeset | -20 |
| Finding contradicts a pattern in `project_conventions` | -40 |

## Confidence Boosters (add to base score)

| Condition | Boost |
|-----------|-------|
| Finding backed by a grep search confirming the call site | +20 |
| Pattern matches a `missed_pattern` from local.md or global.md | +20 |
| Finding verified by reading both caller and callee | +15 |
| Issue reproduces a known bug pattern from the project | +10 |

## False Positive Definitions — Do NOT Report

- Pre-existing issues in unchanged code
- Style/formatting issues catchable by linters
- Missing tests for code that wasn't changed
- Intentional design decisions documented in CLAUDE.md or comments
- Patterns listed in the project's `thorough-review.local.md` false_positives list
- Patterns listed in `~/.claude/thorough-review.global.md` false_positives list