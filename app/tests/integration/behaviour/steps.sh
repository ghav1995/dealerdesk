#!/usr/bin/env bash
# The language of the scenario tests. Each sentence in a scenario is matched here
# and turned into keystrokes or a check. A sentence that matches nothing fails its
# scenario, so a typo cannot become a test that silently passes.
#
# Every action is one app session. The data folder is kept between sessions, so each
# action starts the app again and reads what the last one saved.

# --- Scenario life cycle --------------------------------------------------------

scenarios_passed=0
scenarios_failed=0
current_scenario=""
current_kind=""
scenario_ok=1
scenario_log=""
work=""
start_data=""

finish_scenario() {
    [ -n "$current_scenario" ] || return 0
    if [ "$scenario_ok" -eq 1 ]; then
        scenarios_passed=$((scenarios_passed + 1))
        echo "ok    $current_scenario"
    else
        scenarios_failed=$((scenarios_failed + 1))
        echo "FAIL  $current_scenario"
        printf '%b' "$scenario_log"
    fi
    rm -rf "$work" "$start_data"
    current_scenario=""
}

Scenario() {
    finish_scenario
    current_scenario="$1"
    current_kind=""
    scenario_ok=1
    scenario_log=""
    work="$(mktemp -d)"
    start_data="$(mktemp -d)"
    : > "$work/screen.txt"
    status=0
}

log_step() {
    scenario_log+="      $1\n"
}

fail_step() {
    scenario_ok=0
    scenario_log+="      FAILED: $1\n"
}

run_step() {
    local kind="$1" sentence="$2"
    [ "$scenario_ok" -eq 1 ] || { log_step "skipped: $kind $sentence"; return 0; }
    log_step "$kind $sentence"
    case "$kind" in
        Given) given_step "$sentence" ;;
        When) action_step "$sentence" ;;
        Then) then_step "$sentence" ;;
    esac
}

Given() { current_kind=Given; run_step Given "$1"; }
When()  { current_kind=When;  run_step When "$1"; }
Then()  { current_kind=Then;  run_step Then "$1"; }
And()   { run_step "$current_kind" "$1"; }

# --- Running the app ------------------------------------------------------------

# Runs one session from the keystrokes given, then records the screen and status.
session() {
    printf '%s\n' "$@" > "$work/keys.txt"
    (cd "$work" && "$bin" < keys.txt > raw.txt)
    status=$?
    screen_from_raw
}

# Input that ends at once, so the app never gets a line at all.
session_without_input() {
    (cd "$work" && "$bin" < /dev/null > raw.txt)
    status=$?
    screen_from_raw
}

screen_from_raw() {
    sed 's/\x1b\[[0-9;]*[A-Za-z]//g' "$work/raw.txt" > "$work/screen.txt"
}

# --- Given: the starting data ---------------------------------------------------

snapshot_data() {
    rm -rf "$start_data/data"
    [ -d "$work/data" ] && cp -R "$work/data" "$start_data/data"
    return 0
}

use_sample_data() {
    cp -R "$fixtures" "$work/data"
    snapshot_data
}

fill_stock() {
    local i
    : > "$work/data/stock.dat"
    for ((i = 3000; i < 3000 + $1; i++)); do
        echo "$i|P$i|Ford|Focus|2020|1|1.00|2.00|0"
    done >> "$work/data/stock.dat"
}

fill_customers() {
    local i
    : > "$work/data/customers.dat"
    for ((i = 3000; i < 3000 + $1; i++)); do
        echo "$i|Customer $i|1|a@example.com|R"
    done >> "$work/data/customers.dat"
}

fill_invoices() {
    local i
    : > "$work/data/invoices.dat"
    for ((i = 1; i <= $1; i++)); do
        echo "$i|2021-01-01|1001|2001|1.00|0.00|1.00|0.20|205.00|0.00|206.20"
    done >> "$work/data/invoices.dat"
}

given_step() {
    local s="$1"
    if [ "$s" = "the sample showroom data" ]; then
        use_sample_data
    elif [[ "$s" =~ ^the\ sample\ showroom\ data\ without\ ([a-z_]+\.dat)$ ]]; then
        use_sample_data
        rm "$work/data/${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^the\ sample\ showroom\ data\ without\ customer\ ([0-9]+)$ ]]; then
        use_sample_data
        sed -i.bak "/^${BASH_REMATCH[1]}|/d" "$work/data/customers.dat"
    elif [[ "$s" =~ ^the\ sample\ showroom\ data\ without\ customer\ ([0-9]+)\ or\ vehicle\ ([0-9]+)$ ]]; then
        use_sample_data
        sed -i.bak "/^${BASH_REMATCH[1]}|/d" "$work/data/customers.dat"
        sed -i.bak "/^${BASH_REMATCH[2]}|/d" "$work/data/stock.dat"
    elif [ "$s" = "a folder with no data folder" ]; then
        :
    elif [[ "$s" =~ ^a\ stock\ file\ holding\ ([0-9]+)\ vehicles$ ]]; then
        use_sample_data
        fill_stock "${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^a\ customer\ file\ holding\ ([0-9]+)\ customers$ ]]; then
        use_sample_data
        fill_customers "${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^an\ invoice\ file\ holding\ ([0-9]+)\ invoices$ ]]; then
        use_sample_data
        fill_invoices "${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^the\ customer\ file\ also\ holds\ \"(.*)\"$ ]]; then
        echo "${BASH_REMATCH[1]}" >> "$work/data/customers.dat"
    elif [[ "$s" =~ ^the\ stock\ file\ also\ holds\ \"(.*)\"$ ]]; then
        echo "${BASH_REMATCH[1]}" >> "$work/data/stock.dat"
    elif [ "$s" = "the stock file has CRLF line endings" ]; then
        sed -i.bak 's/$/\r/' "$work/data/stock.dat"
    elif [ "$s" = "the customer file has a blank line and a comment" ]; then
        printf '\n# a note\n' >> "$work/data/customers.dat"
    elif [ "$s" = "the stock file has a comment" ]; then
        echo "# a note" >> "$work/data/stock.dat"
    else
        action_step "$s"
    fi
    rm -f "$work"/data/*.bak
}

# --- Actions: one app session each ----------------------------------------------

# Splits `name "value" and name "value"` into the variables below.
read_fields() {
    local rest="$1" pattern='^(and )?([a-z -]+) "([^"]*)"( |$)(.*)$'
    while [[ "$rest" =~ $pattern ]]; do
        case "${BASH_REMATCH[2]}" in
            plate) f_plate="${BASH_REMATCH[3]}" ;;
            make) f_make="${BASH_REMATCH[3]}" ;;
            model) f_model="${BASH_REMATCH[3]}" ;;
            year) f_year="${BASH_REMATCH[3]}" ;;
            mileage) f_mileage="${BASH_REMATCH[3]}" ;;
            cost) f_cost="${BASH_REMATCH[3]}" ;;
            "list price") f_price="${BASH_REMATCH[3]}" ;;
            name) f_name="${BASH_REMATCH[3]}" ;;
            phone) f_phone="${BASH_REMATCH[3]}" ;;
            email) f_email="${BASH_REMATCH[3]}" ;;
            "trade answer") f_trade="${BASH_REMATCH[3]}" ;;
            "fleet answer") f_fleet="${BASH_REMATCH[3]}" ;;
            *) return 1 ;;
        esac
        rest="${BASH_REMATCH[5]}"
    done
    [ -z "$rest" ]
}

add_vehicle() {
    f_plate="ZZ01 ZZZ" f_make=Ford f_model=Focus f_year=2020 f_mileage=1000 f_cost=1000.00 f_price=2000.00
    read_fields "$1" || { fail_step "cannot read: $1"; return; }
    session 1 3 "$f_plate" "$f_make" "$f_model" "$f_year" "$f_mileage" "$f_cost" "$f_price"
}

add_customer() {
    f_name="Test Customer" f_phone="01632 960000" f_email="test@example.com" f_trade=N f_fleet=N
    read_fields "$1" || { fail_step "cannot read: $1"; return; }
    # A trade customer is not asked the fleet question, so its answer goes to the pause.
    session 2 2 "$f_name" "$f_phone" "$f_email" "$f_trade" "$f_fleet"
}

# Reads the discount and trade-in from the end of a quote or sale sentence.
read_terms() {
    t_discount=0 t_trade_in=0
    case "$1" in
        "") ;;
        " with no discount and no trade-in"|" with no discount"|" with no other discount") ;;
        *)
            if [[ "$1" =~ ^\ with\ (.+)%\ discount\ and\ (.+)\ trade-in$ ]]; then
                t_discount="${BASH_REMATCH[1]}" t_trade_in="${BASH_REMATCH[2]}"
            elif [[ "$1" =~ ^\ with\ (.+)%\ discount$ ]]; then
                t_discount="${BASH_REMATCH[1]}"
            elif [[ "$1" =~ ^\ with\ (.+)\ trade-in$ ]]; then
                t_trade_in="${BASH_REMATCH[1]}"
            else
                return 1
            fi
            ;;
    esac
}

action_step() {
    local s="$1" r=""
    case "$s" in
        "the app starts") session_without_input; return ;;
        "the app is restarted") return ;; # Every action already starts the app again.
        "input ends on the main menu") session_without_input; return ;;
        "input ends after the make is typed") session 1 3 "ZZ01 ZZZ" Ford; return ;;
        "input ends after the vehicle id is typed on the quote screen") session 3 1002; return ;;
        "I choose Stock") session 1; return ;;
        "I choose Customers") session 2; return ;;
        "I choose Invoices") session 5; return ;;
        "I choose Help") session 9; return ;;
        "I choose Add vehicle") session 1 3; return ;;
        "I choose Add customer") session 2 2; return ;;
        "I choose Sell vehicle") session 4; return ;;
        "I list stock") session 1 1; return ;;
        "I list all vehicles") session 1 2; return ;;
        "I list customers") session 2 1; return ;;
        "I list invoices") session 5 1; return ;;
    esac

    if [[ "$s" =~ ^I\ add\ a\ vehicle\ with\ (.*)$ ]]; then
        add_vehicle "${BASH_REMATCH[1]}"
    elif [ "$s" = "I add a vehicle" ]; then
        add_vehicle ""
    elif [[ "$s" =~ ^I\ add\ a\ customer\ with\ (.*)$ ]]; then
        add_customer "${BASH_REMATCH[1]}"
    elif [ "$s" = "I add a customer" ]; then
        add_customer ""
    elif [[ "$s" =~ ^I\ type\ \"(.*)\"\ on\ the\ main\ menu$ ]]; then
        session "${BASH_REMATCH[1]}" ""
    elif [ "$s" = "I press ENTER on the main menu" ]; then
        session ""
    elif [[ "$s" =~ ^I\ type\ \"(.*)\"\ on\ the\ stock\ menu$ ]]; then
        session 1 "${BASH_REMATCH[1]}" ""
    elif [ "$s" = "I press ENTER on the stock menu" ]; then
        session 1 ""
    elif [[ "$s" =~ ^I\ type\ \"(.*)\"\ on\ the\ customers\ menu$ ]]; then
        session 2 "${BASH_REMATCH[1]}" ""
    elif [[ "$s" =~ ^I\ type\ \"(.*)\"\ on\ the\ invoices\ menu$ ]]; then
        session 5 "${BASH_REMATCH[1]}" ""
    elif [[ "$s" =~ ^I\ type\ \"(.*)\"\ at\ the\ pause$ ]]; then
        session 9 "${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^I\ view\ invoice\ ([0-9]+)$ ]]; then
        session 5 2 "${BASH_REMATCH[1]}"
    elif [ "$s" = "I search with a blank plate" ]; then
        session 1 4 ""
    elif [[ "$s" =~ ^I\ search\ for\ plate\ \"(.*)\"$ ]]; then
        session 1 4 "${BASH_REMATCH[1]}"
    elif [ "$s" = "I search customers with blank text" ]; then
        session 2 3 ""
    elif [[ "$s" =~ ^I\ search\ customers\ for\ \"(.*)\"$ ]]; then
        session 2 3 "${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^I\ change\ the\ price\ of\ vehicle\ ([0-9]+)\ to\ \"(.*)\"$ ]]; then
        session 1 5 "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    elif [[ "$s" =~ ^I\ try\ to\ change\ the\ price\ of\ vehicle\ ([0-9]+)$ ]]; then
        session 1 5 "${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^I\ reserve\ or\ release\ vehicle\ ([0-9]+)$ ]]; then
        session 1 6 "${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^I\ mark\ customer\ ([0-9]+)\ as\ a\ fleet\ customer$ ]]; then
        session 2 4 "${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^I\ try\ to\ quote\ vehicle\ ([0-9a-z]+)$ ]]; then
        session 3 "${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^I\ try\ to\ quote\ vehicle\ ([0-9a-z]+)\ for\ customer\ ([0-9a-z]+)$ ]]; then
        session 3 "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    elif [[ "$s" =~ ^I\ quote\ vehicle\ ([0-9a-z]+)\ for\ customer\ ([0-9a-z]+)(.*)$ ]]; then
        local vehicle="${BASH_REMATCH[1]}" customer="${BASH_REMATCH[2]}"
        read_terms "${BASH_REMATCH[3]}" || { fail_step "cannot read: $s"; return; }
        session 3 "$vehicle" "$customer" "$t_discount" "$t_trade_in"
    elif [[ "$s" =~ ^I\ try\ to\ sell\ vehicle\ ([0-9]+)$ ]]; then
        session 4 "${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^I\ try\ to\ sell\ vehicle\ ([0-9]+)\ to\ customer\ ([0-9]+)$ ]]; then
        session 4 "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    elif [[ "$s" =~ ^I\ see\ the\ preview\ for\ vehicle\ ([0-9]+)\ and\ customer\ ([0-9]+)$ ]]; then
        session 4 "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" 0 0
    elif [[ "$s" =~ ^I\ answer\ \"(.*)\"\ to\ selling\ vehicle\ ([0-9]+)\ to\ customer\ ([0-9]+)$ ]]; then
        session 4 "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" 0 0 "${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^I\ sell\ vehicle\ ([0-9]+)\ to\ customer\ ([0-9]+)(.*)$ ]]; then
        local vehicle="${BASH_REMATCH[1]}" customer="${BASH_REMATCH[2]}"
        read_terms "${BASH_REMATCH[3]}" || { fail_step "cannot read: $s"; return; }
        session 4 "$vehicle" "$customer" "$t_discount" "$t_trade_in" Y
    else
        fail_step "no step matches: $s"
    fi
}

# --- Then: the checks -----------------------------------------------------------

screen_has() {
    grep -F -q -- "$1" "$work/screen.txt"
}

# Checks a labelled amount line, such as "  Net price    10445.25".
line_is() {
    local label="$1" amount="${2//./\\.}"
    grep -E -q "^ *${label}.* +${amount}$" "$work/screen.txt"
}

line_absent() {
    ! grep -E -q "^ *$1" "$work/screen.txt"
}

label_for() {
    case "$1" in
        "list price") echo "List price" ;;
        "net price") echo "Net price" ;;
        delivery) echo "Delivery" ;;
        VAT) echo "VAT" ;;
        "registration fee") echo "Registration fee" ;;
        "trade discount") echo "Trade discount" ;;
        discount) echo "Discount \\(" ;;
        discounts) echo "Discounts" ;;
        fees) echo "Fees" ;;
        trade-in) echo "Trade-in" ;;
        total) echo "TOTAL" ;;
        *) return 1 ;;
    esac
}

vehicle_column() {
    case "$1" in
        plate) echo 2 ;; make) echo 3 ;; model) echo 4 ;; year) echo 5 ;; mileage) echo 6 ;;
        cost) echo 7 ;; price) echo 8 ;; status) echo 9 ;; *) return 1 ;;
    esac
}

customer_column() {
    case "$1" in
        name) echo 2 ;; phone) echo 3 ;; email) echo 4 ;; type) echo 5 ;; *) return 1 ;;
    esac
}

invoice_column() {
    case "$1" in
        date) echo 2 ;; vehicle) echo 3 ;; customer) echo 4 ;; list) echo 5 ;; discount) echo 6 ;;
        net) echo 7 ;; VAT) echo 8 ;; fees) echo 9 ;; trade-in) echo 10 ;; total) echo 11 ;; *) return 1 ;;
    esac
}

# Checks one column of the record starting with an id. A wrong value fails the step.
field_is() {
    local file="$1" id="$2" column="$3" want="$4" got
    got="$(grep "^$id|" "$work/data/$file" | head -1 | cut -d'|' -f"$column")"
    [ "$got" = "$want" ] || fail_step "$file record $id column $column is '$got', expected '$want'"
}

# Reads a fixed-width column of a line in the customer list, without its padding.
listed_value() {
    grep -E "^ *$1 " "$work/screen.txt" | head -1 | cut -c"$2" | sed 's/ *$//'
}

then_step() {
    local s="$1"
    if [[ "$s" =~ ^the\ screen\ shows\ \"(.*)\"$ ]]; then
        screen_has "${BASH_REMATCH[1]}" || fail_step "screen does not show: ${BASH_REMATCH[1]}"
    elif [[ "$s" =~ ^the\ screen\ does\ not\ show\ \"(.*)\"$ ]]; then
        ! screen_has "${BASH_REMATCH[1]}" || fail_step "screen shows: ${BASH_REMATCH[1]}"
    elif [ "$s" = "the header shows the current version" ]; then
        local version
        version="$(cd "$repo_root" && make -s version)"
        screen_has "DEALERDESK $version" || fail_step "header does not show $version"
    elif [[ "$s" =~ ^the\ line\ for\ \"(.*)\"\ shows\ \"(.*)\"$ ]]; then
        local start="${BASH_REMATCH[1]}" want="${BASH_REMATCH[2]}"
        grep -E "^ *$start " "$work/screen.txt" | grep -F -q -- "$want" \
            || fail_step "line for $start does not show: $want"
    elif [[ "$s" =~ ^the\ (.+)\ (is|are)\ (-?[0-9.]+)$ ]]; then
        local label amount="${BASH_REMATCH[3]}"
        label="$(label_for "${BASH_REMATCH[1]}")" || { fail_step "no step matches: $s"; return; }
        line_is "$label" "$amount" || fail_step "$s, but the screen shows: $(grep -E "^ *$label" "$work/screen.txt" | head -1)"
    elif [[ "$s" =~ ^there\ is\ no\ (.+)\ line$ ]]; then
        local label
        label="$(label_for "${BASH_REMATCH[1]}")" || { fail_step "no step matches: $s"; return; }
        line_absent "$label" || fail_step "unexpected line: $label"
    elif [ "$s" = "the data files are unchanged" ]; then
        diff -r "$start_data/data" "$work/data" > /dev/null || fail_step "data files changed"
    elif [[ "$s" =~ ^the\ app\ exits\ with\ status\ ([0-9]+)$ ]]; then
        [ "$status" -eq "${BASH_REMATCH[1]}" ] || fail_step "app exited with status $status"
    elif [[ "$s" =~ ^vehicle\ ([0-9]+)\ is\ saved\ with\ ([a-z]+)\ \"(.*)\"$ ]]; then
        local id="${BASH_REMATCH[1]}" want="${BASH_REMATCH[3]}" column
        column="$(vehicle_column "${BASH_REMATCH[2]}")" || { fail_step "no step matches: $s"; return; }
        field_is stock.dat "$id" "$column" "$want"
    elif [[ "$s" =~ ^customer\ ([0-9]+)\ is\ saved\ with\ ([a-z]+)\ \"(.*)\"$ ]]; then
        local id="${BASH_REMATCH[1]}" want="${BASH_REMATCH[3]}" column
        column="$(customer_column "${BASH_REMATCH[2]}")" || { fail_step "no step matches: $s"; return; }
        field_is customers.dat "$id" "$column" "$want"
    elif [[ "$s" =~ ^customer\ ([0-9]+)\ is\ listed\ with\ phone\ \"(.*)\"$ ]]; then
        local want="${BASH_REMATCH[2]}" got
        got="$(listed_value "${BASH_REMATCH[1]}" 36-49)"
        [ "$got" = "$want" ] || fail_step "$s, but the list shows '$got'"
    elif [[ "$s" =~ ^customer\ ([0-9]+)\ is\ listed\ with\ email\ \"(.*)\"$ ]]; then
        local want="${BASH_REMATCH[2]}" got
        got="$(listed_value "${BASH_REMATCH[1]}" 51-78)"
        [ "$got" = "$want" ] || fail_step "$s, but the list shows '$got'"
    elif [[ "$s" =~ ^invoice\ ([0-9]+)\ is\ saved\ with\ ([A-Za-z-]+)\ \"(.*)\"$ ]]; then
        local id="${BASH_REMATCH[1]}" want="${BASH_REMATCH[3]}" column
        column="$(invoice_column "${BASH_REMATCH[2]}")" || { fail_step "no step matches: $s"; return; }
        field_is invoices.dat "$id" "$column" "$want"
    elif [[ "$s" =~ ^invoice\ ([0-9]+)\ is\ saved\ with\ today\'s\ date$ ]]; then
        field_is invoices.dat "${BASH_REMATCH[1]}" 2 "$(date +%F)"
    elif [[ "$s" =~ ^invoice\ ([0-9]+)\ does\ not\ exist$ ]]; then
        ! grep -q "^${BASH_REMATCH[1]}|" "$work/data/invoices.dat" || fail_step "invoice exists"
    elif [[ "$s" =~ ^([a-z_]+\.dat)\ holds\ ([0-9]+)\ records$ ]]; then
        local got
        got="$(grep -c . "$work/data/${BASH_REMATCH[1]}")"
        [ "$got" -eq "${BASH_REMATCH[2]}" ] || fail_step "holds $got records"
    elif [[ "$s" =~ ^([a-z_]+\.dat)\ contains\ \"(.*)\"$ ]]; then
        grep -F -q -- "${BASH_REMATCH[2]}" "$work/data/${BASH_REMATCH[1]}" || fail_step "$s"
    elif [[ "$s" =~ ^([a-z_]+\.dat)\ does\ not\ contain\ \"(.*)\"$ ]]; then
        ! grep -F -q -- "${BASH_REMATCH[2]}" "$work/data/${BASH_REMATCH[1]}" || fail_step "$s"
    elif [[ "$s" =~ ^only\ record\ ([0-9]+)\ of\ ([a-z_]+\.dat)\ has\ changed$ ]]; then
        local id="${BASH_REMATCH[1]}" file="${BASH_REMATCH[2]}"
        ! diff -q "$start_data/data/$file" "$work/data/$file" > /dev/null || fail_step "$file did not change"
        diff <(grep -v "^$id|" "$start_data/data/$file") <(grep -v "^$id|" "$work/data/$file") > /dev/null \
            || fail_step "another record in $file changed"
    elif [[ "$s" =~ ^([a-z_]+\.dat)\ has\ no\ CRLF\ line\ endings$ ]]; then
        ! grep -q $'\r' "$work/data/${BASH_REMATCH[1]}" || fail_step "$s"
    elif [[ "$s" =~ ^([a-z_]+\.dat)\ has\ a\ duplicate\ id\ ([0-9]+)$ ]]; then
        local got
        got="$(grep -c "^${BASH_REMATCH[2]}|" "$work/data/${BASH_REMATCH[1]}")"
        [ "$got" -ge 2 ] || fail_step "id appears $got time(s)"
    elif [[ "$s" =~ ^the\ screen\ shows\ \"(.*)\"\ ([0-9]+)\ times$ ]]; then
        local got
        got="$(grep -F -c -- "${BASH_REMATCH[1]}" "$work/screen.txt")"
        [ "$got" -eq "${BASH_REMATCH[2]}" ] || fail_step "shown $got time(s)"
    else
        fail_step "no step matches: $s"
    fi
}
