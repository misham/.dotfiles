# Project Fingerprinting

## Process

Before starting any review, identify the project type to set the baseline for what constitutes a finding:

1. Check for framework markers: `Gemfile` (Rails), `package.json` (Node/React), `go.mod` (Go), `Cargo.toml` (Rust), `pyproject.toml` (Python)
2. Check CLAUDE.md for documented conventions and patterns
3. Check for typing strictness: TypeScript `strict: true`, `# typed: strict` (Sorbet), mypy config
4. Check for metaprogramming prevalence (Ruby DSLs, Python decorators, macro-heavy Rust)

## Fingerprint Categories

| Category | Indicators | Review Implications |
|----------|-----------|---------------------|
| Strict typed | TS strict, Sorbet strict, mypy strict | Type errors are critical findings |
| Dynamic/metaprogrammed | Heavy DSLs, monkey-patching, decorators | Grep for runtime behavior, don't trust static analysis alone |
| Functional style | Immutable patterns, Result types, no side effects | Mutation is a finding; missing error propagation is critical |
| Microservice | Multiple services, API contracts, message queues | Interface compatibility is critical; internal implementation is less important |
| Monolith | Single app, shared database | Side effects across modules are critical findings |