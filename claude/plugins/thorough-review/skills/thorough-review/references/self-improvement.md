# Self-Improvement Workflow

## Local Feedback File

**Location:** `.claude/thorough-review.local.md` (per-project, gitignored)

**Format:**

```yaml
---
false_positives:
  - pattern: "Missing nil check on ActiveRecord .find"
    reason: "Rails raises RecordNotFound by default"
    added: "2026-03-07"

calibrations:
  - pattern: "N+1 query"
    default_severity: "critical"
    adjusted_severity: "minor"
    reason: "Only affects admin pages with <100 records in this project"
    added: "2026-03-07"

missed_patterns:
  - description: "Check for .save vs .save! in service objects — silent failures"
    added: "2026-03-07"

project_conventions:
  - "Uses Dry::Monads — check Result wrapping on service return values"
  - "All background jobs must be idempotent"
---

# Review Notes

Any free-form notes about review patterns specific to this project.
```

## Global Feedback File

**Location:** `~/.claude/thorough-review.global.md`

**Format:**

```yaml
---
project_registry:
  - path: "/Users/misham/code/xpc-api"
    last_active: "2026-03-15"
  - path: "/Users/misham/code/ppt-compass"
    last_active: "2026-03-10"

false_positives:
  - pattern: "Missing nil check on ActiveRecord .find"
    reason: "Rails raises RecordNotFound by default"
    promoted_from: ["xpc-api", "ppt-compass", "phenoml-console"]
    promoted_at: "2026-03-15"
    confirmation_count: 7

missed_patterns:
  - description: "Check for .save vs .save! in service objects"
    promoted_from: ["xpc-api", "ppt-compass", "phenoml-console"]
    promoted_at: "2026-03-15"
    confirmation_count: 5
---
```

## Feedback Capture Mechanism

After each review, when the user identifies false positives, missed patterns, or severity miscalibrations, use the Edit tool to append entries to `.claude/thorough-review.local.md`. If the file does not exist, create it with the Write tool using the YAML frontmatter format above. Each entry includes a `pattern` or `description`, a `reason`, and an `added` date.