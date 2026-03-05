---
description: Implement technical plans from docs/ai/plans with verification
---

# Implement Plan

You are tasked with implementing an approved technical plan from `docs/ai/plans/`. These plans contain phases with specific changes and success criteria.

## Getting Started

When given a plan path:
- Read the plan completely and check for any existing checkmarks (- [x])
- Read the original ticket and all files mentioned in the plan
- **Read files fully** - never use limit/offset parameters, you need complete context
- Think deeply about how the pieces fit together
- Create a todo list to track your progress
- Start implementing if you understand what needs to be done

If no plan path provided, ask for one.

## Implementation Philosophy

Plans are carefully designed, but reality can be messy. Your job is to:
- Follow the plan's intent while adapting to what you find
- Implement each phase fully before moving to the next
- Verify your work makes sense in the broader codebase context
- Update checkboxes in the plan as you complete sections

When things don't match the plan exactly, think about why and communicate clearly. The plan is your guide, but your judgment matters too.

If you encounter a mismatch:
- STOP and think deeply about why the plan can't be followed
- Present the issue clearly:
  ```
  Issue in Phase [N]:
  Expected: [what the plan says]
  Found: [actual situation]
  Why this matters: [explanation]

  How should I proceed?
  ```

## Within-Phase Implementation Loop

For each change within a phase, follow a strict TDD cycle:

1. **Red**: Write a failing test first. Run it to confirm it fails for the expected reason.
2. **Green**: Write the minimum code to make the test pass. Run the test to confirm it passes.
3. **Refactor**: Clean up if needed. Re-run the test to confirm it still passes.

Rules for the loop:
- Do NOT write implementation code before a failing test exists
- Run the relevant test file after every edit — do not batch changes and test later
- If a test fails unexpectedly, STOP and diagnose before continuing. Do not move to the next change until the failure is understood and resolved.
- If your implementation approach causes repeated test failures (3+ attempts), reassess the approach rather than continuing to iterate on a broken path

This loop runs continuously within a phase. The Phase Gate Protocol (below) only triggers after all changes in the phase are complete and passing.

## Verification Approach

After implementing a phase:
- Run the success criteria checks
- Fix any issues before proceeding
- Update your progress in both the plan and your todos
- Check off completed items in the plan file itself using Edit

### Phase Gate Protocol

After completing all changes in a phase:

1. **Run all automated verification** listed in the phase's success criteria
2. **Fix any failures** before proceeding — do not move to the next phase with failing checks
3. **Mark phase as complete** (`✅ COMPLETE`) in the plan file
4. **Proceed to the next phase** — no manual verification pause between phases

If the plan explicitly requests per-phase manual verification for a specific phase, pause at that phase using the Plan Completion Gate format below. Otherwise, continue to the next phase.

### Plan Completion Gate

After ALL phases are complete and all automated checks pass:

1. **STOP implementation**
2. **Use AskUserQuestion tool** to present the final manual verification:

═══════════════════════════════════════════════════════
⏸️  ALL PHASES COMPLETE - AWAITING MANUAL VERIFICATION
═══════════════════════════════════════════════════════

All automated verification passed across [N] phases.

Manual verification steps from plan:

- [ ] Step 1
- [ ] Step 2
- [ ] ...

Reply "done" when manual verification is complete.
═══════════════════════════════════════════════════════

3. **Wait for user confirmation** before marking the plan as fully complete

### Phase Status Updates

- After automated checks pass: mark phase as `✅ COMPLETE`
- After plan completion gate: mark plan as fully complete
- Do not check off manual testing items until confirmed by the user

## If You Get Stuck

When something isn't working as expected:
- First, make sure you've read and understood all the relevant code
- Consider if the codebase has evolved since the plan was written
- Present the mismatch clearly and ask for guidance

Use sub-tasks sparingly - mainly for targeted debugging or exploring unfamiliar territory.

## Resuming Work

If the plan has existing checkmarks:
- Trust that completed work is done
- Pick up from the first unchecked item
- Verify previous work only if something seems off

Remember: You're implementing a solution, not just checking boxes. Keep the end goal in mind and maintain forward momentum.
