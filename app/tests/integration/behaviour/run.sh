#!/usr/bin/env bash
# Runs the Given/When/Then scenarios against the real binary.
#
#   run.sh <binary>            run every scenario
#   run.sh <binary> <file>     run one file from scenarios/
#
# Each scenario gets a private copy of fixtures/data, so app/data is never touched.
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
fixtures="$here/../fixtures/data"
repo_root="$(cd "$here/../../../.." && pwd)"

. "$here/steps.sh"

if [ $# -ge 2 ]; then
    . "$here/scenarios/$2"
else
    for file in "$here"/scenarios/*.sh; do
        . "$file"
    done
fi
finish_scenario

echo "$scenarios_passed passed, $scenarios_failed failed"
[ "$scenarios_failed" -eq 0 ]
