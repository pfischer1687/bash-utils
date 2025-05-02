#!/usr/bin/env bash 

# ======================================================================== 
# Script Name: git-utils.sh 
# Version: 0.1.0 
# Author: Paul Fischer 
# Description: Automates git add, commit, and push with an optional force push. 
# Requirements: Must be run inside a Git repository. 
# ======================================================================== 

set -eux # Enable debugging and exit on error 

# ------------------------------------------------------------------------ 
# Globals 
# ------------------------------------------------------------------------ 
COMMIT_MSG="" 
FORCE_FLAG=false 
ERR_CODE=1 

# ------------------------------------------------------------------------ 
# Functions 
# ------------------------------------------------------------------------ 

usage() { 
  echo "Usage: $0 -m <message> [-f]" 
  echo "  -m    <message>    The commit message (required)" 
  echo "  -f                 Optional flag to force push (use with caution)" 
  exit $ERR_CODE 
} 

parse_args() { 
  while getopts "m:f" opt; do 
    case "$opt" in 
      m) COMMIT_MSG="$OPTARG" ;; 
      f) FORCE_FLAG="true" ;; 
      *) usage ;; 
    esac 
  done 

  if [[ -z "$COMMIT_MSG" ]]; then 
    echo "ERROR: Commit message (-m) is required" 
    usage 
  fi 
} 

get_current_branch() { 
  git symbolic-ref --quiet --short HEAD || { 
    echo "ERROR: Could not determine the current branch." 
    exit "$ERR_CODE" 
  } 
} 

validate_branch() { 
  local branch 
  branch="$(get_current_branch)" 
  echo "INFO: Current branch is '$branch'" 
  if [[ "$branch" == "main" || "$branch" == "master" ]]; then 
    echo "WARNING: You are pushing directly to '$branch'." 
  fi 
} 

has_pending_changes() { 
  [[ -n "$(git status --porcelain)" ]] 
} 

confirm_force_push() { 
  echo -n "Force push? This may overwrite remote history. Continue? (y/N): " 
  read confirmation 
  [[ "$confirmation" =~ ^[Yy]$ ]] || { 
    echo "Force push aborted." 
    exit 0 
  }
} 

commit_and_push() { 
  git add -A || { echo "ERROR: Failed to stage changes."; exit "$ERR_CODE"; } 

  git commit -m "$COMMIT_MSG" || { 
    echo "ERROR: Commit failed." 
    exit $ERR_CODE 
  } 

  if [[ "$FORCE_FLAG" == true ]]; then 
    confirm_force_push 
    git push -f || { echo "ERROR: Force push failed."; exit $ERR_CODE; } 
  else 
    git push || { echo "ERROR: Push failed."; exit $ERR_CODE; } 
  fi 

  echo "SUCCESS: Changes committed and pushed successfully." 
} 

# ------------------------------------------------------------------------ 
# Main 
# ------------------------------------------------------------------------ 

main() { 
  parse_args "$@" 
  validate_branch 

  if ! has_pending_changes; then 
    echo "INFO: No changes to commit. Exiting." 
    exit 0 
  fi 

  commit_and_push 
} 

main "$@" 
