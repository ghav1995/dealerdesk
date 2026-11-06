#!/usr/bin/env bash
# Runs the real DealerDesk and saves what staff see, one text file per screen.
#
#   bash docs/evidences/capture/capture.sh
#
# Both versions are built from git, so local changes make no difference. Each use
# case types its keystrokes into a pseudo-terminal, so answers appear as they do for
# staff, and starts from a throwaway copy of the sample data, so app/data is never
# touched. A screen that does not appear stops the script, because keystrokes out of
# step must not produce evidence of nothing.
#
# Needs Linux or WSL, for `script` from util-linux. render.js then draws the images.
set -uo pipefail
export LC_ALL=C

fleet_commit=28b4830    # pull request #4 merged, version 2.7
before_commit=4d5b7b4   # pull request #3 merged, version 2.6, the rollback target

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(git -C "$here" rev-parse --show-toplevel)" || exit 1
out="$(cd "$here/.." && pwd)/transcripts"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
work=""

fail() {
    echo "capture: $*" >&2
    exit 1
}

build() {
    mkdir -p "$tmp/$1" || fail "cannot create $1"
    git -C "$root" archive "$2" | tar -x -C "$tmp/$1" || fail "cannot unpack $2"
    make -s -C "$tmp/$1" build || fail "cannot build $2"
}

# Starts a use case from a fresh copy of the sample data.
fresh() {
    work="$(mktemp -d -p "$tmp")"
    cp -R "$tmp/v2.7/app/tests/integration/fixtures/data" "$work/data" || fail "no sample data"
    cp -R "$work/data" "$work/original" || fail "no copy of the sample data"
}

# Plays one session of a version. Each session is a new process, so a later session
# in the same use case shows what survives a restart.
play() {
    local version="$1" key
    shift
    (
        cd "$work" || exit 1
        for key in "$@"; do
            sleep 0.1
            printf '%s\n' "$key"
        done | script -qefc "$tmp/$version/app/dealerdesk" /dev/null
    ) > "$work/raw" || fail "session on $version failed: $*"
    tr -d '\r' < "$work/raw" > "$work/session.txt"
    rm -rf "$work/screens"
    mkdir "$work/screens" || fail "cannot create the screens folder"
    sed 's/\x1b\[2J\x1b\[H/\f/g' "$work/session.txt" |
        awk -v dir="$work/screens" 'BEGIN { RS = "\f" } NR > 1 { printf "%s", $0 > sprintf("%s/%03d", dir, NR - 1) }'
}

# Saves the first screen of the session that matches.
keep() {
    local name="$1" match="$2" file
    file="$(grep -lE "$match" "$work"/screens/* | head -1)"
    [ -n "$file" ] || fail "$name: no screen shows '$match'"
    cp "$file" "$out/$name.txt" || fail "cannot save $name"
}

# Adds a transcript to the images, with the lines to mark.
draw() {
    printf '%s\t%s\n' "$1" "$2" >> "$out/index.tsv"
}

# Saves a screen and adds it to the images.
shot() {
    keep "$1" "$2"
    draw "$1" "${3:-$2}"
}

# Records a command and its output as a terminal would show them, and stops if the
# output lacks the expected text.
run() {
    local name="$1" command="$2" expected="$3" output
    output="$(cd "$work" && bash -c "$command" 2>&1)"
    printf '$ %s\n%s\n' "$command" "$output" >> "$out/$name.txt"
    grep -qE "$expected" <<< "$output" || fail "$name: '$command' did not show '$expected'"
}

mkdir -p "$out" || exit 1
rm -f "$out"/*.txt "$out"/index.tsv

build v2.7 "$fleet_commit"
build v2.6 "$before_commit"

# --- UC-01 Mark an existing customer as fleet --------------------------------------
fresh
run uc01-data "grep '^2008' data/customers.dat" '\|R$'
play v2.7 2 1 "" 4 2008 "" 0 0
shot uc01-menu 'Option: 4' 'Mark / unmark fleet customer'
shot uc01-list-before 'Greenway Taxis .*Retail'
shot uc01-marked 'Customer 2008 is now a fleet customer'
run uc01-data "grep '^2008' data/customers.dat" '\|F$'
play v2.7 2 1 "" 0 0
shot uc01-list-after 'Greenway Taxis .*Fleet'

# --- UC-02 Return a fleet customer to retail ---------------------------------------
fresh
play v2.7 2 4 2008 "" 4 2008 "" 0 0
shot uc02-unmarked 'Customer 2008 is no longer a fleet customer'
run uc02-data "grep '^2008' data/customers.dat" '\|R$'
run uc02-data "cmp data/customers.dat original/customers.dat && echo 'customers.dat matches the sample data again'" 'matches'

# --- UC-03 Add a new fleet customer ------------------------------------------------
fresh
play v2.7 2 2 "Fleet Co" "01632 960125" "buying@fleetco.example" N Y "" 0 0
shot uc03-added 'Customer 2009 added' 'Fleet customer|Customer 2009 added'
run uc03-data "grep '^2009' data/customers.dat" '\|F$'
play v2.7 2 1 "" 0 0
shot uc03-list 'Fleet Co .*Fleet'
fresh
play v2.7 2 2 "Trade Co" "01632 960126" "sales@tradeco.example" Y "" 0 0
shot uc03-trade 'Customer 2009 added' 'Trade customer'
if grep -q 'Fleet customer' "$out/uc03-trade.txt"; then
    fail "uc03-trade: a trade customer was asked the fleet question"
fi

# --- UC-04 Refused: a trade customer, or an unknown customer -----------------------
fresh
play v2.7 2 4 2002 "" 4 9999 "" 0 0
shot uc04-refused 'Trade customers cannot be fleet customers'
shot uc04-unknown 'Customer not found'
run uc04-data "cmp data/customers.dat original/customers.dat && echo 'customers.dat is unchanged'" 'unchanged'

# --- UC-05 Quote a fleet customer --------------------------------------------------
fresh
play v2.7 2 4 2008 "" 0 \
    3 1002 2008 "" "" "" \
    3 1007 2008 5 1000 "" \
    3 1007 2008 20 "" "" \
    0
shot uc05-simple 'TOTAL +12901\.24' 'Fleet discount|Delivery|Registration fee|TOTAL'
shot uc05-deductions 'TOTAL +13188\.60' 'Fleet discount|Discount \(|Trade-in +-|TOTAL'
shot uc05-limit 'TOTAL +12719\.80' 'Fleet discount|Discount \(|TOTAL'

# --- UC-06 Sell to a fleet customer and view the invoice ---------------------------
fresh
play v2.7 2 4 2008 "" 0 \
    4 1002 2008 "" "" Y "" \
    4 1007 2008 5 1000 Y "" \
    0
shot uc06-sale 'Invoice 50233 created' 'Fleet discount|TOTAL|Invoice 50233 created'
run uc06-data "grep -E '^5023[34]' data/invoices.dat" '\|510\.00$'
run uc06-data "awk -F'|' '{ print \$1, NF, \"fields\" }' data/invoices.dat" '50234 12 fields'
play v2.7 5 2 50233 "" 2 50234 "" 0 0
shot uc06-invoice 'INVOICE 50233' 'Fleet discount|TOTAL'
shot uc06-invoice-deductions 'INVOICE 50234' 'Fleet discount|Discounts|Trade-in +-|TOTAL'

# --- UC-07 Customers who are not fleet see no change -------------------------------
same_keys=(
    3 1002 2001 "" "" ""
    3 1003 2002 "" "" ""
    3 1004 2002 10 500 ""
    4 1002 2001 "" "" Y ""
    5 2 50233 "" 0
    0
)
fresh
play v2.6 "${same_keys[@]}"
before_work="$work"
fresh
play v2.7 "${same_keys[@]}"
shot uc07-retail 'Sarah Whitfield \(Retail\)' 'List price|TOTAL'
keep uc07-trade 'TOTAL +17509\.60'
shot uc07-trade-deductions 'TOTAL +16016\.00' 'Trade discount|Discount \(|Trade-in +-|TOTAL'
cp "$before_work/session.txt" "$work/session-v2.6.txt" || fail "no v2.6 session"
cp "$work/session.txt" "$work/session-v2.7.txt" || fail "no v2.7 session"
cp -R "$before_work/data" "$work/data-v2.6" || fail "no v2.6 data"
run uc07-compare "grep -c DEALERDESK session-v2.7.txt" '^[0-9]+$'
run uc07-compare "diff session-v2.6.txt session-v2.7.txt | grep -E '^[<>]' | grep -c 'DEALERDESK v2\.[67]'" '^[0-9]+$'
run uc07-compare "diff session-v2.6.txt session-v2.7.txt | grep -E '^[<>]' | grep -vc 'DEALERDESK v2\.[67]'" '^0$'
run uc07-compare "diff -r data-v2.6 data && echo 'all data files are identical'" 'identical'
draw uc07-compare '^0$|^all data files'
# The control: the same keystrokes with a fleet customer must show a difference.
control_work="$work"
fresh
play v2.7 2 4 2001 "" 0 0
play v2.7 "${same_keys[@]}"
cp "$work/session.txt" "$control_work/session-control.txt" || fail "no control session"
work="$control_work"
run uc07-control "diff session-v2.6.txt session-control.txt | grep -E '^[<>]' | grep -v 'DEALERDESK v2\.[67]'" 'Fleet discount'

# --- UC-08 Existing invoices and data files ----------------------------------------
fresh
play v2.7 5 2 50232 "" 0 0
keep uc08-before 'INVOICE 50232'
cp "$out/uc08-before.txt" "$work/invoice-before.txt" || fail "no invoice before"
play v2.7 2 4 2008 "" 0 0
play v2.7 5 2 50232 "" 0 0
shot uc08-after 'INVOICE 50232' 'Discounts|TOTAL'
cp "$out/uc08-after.txt" "$work/invoice-after.txt" || fail "no invoice after"
run uc08-data "cmp invoice-before.txt invoice-after.txt && echo 'invoice 50232 reads the same before and after'" 'reads the same'
play v2.7 4 1007 2008 "" "" Y "" 0
run uc08-data "head -3 data/invoices.dat | cmp - original/invoices.dat && echo 'invoices 50230, 50231 and 50232 are byte-identical'" 'byte-identical'
run uc08-data "awk -F'|' '{ print \$1, NF, \"fields\" }' data/invoices.dat" '50233 12 fields'

# --- UC-09 A fleet customer with no email stays fleet ------------------------------
fresh
play v2.7 2 2 "No Email Fleet" "01632 960123" "" N Y "" 0 0
run uc09-data "grep '^2009' data/customers.dat" '\|\|F$'
play v2.7 2 1 "" 0 3 1002 2009 "" "" "" 0
shot uc09-list 'No Email Fleet .*Fleet'
shot uc09-quote 'TOTAL +12901\.24' 'Customer :|Fleet discount|TOTAL'

# --- UC-10 Roll back to v2.6 and return to v2.7 ------------------------------------
fresh
play v2.7 2 4 2008 "" 0 4 1002 2008 "" "" Y "" 0
run uc10-data "grep '^2008' data/customers.dat" '\|F$'
run uc10-data "grep '^50233' data/invoices.dat" '\|439\.80$'
# Adding a customer makes v2.6 rewrite customers.dat, so the F is really put to the test.
play v2.6 2 1 "" 2 "Rollback Customer" "01632 960127" "rollback@example.com" N "" 0 \
    3 1007 2008 "" "" "" \
    5 2 50233 "" 0 \
    0
keep uc10-old-list 'Greenway Taxis .*Retail'
shot uc10-old-quote 'Greenway Taxis \(Retail\)' 'DEALERDESK v2\.6|Customer :|TOTAL'
shot uc10-old-invoice 'INVOICE 50233' 'DEALERDESK v2\.6|Discounts|TOTAL'
run uc10-data "grep -E '^(2008|2009)' data/customers.dat" '2008.*\|F$'
play v2.7 2 1 "" 0 5 2 50233 "" 0 0
shot uc10-back-list 'Greenway Taxis .*Fleet'
shot uc10-back-invoice 'INVOICE 50233' 'DEALERDESK v2\.7|Fleet discount|TOTAL'
# What a rollback costs: v2.6 saves invoices, and drops the field it does not know.
play v2.6 4 1003 2001 "" "" Y "" 0
run uc10-cost "grep '^50233' data/invoices.dat" '\|12901\.24$'
play v2.7 5 2 50233 "" 0 0
shot uc10-cost-invoice 'INVOICE 50233' 'Discounts|TOTAL'
# It also brings BUG-002 back, and v2.6's next customer save damages a blank email.
fresh
play v2.7 2 2 "No Email Fleet" "01632 960123" "" N Y "" 0 0
run uc10-cost "grep '^2009' data/customers.dat" '\|\|F$'
play v2.6 2 2 "Rollback Customer" "01632 960127" "rollback@example.com" N "" 0 0
run uc10-cost "grep '^2009' data/customers.dat" '\|F\|R$'

# --- The tests ---------------------------------------------------------------------
work="$tmp/v2.7"
run tests-all "make test 2>&1 | grep -E 'all pricing|[0-9] passed|spec scenarios'" '220 spec scenarios, 220 tests'
draw tests-all '^[^$].*(passed|spec scenarios)'
run tests-coverage "bash app/tests/integration/behaviour/check-coverage.sh --strict && echo 'every spec scenario has a test'" 'every spec scenario'

# The safety net must catch a real mistake: the same tests with a fleet rate of 5%.
build wrong-rate "$fleet_commit"
sed -i 's/list \* 0\.04/list * 0.05/' "$tmp/wrong-rate/app/src/calc.c"
make -s -C "$tmp/wrong-rate" build || fail "cannot build the wrong rate"
work="$tmp/wrong-rate"
run tests-wrong-rate "grep -n 'list \* 0.05' app/src/calc.c" '0\.05'
run tests-wrong-rate "make test-unit 2>&1 | grep FAIL | head -4" 'FAIL fleet'
run tests-wrong-rate "make test-integration 2>&1 | tail -1" '6 passed, 0 failed'
run tests-wrong-rate "make test-behaviour 2>&1 | grep -E '^FAIL  ' | head -8" 'FAIL  '
run tests-wrong-rate "make test-behaviour 2>&1 | grep -E '[0-9]+ passed, [1-9][0-9]* failed'" '[1-9][0-9]* failed'
draw tests-wrong-rate '^[^$].*(FAIL|0\.05|[1-9][0-9]* failed)'

echo "saved $(ls "$out"/*.txt | wc -l) transcripts in $out"
