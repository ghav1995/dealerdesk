This standard disclaimer states that the work is entirely fictional and any resemblance to real people, places, or events is coincidental.

# DealerDesk v2.3

Dealer management for the showroom: stock, customers, quotes and invoices. A
menu-driven terminal application written in C.

## Repository layout

    app/
      src/                 C sources and headers
      data/                sample data files
      tests/unit/          pricing tests
      tests/integration/   scripted sessions compared with a recorded baseline
    openspec/              behaviour specs and proposed changes
    docs/                  challenge brief, TICKET-142, release procedure
    AGENTS.md, CLAUDE.md   instructions for AI coding agents

## Quick start

You need Linux, macOS or WSL on Windows, with a C compiler and make. On Ubuntu
or WSL:

    sudo apt install build-essential

Then, from the repository root:

    make build      # compile to app/dealerdesk
    make run        # start the app
    make test       # run the unit and integration tests

To build without make:

    cd app
    gcc -o dealerdesk src/*.c -lm
    ./dealerdesk

* The app reads and writes `./data`, so it has to start from `app/`. `make run`
  does this for you.
* Pick a menu option by typing its number and pressing ENTER. 0 goes back, and
  0 on the main menu exits.
* Every change (new vehicle, sale, ...) is saved to `app/data/*.dat`
  immediately. To put the sample data back:

      git checkout -- app/data

Do not edit the `.dat` files by hand while the program is running.

## Menu

    1. Stock
    2. Customers
    3. Quote
    4. Sell vehicle
    5. Invoices
    9. Help
    0. Exit

## Data files

    stock.dat       vehicles
    customers.dat   customers
    invoices.dat    invoices
    next_ids.dat    id counters

One record per line, with fields separated by `|`. The formats are defined in
[openspec/specs/data-files/spec.md](openspec/specs/data-files/spec.md).

## Pricing rules

Checked against the code and the invoices in the sample data. The full rules
are in [openspec/specs/pricing/spec.md](openspec/specs/pricing/spec.md).

      List price
    - Trade discount       10% of list price, trade customers only
    - Salesman discount    0-15% of the price after trade discount
    = Net price
    + Delivery             150.00
    + VAT                  20% of net price plus delivery
    + Registration fee     55.00, no VAT
    - Trade-in
    = Total

A salesman discount above 15% is reduced to 15%. There is no manager PIN.

The in-app Help screen still says 5% trade discount and a manager PIN above
10%. That text is out of date, and is left as it is because staff see it.

## Changing the code

Changes are spec-driven with [OpenSpec](https://github.com/Fission-AI/OpenSpec),
which needs Node.js 22.12 or later:

    npm install -g @fission-ai/openspec@1.16.0

See [AGENTS.md](AGENTS.md) for the workflow and the rules for changing this
codebase.

## Release

See [docs/RELEASE.txt](docs/RELEASE.txt). Releases are manual. The pipeline in
[.github/workflows/cd.yml](.github/workflows/cd.yml) runs the tests and then
simulates approved deploys to dev, test, qa and prd. It does not deploy anything.

Problems: ask Phil (ext. 214).
