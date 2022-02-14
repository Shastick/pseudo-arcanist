#!/usr/bin/env bash

repo_root=$(git rev-parse --show-toplevel)
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

# Look up the current branch...
curr_branch=$(git rev-parse --abbrev-ref HEAD)

# Is there a corresponding MR?
# Run via script to capture color output
# Note: glab shoes different output depending on if it thinks it is displaying stuff in a terminal or not
# TODO check that the script under OS X is the same as under linux...
# TODO if there are multiple corresponding MRs, consider improving the handling?
temp_file=$(mktemp -t parc)
echo | script -q "$temp_file" glab mr view >/dev/null
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "No MR corresponding to $curr_branch was found."
    rm "$temp_file"
    exit 1
fi

mr_id=$(tail -n2 "$temp_file" | head -n1 | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | rev | cut -d "/" -f1 | rev)

echo "MR ID: $mr_id"

# Compare local branch to remote one
# We could consider simply force pushing but it's interesting to tell the user
# that the local content does not match what is displayed in the MR
# TODO Consider doing git_status=$(git status -sb --porcelain=v2) and echoing?
remote_branch=$(git status -sb --porcelain=v2 | grep "# branch.upstream " | cut -d " " -f3)
commit_difference=$(git status -sb --porcelain=v2 | grep "# branch.ab " | cut -d " " -f 3-)

echo "Remote branch is: $remote_branch"
if [ "$commit_difference" != "+0 -0" ]; then
    echo "Remote and local branch content differ. Please update the remote first."
    exit 1
fi

# At this point we can land the MR

echo "Local and remote branch are in sync."
echo "Landing the following MR:"
cat "$temp_file"
rm "$temp_file"

# TODO check it is in an accepted state?
# TODO configurable merge strategy
glab mr merge -s

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Merging failed, aborting land sequence."
    exit 1
fi

mr_state=$(glab mr view "$mr_id" | grep "state:" | cut -f2)
if [ "$mr_state" != "merged" ]; then
    echo "MR was not merged properly, aborting land sequence."
    exit 1
fi

after_land="main"
if [ -f "$repo_root/.parcrc" ]; then
    rc_after_land=$("checkout-after-land" "$repo_root/.parcrc" | cut -d "=" -f2)
    if [ "$rc_after_land" != "" ]; then
        after_land=$rc_after_land
    fi
fi

echo "Pulling branch $after_land and cleaning up..."
git checkout main
git pull
git branch -D "$curr_branch"
