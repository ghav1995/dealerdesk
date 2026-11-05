#!/usr/bin/env bash
# Merges a pull request, then tags its version from master with a full description.
# Pushing the tag starts the CD pipeline. Safe to run again: a pull request that is
# already merged goes straight to tagging, and a finished tag is left alone.
#
#   merge-and-tag.sh check <pr>              report what would happen, change nothing
#   merge-and-tag.sh run <pr> <notes-file>   check, merge, tag and push
set -euo pipefail

die() {
    echo "merge-and-tag: $1" >&2
    exit 1
}

mode="${1:-}"
pr="${2:-}"
notes="${3:-}"
case "$mode" in
    check) [ -n "$pr" ] || die "usage: merge-and-tag.sh check <pr>" ;;
    run) [ -n "$pr" ] && [ -f "$notes" ] || die "usage: merge-and-tag.sh run <pr> <notes-file>" ;;
    *) die "usage: merge-and-tag.sh check <pr> | run <pr> <notes-file>" ;;
esac

command -v gh >/dev/null || die "gh is not on PATH."
cd "$(git rev-parse --show-toplevel)"

# Always the fork: on a fork, gh can otherwise default to the parent repository.
repo="$(git config --get remote.origin.url)"
repo="${repo#*github.com[:/]}"
repo="${repo%.git}"

load_pr() {
    IFS=$'\t' read -r state base cross draft merge_state head_oid url merge_oid < <(
        gh pr view "$pr" --repo "$repo" \
            --json state,baseRefName,isCrossRepository,isDraft,mergeStateStatus,headRefOid,url,mergeCommit \
            --jq '[.state,.baseRefName,.isCrossRepository,.isDraft,.mergeStateStatus,.headRefOid,.url,(.mergeCommit.oid // "")] | @tsv' |
            tr -d '\r') || true
    [ -n "${state:-}" ] || die "could not read pull request $pr on $repo."
}

version_at() {
    git grep -h -o -E 'DEALERDESK v[0-9]+\.[0-9]+' "$1" -- '*.c' | awk 'NR == 1 { print $2 }'
}

remote_tag_commit() {
    git ls-remote origin "refs/tags/$1^{}" | cut -f1
}

check_open_pr() {
    [ "$base" = master ] || die "pull request $pr targets $base, not master."
    [ "$cross" = false ] || die "pull request $pr comes from another repository."
    [ "$draft" = false ] || die "pull request $pr is a draft."
    [ "$merge_state" = CLEAN ] ||
        die "pull request $pr is not ready to merge: GitHub reports $merge_state. The test check must pass and the branch must be up to date with master."

    git fetch -q origin "refs/pull/$pr/head"
    version="$(version_at "$head_oid")"
    [ -n "$version" ] || die "could not find the version in pull request $pr."
    [ -z "$(remote_tag_commit "$version")" ] ||
        die "$version is already tagged, so pull request $pr needs its own version."
}

previous_tag() {
    git describe --tags --abbrev=0 --match 'v*' "$1" 2>/dev/null || true
}

git fetch -q --tags origin master
load_pr

if [ "$mode" = check ]; then
    [ "$state" = OPEN ] || [ "$state" = MERGED ] || die "pull request $pr is $state."
    if [ "$state" = OPEN ]; then
        check_open_pr
        echo "Ready to merge pull request $pr as $version."
        echo "Previous tag: $(previous_tag origin/master)"
    else
        version="$(version_at "$merge_oid")"
        echo "Pull request $pr is merged at $merge_oid as $version."
        echo "Tagged at: $(remote_tag_commit "$version")"
    fi
    exit 0
fi

case "$state" in
    OPEN)
        check_open_pr
        bash .github/scripts/check-tag-notes.sh "$version" "$notes"

        # Never squash: the individual commits are read as part of the work. The head
        # commit is pinned so a late push cannot merge code nobody has checked.
        gh pr merge "$pr" --repo "$repo" --merge --match-head-commit "$head_oid"

        for _ in 1 2 3 4 5 6 7 8 9 10; do
            load_pr
            [ "$state" = MERGED ] && [ -n "$merge_oid" ] && break
            sleep 3
        done
        [ "$state" = MERGED ] && [ -n "$merge_oid" ] ||
            die "pull request $pr did not merge. Nothing was tagged. Its state is $state."
        ;;
    MERGED)
        [ -n "$merge_oid" ] || die "pull request $pr has no merge commit."
        ;;
    *)
        die "pull request $pr is $state."
        ;;
esac

git fetch -q --tags origin master
git merge-base --is-ancestor "$merge_oid" origin/master || die "$merge_oid is not on master."
version="$(version_at "$merge_oid")"
[ -n "$version" ] || die "could not find the version at $merge_oid."
bash .github/scripts/check-tag-notes.sh "$version" "$notes" ||
    die "fix the description and run this again. The merge is done, so it will not repeat."

tagged="$(remote_tag_commit "$version")"
if [ "$tagged" = "$merge_oid" ]; then
    echo "$version is already tagged on $merge_oid. Nothing to do."
    exit 0
fi
[ -z "$tagged" ] || die "$version is already tagged on $tagged, not $merge_oid."

message="$(mktemp)"
trap 'rm -f "$message"' EXIT
previous="$(previous_tag "$merge_oid^1")"
{
    tr -d '\r' < "$notes"
    echo
    echo "## Change record"
    echo
    echo "Pull request: $url"
    echo "Merge commit: $merge_oid"
    if [ -n "$previous" ]; then
        echo "Compared with $previous: $(git rev-list --count "$previous..$merge_oid") commits,$(git diff --shortstat "$previous" "$merge_oid")"
        echo
        git log --no-merges --format='- %h %s' "$previous..$merge_oid"
    fi
} > "$message"

# The default cleanup would strip every "## " heading as a comment. --force only
# replaces a local tag left by a push that failed, because origin has none.
git tag --force --annotate --cleanup=whitespace --file "$message" "$version" "$merge_oid"
git push -q origin "refs/tags/$version"

[ "$(remote_tag_commit "$version")" = "$merge_oid" ] || die "the tag did not reach origin."
echo "Merged pull request $pr and tagged $version on $merge_oid."
echo "CD has started: https://github.com/$repo/actions/workflows/cd.yml"
