#!/usr/bin/env bash
# Fails unless a version's description is complete. The merge-and-tag skill runs this
# before it merges and CD runs it before it deploys, because a pushed tag cannot be
# moved, so a thin description cannot be corrected later.
#
#   check-tag-notes.sh <version> <notes-file>
set -euo pipefail

version="$1"
text="$(tr -d '\r' < "$2")"
status=0

fail() {
    echo "::error::$1"
    status=1
}

case "$(printf '%s\n' "$text" | sed -n 1p)" in
    "DealerDesk $version: "?*) ;;
    *) fail "The first line must be 'DealerDesk $version: <what this version does>'." ;;
esac

for heading in \
    'Summary' \
    'Staff-visible changes' \
    'Pricing and invoices' \
    'Data files and rollback' \
    'Tests' \
    'Delivery and documentation' \
    'Not in this version'
do
    body="$(printf '%s\n' "$text" |
        awk -v heading="## $heading" '$0 == heading { on = 1; next } /^## / { on = 0 } on && NF')"
    if [ -z "$body" ]; then
        fail "Section '## $heading' is missing or empty."
    fi
done

if printf '%s\n' "$text" | grep -q 'TODO'; then
    fail "The description still has a TODO in it."
fi

exit "$status"
