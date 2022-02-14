#!/usr/bin/env bash

_=$(git rev-parse --show-toplevel)
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "$PWD does not seem to be in a git repo."
    exit 1
fi

# Check there are no uncommitted changes
git_status=$(git status --porcelain=v1)

if [ "$git_status" != "" ]; then
    echo "Worktree is dirty, please commit or stash any uncommitted or untracked files:"
    echo "$git_status"
    exit 1
fi

# Force push the current branch
# TODO some user-friendly error handling if we seem to be on the main branch?
# TODO check if pre-commit is used on the pre-push hook and mention linting instead of pushing?
echo "Pushing code ..."
curr_branch=$(git rev-parse --abbrev-ref HEAD)
git push -u origin "$curr_branch" --force

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Failed to push branch. Git returned with exit code $retVal"
    exit 1
fi

# The echo is there in case a prompt is shown to select multiple MRs -> the most recent one is selected by default
# Possibly using `lab` instead of `glab` could make this easier if required
echo | glab mr view
retVal=$?
if [ $retVal -ne 0 ]; then
    glab mr create
fi
