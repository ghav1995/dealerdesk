#!/usr/bin/env bash
# Compares the scenario names in the specs with the tests that assert them.
#
#   check-coverage.sh            report any gaps
#   check-coverage.sh --strict   also fail if there are any
#
# A scenario covered by a unit test names it in a comment: /* Scenario: <name> */
set -uo pipefail
export LC_ALL=C

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../../../.." && pwd)"
specs="$(mktemp)"
tests="$(mktemp)"
trap 'rm -f "$specs" "$tests"' EXIT

find "$root/openspec/specs" "$root/openspec/changes" -name spec.md -not -path '*/archive/*' -print0 \
    | xargs -0 sed -n 's/^#### Scenario: //p' | sort -u > "$specs"

{
    sed -n 's/^Scenario "\(.*\)"$/\1/p' "$here"/scenarios/*.sh
    sed -n 's|^.*/\* Scenario: \(.*\) \*/.*$|\1|p' "$root"/app/tests/unit/test_*.c
} | sort > "$tests"

untested="$(comm -23 "$specs" "$tests")"
unknown="$(comm -13 "$specs" "$tests")"
repeated="$(uniq -d "$tests")"

echo "$(wc -l < "$specs") spec scenarios, $(wc -l < "$tests") tests"
[ -z "$untested" ] || { echo "No test for:"; echo "$untested" | sed 's/^/  /'; }
[ -z "$unknown" ] || { echo "No spec scenario for:"; echo "$unknown" | sed 's/^/  /'; }
[ -z "$repeated" ] || { echo "More than one test for:"; echo "$repeated" | sed 's/^/  /'; }

if [ "${1:-}" = "--strict" ] && [ -n "$untested$unknown$repeated" ]; then
    exit 1
fi
exit 0
