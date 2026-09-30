---
name: yx-review
description: Review Dart/Flutter code against the yx_architecture canon - layer flow, yx_scope DI, yx_state handle/emit, navigation and ViewModel rules - and report every violation with a concrete fix.
argument-hint: "[path to a file or package; empty means the changed files]"
allowed-tools: Read, Glob, Grep, Skill
user-invocable: true
disable-model-invocation: true
---

# Review against the yx_architecture canon

Target: `$ARGUMENTS` (when empty, review the files changed in the working tree).

Read `../yx-architecture/references/procedures/review.md` and follow it. That file is the whole
procedure: which catalogs to read for what the target contains, the order of the checks, and the
output format. The same procedure answers a plain "review this against the canon" - this command
only pins the target and the turn budget.

**Turn budget.** This command reads several reference files and then every file in the target, so it
needs more turns than a typical answer. In an interactive session that is not a concern. In
non-interactive mode (`claude -p`), pass `--max-turns 80` or more: with the default limit a review
of a 40-file package stops before producing any output.
