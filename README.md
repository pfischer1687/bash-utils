# bash-utils

Personal developer tools for running checks and committing.

## pycheck

Runs the usual Python pre-commit checklist:

1. Ruff auto-fixes
2. Ruff format
3. Pyright
4. pre-commit (if a config is present)
5. pytest

```bash
pycheck
pycheck --lint-only
pycheck --test-only
pycheck --verbose
```

`--lint-only` runs format/lint/typecheck/pre-commit, then stops (skips pytest).
`--test-only` runs pytest only (skips format, lint, typecheck, and pre-commit).
These modes are mutually exclusive.

Pre-commit runs when `.pre-commit-config.yaml` (or `.yml`) exists at the repo root; otherwise that step is skipped with
a warning.

Requires `uv` and `git`. Works from any directory inside the repository.

## jscheck

Runs the usual frontend pre-commit checklist against an npm project:

1. discover repository
2. locate `package.json`
3. activate Node via `.nvmrc` + nvm
4. format / lint / typecheck / test / build (skip missing scripts with a warning)

```bash
jscheck
jscheck --lint-only
jscheck --test-only
jscheck --verbose
```

`--lint-only` runs format, lint, and typecheck, then stops (skips test and build).
`--test-only` runs tests only (skips format, lint, typecheck, and build).
These modes are mutually exclusive.

### Expectations

- npm only
- exactly one `package.json` in the repo (ignoring `node_modules`, `dist`, `build`)
- a `.nvmrc` next to that `package.json`
- nvm available (`NVM_DIR` or `~/.nvm`)

If a project omits a script such as `build` or `test`, that step is skipped with a warning instead of failing.

## shcheck

Discovers Bash scripts in the current git repository, then formats and lints them.

```bash
shcheck
shcheck --verbose
```

Uses:

- **shfmt** — formats scripts in place (4-space indent, case indentation)
- **ShellCheck** — static analysis / linting

Scripts are found by Bash shebang (`#!/usr/bin/env bash`, etc.), including extensionless files. Dependency and build
directories such as `.git`, `node_modules`, `dist`, `build`, `target`, `.venv`, and `vendor` are skipped.

Requires `shfmt`, `shellcheck`, and `git`. Works from any directory inside a repository.

## git-utils

Simple helper to stage, commit, and push:

```bash
git-utils -m "your commit message"
git-utils -m "your commit message" -f   # force push (prompts for confirmation)
```
