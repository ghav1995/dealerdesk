#!/usr/bin/env bash
# Compares the scenario names in the specs with the tests that assert them.
#
#   check-coverage.sh            report any gaps
#   check-coverage.sh --strict   also fail if there are any
#
# Every scenario in openspec/specs needs a test, apart from those under a requirement
# that an active change removes. Scenarios that only exist in an active change are
# reported as pending, and become mandatory when that change is archived.
#
# A scenario covered by a unit test names it in a comment: /* Scenario: <name> */
set -uo pipefail
export LC_ALL=C

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../../../.." && pwd)"
specs_dir="$root/openspec/specs"
changes_dir="$root/openspec/changes"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# Lists "capability|requirement" for each requirement an active change removes.
find "$changes_dir" -path '*/specs/*/spec.md' -not -path '*/archive/*' | while IFS= read -r file; do
    capability="${file#"$changes_dir"/*/specs/}"
    capability="${capability%/spec.md}"
    awk -v capability="$capability" '
        /^## / { removing = ($0 == "## REMOVED Requirements") }
        removing && /^### Requirement: / {
            sub(/^### Requirement: /, "")
            print capability "|" $0
        }
    ' "$file"
done > "$work/removed"

# The main spec scenarios that must have a test.
find "$specs_dir" -name spec.md | while IFS= read -r file; do
    capability="${file#"$specs_dir"/}"
    capability="${capability%/spec.md}"
    awk -v capability="$capability" -v removed="$work/removed" '
        BEGIN { while ((getline line < removed) > 0) gone[line] = 1 }
        /^### Requirement: / {
            name = $0
            sub(/^### Requirement: /, "", name)
            skipping = ((capability "|" name) in gone)
        }
        /^#### Scenario: / && !skipping {
            sub(/^#### Scenario: /, "")
            print
        }
    ' "$file"
done | sort -u > "$work/required"

find "$changes_dir" -name spec.md -not -path '*/archive/*' -print0 \
    | xargs -0 sed -n 's/^#### Scenario: //p' | sort -u > "$work/active"

find "$specs_dir" -name spec.md -print0 \
    | xargs -0 sed -n 's/^#### Scenario: //p' | sort -u > "$work/main"

sort -u "$work/main" "$work/active" > "$work/known"

{
    sed -n 's/^Scenario "\(.*\)"$/\1/p' "$here"/scenarios/*.sh
    sed -n 's|^.*/\* Scenario: \(.*\) \*/.*$|\1|p' "$root"/app/tests/unit/test_*.c
} | sort > "$work/tests"

untested="$(comm -23 "$work/required" "$work/tests")"
unknown="$(comm -13 "$work/known" "$work/tests")"
repeated="$(uniq -d "$work/tests")"
pending="$(comm -23 "$work/active" "$work/required" | comm -23 - "$work/tests")"

echo "$(wc -l < "$work/required") spec scenarios, $(wc -l < "$work/tests") tests"
[ -z "$untested" ] || { echo "No test for:"; echo "$untested" | sed 's/^/  /'; }
[ -z "$unknown" ] || { echo "No spec scenario for:"; echo "$unknown" | sed 's/^/  /'; }
[ -z "$repeated" ] || { echo "More than one test for:"; echo "$repeated" | sed 's/^/  /'; }
[ -z "$pending" ] || { echo "Pending in an active change:"; echo "$pending" | sed 's/^/  /'; }

if [ "${1:-}" = "--strict" ] && [ -n "$untested$unknown$repeated" ]; then
    exit 1
fi
exit 0
