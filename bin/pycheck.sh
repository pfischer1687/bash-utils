#!/usr/bin/env bash

set -Eeuo pipefail

#######################################
# Configuration
#######################################

LINT_ONLY=false
SKIP_PRECOMMIT=false
VERBOSE=false

#######################################
# Colors
#######################################

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

#######################################
# Helpers
#######################################

usage() {
    cat <<EOF
Usage:
  pycheck [options]

Runs formatting, linting, type checking, pre-commit, and tests.

Options:
  --lint-only       Run checks but skip pytest
  --no-precommit    Skip pre-commit hooks
  --verbose         Enable bash debug output
  -h, --help        Show this help message

Examples:
  pycheck
  pycheck --lint-only
  pycheck --no-precommit
EOF
}

log() {
    echo -e "${BLUE}==>${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warn() {
    echo -e "${YELLOW}!${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1" >&2
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        error "Required command not found: $1"
        exit 1
    fi
}

run_step() {
    local description="$1"
    shift

    log "$description"

    "$@"

    success "$description completed"
}

#######################################
# Argument parsing
#######################################

while [[ $# -gt 0 ]]; do
    case "$1" in
        --lint-only)
            LINT_ONLY=true
            shift
            ;;
        --no-precommit)
            SKIP_PRECOMMIT=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            set -x
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown argument: $1"
            usage
            exit 1
            ;;
    esac
done

#######################################
# Main
#######################################

main() {
    require_command uv
    require_command git

    if [[ ! -d ".git" ]]; then
        error "Not inside a git repository"
        exit 1
    fi

    if [[ -f ".venv/bin/activate" ]]; then
        log "Detected virtual environment (.venv)"
    else
        warn "No .venv found (uv will still manage environments)"
    fi

    run_step "Running Ruff auto-fixes" \
        uv run ruff check --fix

    run_step "Running Ruff formatter" \
        uv run ruff format

    run_step "Running Pyright" \
        uv run pyright

    if [[ "$SKIP_PRECOMMIT" == false ]]; then
        run_step "Running pre-commit hooks" \
            uv run pre-commit run --all-files
    else
        warn "Skipping pre-commit"
    fi

    if [[ "$LINT_ONLY" == true ]]; then
        success "Lint-only mode complete"
        exit 0
    fi

    run_step "Running pytest" \
        uv run pytest

    success "All checks passed"
}

main