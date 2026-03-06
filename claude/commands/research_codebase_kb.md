---
description: Research codebase and store findings in kb database
model: opus
argument-hint: [research query]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(~/.claude/bin/kb:*), Bash(git:*), Bash(gh:*), Bash(~/.claude/scripts/*), Agent, TodoWrite
---

# Research Codebase (KB)

You are tasked with conducting comprehensive research across the codebase to answer user questions by spawning parallel sub-agents and synthesizing their findings. Research results are stored in a `kb` database instead of markdown files.

If `$ARGUMENTS` is provided, use it as the research query and skip the Initial Setup prompt. Otherwise, follow the Initial Setup step below.

## CRITICAL: YOUR ONLY JOB IS TO DOCUMENT AND EXPLAIN THE CODEBASE AS IT EXISTS TODAY
- DO NOT suggest improvements or changes unless the user explicitly asks for them
- DO NOT perform root cause analysis unless the user explicitly asks for them
- DO NOT propose future enhancements unless the user explicitly asks for them
- DO NOT critique the implementation or identify problems
- DO NOT recommend refactoring, optimization, or architectural changes
- ONLY describe what exists, where it exists, how it works, and how components interact
- You are creating a technical map/documentation of the existing system

## KB Tool

The `kb` CLI is available at `~/.claude/bin/kb`. The database path should always be specified with `--db kb.db` relative to the project root. Use `--plain` for machine-readable output.

Key commands:
- `~/.claude/bin/kb search <query> --db kb.db --plain` — Search existing knowledge
- `~/.claude/bin/kb search <query> -t research --db kb.db --plain` — Search only research documents
- `~/.claude/bin/kb list --db kb.db --plain` — List all documents
- `~/.claude/bin/kb list -t research --db kb.db --plain` — List research documents
- `~/.claude/bin/kb get <id> --db kb.db --plain` — Get a document by ID
- `~/.claude/bin/kb import <file> -t research --db kb.db --plain` — Import a markdown file as research
- `~/.claude/bin/kb links <id> --db kb.db --plain` — Show linked documents
- `~/.claude/bin/kb link <id1> <id2> -r related --db kb.db --plain` — Link two documents

## Initial Setup:

If no `$ARGUMENTS` was provided, respond with:
```
I'm ready to research the codebase. Please provide your research question or area of interest, and I'll analyze it thoroughly by exploring relevant components and connections.
```
Then wait for the user's research query before proceeding.

If `$ARGUMENTS` was provided, proceed immediately with it as the research query.

## Steps to follow after receiving the research query:

1. **Read any directly mentioned files first:**
   - If the user mentions specific files (tickets, docs, JSON), read them FULLY first
   - **IMPORTANT**: Use the Read tool WITHOUT limit/offset parameters to read entire files
   - **CRITICAL**: Read these files yourself in the main context before spawning any sub-tasks
   - This ensures you have full context before decomposing the research

2. **Search existing knowledge base for prior research:**
   - Run `~/.claude/bin/kb search "<relevant terms>" --db kb.db --plain` to find related prior research
   - Note the IDs and titles of relevant documents — do NOT read them inline with `kb get`
   - These will be analyzed by background agents in step 4
   - Use prior findings as supplementary context, but always verify against live code

3. **Analyze and decompose the research question:**
   - Break down the user's query into composable research areas
   - Take time to ultrathink about the underlying patterns, connections, and architectural implications the user might be seeking
   - Identify specific components, patterns, or concepts to investigate
   - Create a research plan using TodoWrite to track all subtasks
   - Consider which directories, files, or architectural patterns are relevant

4. **Spawn parallel sub-agent tasks for comprehensive research:**
   - Create multiple Task agents to research different aspects concurrently
   - We now have specialized agents that know how to do specific research tasks:

   **For kb document analysis (from step 2 results):**
   - For each relevant kb document found in step 2, spawn a **research-analyzer** background agent
   - Pass the kb document ID so it can fetch and analyze the content: "Analyze kb document <id> for insights related to <research question>"
   - These run in the background alongside codebase research agents, keeping full kb document content out of the main context

   **For codebase research:**
   - Use the **codebase-locator** agent to find WHERE files and components live
   - Use the **codebase-analyzer** agent to understand HOW specific code works (without critiquing it)
   - Use the **codebase-pattern-finder** agent to find examples of existing patterns (without evaluating them)

   **IMPORTANT**: All agents are documentarians, not critics. They will describe what exists without suggesting improvements or identifying issues.

   **For web research (only if user explicitly asks):**
   - Use the **web-search-researcher** agent for external documentation and resources
   - IF you use web-research agents, instruct them to return LINKS with their findings, and please INCLUDE those links in your final report

   **For Linear tickets (if relevant):**
   - Use the **linear-ticket-reader** agent to get full details of a specific ticket
   - Use the **linear-searcher** agent to find related tickets or historical context

   The key is to use these agents intelligently:
   - Start with locator agents to find what exists
   - Then use analyzer agents on the most promising findings to document how they work
   - Run multiple agents in parallel when they're searching for different things
   - Spawn kb document analyzers in the background alongside codebase agents
   - Each agent knows its job - just tell it what you're looking for
   - Don't write detailed prompts about HOW to search - the agents already know
   - Remind agents they are documenting, not evaluating or improving

5. **Wait for all sub-agents to complete and synthesize findings:**
   - IMPORTANT: Wait for ALL sub-agent tasks to complete before proceeding (including background kb analyzers)
   - Compile all sub-agent results (codebase research, kb document analyses, and any other findings)
   - Prioritize live codebase findings as primary source of truth
   - Use kb analyzer summaries as supplementary historical context (these are already distilled — no need to re-read full kb documents)
   - Connect findings across different components
   - Include specific file paths and line numbers for reference
   - Highlight patterns, connections, and architectural decisions
   - Answer the user's specific questions with concrete evidence

6. **Gather metadata for the research document:**
   - Run the `~/.claude/scripts/spec_metadata.sh` script to generate all relevant metadata
   - Ensure the `docs/ai/research/` directory exists: `mkdir -p docs/ai/research`
   - Prepare a temporary markdown file in `docs/ai/research/` with naming:
     - Format: `YYYY-MM-DD-ENG-XXXX-description.md` where:
       - YYYY-MM-DD is today's date
       - ENG-XXXX is the ticket number (omit if no ticket)
       - description is a brief kebab-case description of the research topic
     - Examples:
       - With ticket: `2025-01-08-ENG-1478-parent-child-tracking.md`
       - Without ticket: `2025-01-08-authentication-flow.md`

7. **Generate research document and import into kb:**
   - Write the research document as a temporary markdown file in `docs/ai/research/`
   - Structure the document with YAML frontmatter followed by content:
     ```markdown
     ---
     date: [Current date and time with timezone in ISO format]
     git_commit: [Current commit hash]
     branch: [Current branch name]
     repository: [Repository name]
     topic: "[User's Question/Topic]"
     tags: [research, codebase, relevant-component-names]
     status: complete
     last_updated: [Current date in YYYY-MM-DD format]
     last_updated_by: [Researcher name]
     ---

     # Research: [User's Question/Topic]

     **Date**: [Current date and time with timezone from step 6]
     **Git Commit**: [Current commit hash from step 6]
     **Branch**: [Current branch name from step 6]
     **Repository**: [Repository name]

     ## Research Question
     [Original user query]

     ## Summary
     [High-level documentation of what was found, answering the user's question by describing what exists]

     ## Detailed Findings

     ### [Component/Area 1]
     - Description of what exists ([file.ext:line](link))
     - How it connects to other components
     - Current implementation details (without evaluation)

     ### [Component/Area 2]
     ...

     ## Code References
     - `path/to/file.py:123` - Description of what's there
     - `another/file.ts:45-67` - Description of the code block

     ## Architecture Documentation
     [Current patterns, conventions, and design implementations found in the codebase]

     ## Related Research
     [Links to related kb documents by ID, if any were found in step 2]

     ## Open Questions
     [Any areas that need further investigation]
     ```

8. **Add GitHub permalinks (if applicable):**
   - Check if on main branch or if commit is pushed: `git branch --show-current` and `git status`
   - If on main/master or pushed, generate GitHub permalinks:
     - Get repo info: `gh repo view --json owner,name`
     - Create permalinks: `https://github.com/{owner}/{repo}/blob/{commit}/{file}#L{line}`
   - Replace local file references with permalinks in the document before importing

9. **Import into kb:**
   - Import the document into kb:
     ```bash
     ~/.claude/bin/kb import docs/ai/research/<filename>.md -t research --db kb.db --plain
     ```
   - If related kb documents were found in step 2, link them:
     ```bash
     ~/.claude/bin/kb link <new_id> <related_id> -r related --db kb.db --plain
     ```
   - Keep the markdown file in `docs/ai/research/` — it will be cleaned up separately when the feature is complete

10. **Present findings:**
   - Present a concise summary of findings to the user
   - Include key file references for easy navigation
   - Mention the kb document ID for future reference
   - Ask if they have follow-up questions or need clarification

11. **Handle follow-up questions:**
    - If the user has follow-up questions, retrieve the original document with `~/.claude/bin/kb get <id> --db kb.db --plain`
    - Write an updated version of the document to a temporary file
    - Update the frontmatter fields `last_updated` and `last_updated_by` to reflect the update
    - Add `last_updated_note: "Added follow-up research for [brief description]"` to frontmatter
    - Add a new section: `## Follow-up Research [timestamp]`
    - Spawn new sub-agents as needed for additional investigation
    - Delete the old document from kb and re-import the updated version

## Important notes:
- Always use parallel Task agents to maximize efficiency and minimize context usage
- Always run fresh codebase research - never rely solely on existing kb documents
- The kb database provides historical context to supplement live findings
- Focus on finding concrete file paths and line numbers for developer reference
- Research documents should be self-contained with all necessary context
- Each sub-agent prompt should be specific and focused on read-only documentation operations
- Document cross-component connections and how systems interact
- Include temporal context (when the research was conducted)
- Link to GitHub when possible for permanent references
- Keep the main agent focused on synthesis, not deep file reading
- Have sub-agents document examples and usage patterns as they exist
- **CRITICAL**: You and all sub-agents are documentarians, not evaluators
- **REMEMBER**: Document what IS, not what SHOULD BE
- **NO RECOMMENDATIONS**: Only describe the current state of the codebase
- **File reading**: Always read mentioned files FULLY (no limit/offset) before spawning sub-tasks
- **Critical ordering**: Follow the numbered steps exactly
  - ALWAYS read mentioned files first before spawning sub-tasks (step 1)
  - ALWAYS search kb for prior research before decomposing (step 2)
  - ALWAYS wait for all sub-agents to complete before synthesizing (step 5)
  - ALWAYS gather metadata before writing the document (step 6)
  - NEVER write the research document with placeholder values
  - ALWAYS import into kb and delete the temporary file (step 9)
- **Frontmatter consistency**:
  - Always include frontmatter at the beginning of research documents
  - Keep frontmatter fields consistent across all research documents
  - Update frontmatter when adding follow-up research
  - Use snake_case for multi-word field names (e.g., `last_updated`, `git_commit`)
  - Tags should be relevant to the research topic and components studied
