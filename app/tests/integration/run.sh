#!/usr/bin/env bash
# Replays scripted keystrokes against the real binary and compares what staff
# would see, plus the data files left behind, with a recorded baseline.
#
#   run.sh <binary>            compare with expected/
#   run.sh <binary> --update   rewrite expected/ from this binary
#
# Every scenario runs in a temporary copy of fixtures/data, so app/data is never
# touched. Output goes through `cat -v` so control codes stay visible in diffs.
# Today's date is masked so recorded sales stay comparable, and the version in
# the screen header is masked so a version bump does not change the baseline.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
mode="${2:-check}"
today="$(date +%F)"
passed=0
failed=0

capture() {
    local keys="$1" work="$2"
    (
        cd "$work"
        "$bin" < "$keys"
        for f in data/*.dat; do
            printf '\n--- %s\n' "$f"
            cat "$f"
        done
    ) | sed -e "s/$today/<TODAY>/g" -e 's/DEALERDESK v[0-9.]*/DEALERDESK v<VERSION>/' | cat -v
}

for keys in "$here"/scenarios/*.keys; do
    name="$(basename "$keys" .keys)"
    expected="$here/expected/$name.txt"
    work="$(mktemp -d)"
    cp -R "$here/fixtures/data" "$work/data"

    if [ "$mode" = "--update" ]; then
        capture "$keys" "$work" > "$expected"
        echo "updated  $name"
    elif [ ! -f "$expected" ]; then
        echo "MISSING  $name (no baseline recorded)"
        failed=$((failed + 1))
    elif diff -u "$expected" <(capture "$keys" "$work"); then
        echo "ok       $name"
        passed=$((passed + 1))
    else
        echo "FAILED   $name"
        failed=$((failed + 1))
    fi
    rm -rf "$work"
done

if [ "$mode" != "--update" ]; then
    echo "$passed passed, $failed failed"
    [ "$failed" -eq 0 ]
fi
