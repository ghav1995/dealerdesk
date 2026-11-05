#!/usr/bin/env bash
# Fails unless the version is exactly the base branch version plus 0.1.
# The version comes from the screen header, because that is what staff see.
#
#   check-version.sh <base-ref>
set -euo pipefail

old="$(git grep -h -o -E 'DEALERDESK v[0-9]+\.[0-9]+' "$1" -- '*.c' | head -1 | cut -d' ' -f2)"
new="$(make -s version)"
expected="${old%.*}.$((${old##*.} + 1))"

if [ "$new" != "$expected" ]; then
    echo "::error::Version is $new, but must be $expected ($old on the base branch plus 0.1)."
    exit 1
fi
echo "Version is correct: $old to $new"
