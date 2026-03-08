# Output Format Templates

## Code Review Output

```markdown
## Review: [target description]

### Summary
[1-2 sentences: what was reviewed, overall assessment]

### Findings

#### Critical (must fix before merge)
- **[Title]** (`file:line`, confidence: [score]) — [description]. **Fix:** [concrete remediation]

#### Important (should fix)
- **[Title]** (`file:line`, confidence: [score]) — [description]. **Fix:** [concrete remediation]

#### Minor (consider fixing)
- **[Title]** (`file:line`, confidence: [score]) — [description]. **Fix:** [concrete remediation]

### What Passed
- [Explicit list of things reviewed that looked correct]

### Recommendation
[Proceed / Fix critical issues first / Needs rework]
```

## Plan Review Output

```markdown
## Review: [plan description]

### Summary
[1-2 sentences: what was reviewed, overall assessment]

### Verification

| Claim | Status | Side Effects | Notes |
|-------|--------|-------------|-------|
| [claim from plan] | Correct / Incorrect / Unverifiable | [breaks tests? violates conventions?] | [details] |

### Issues Found

#### Critical (must fix before implementation)
- **[Title]** (`file:line`, confidence: [score]) — [description]. **Fix:** [concrete remediation]

#### Important (should fix)
- **[Title]** (`file:line`, confidence: [score]) — [description]. **Fix:** [concrete remediation]

#### Minor (consider fixing)
- **[Title]** (`file:line`, confidence: [score]) — [description]. **Fix:** [concrete remediation]

### What the Plan Gets Right
- [Explicit list of verified claims and sound decisions]

### Recommendation
[Proceed with implementation / Fix issues first / Needs rework]
```