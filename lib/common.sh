#!/usr/bin/env bash
# Shared helpers for bash-utils scripts.
# Source this file; do not execute it directly.

#######################################
# Colors
#######################################

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

#######################################
# Logging
#######################################

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

die() {
    error "$1"
    exit 1
}

#######################################
# Requirements
#######################################

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        die "Required command not found: $1"
    fi
}

require_file() {
    if [[ ! -f "$1" ]]; then
        die "Required file not found: $1"
    fi
}

#######################################
# Steps
#######################################

run_step() {
    local description="$1"
    shift

    log "$description"

    "$@"

    success "$description completed"
}

#######################################
# Repository discovery
#######################################

find_git_root() {
    local root
    root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        die "Not inside a git repository"
    }
    echo "$root"
}

cd_to_git_root() {
    local root
    root="$(find_git_root)"
    cd "$root" || {
        die "Failed to change directory to: $root"
    }
    log "Working in repository: $root"
}
