#!/usr/bin/env bash
# PreToolUse hook. Blocks a direct merge, because a merge that skips merge-and-tag
# leaves its version without a tag, and the CD pipeline only starts from a tag.
input="$(cat)"

direct_tool='"tool_name" *: *"mcp__[^"]*merge_pull_request"'
gh_merge='(^|[^[:alnum:]])gh(\.exe)?[^[:alnum:][:space:]]*[[:space:]]([^|;&]*[[:space:]])?pr[[:space:]]+merge([^[:alnum:]-]|$)'
api_merge='pulls/[^/[:space:]]+/merge([^[:alnum:]]|$)|mergePullRequest'

if printf '%s' "$input" | grep -Eq "$direct_tool|$gh_merge|$api_merge"; then
    echo "Blocked: merge pull requests with the merge-and-tag skill, which also creates the version tag that starts CD. Its script runs the merge for you." >&2
    exit 2
fi
exit 0
