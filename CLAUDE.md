# DealerDesk

DealerDesk is a menu-driven terminal application that car dealerships use to manage
stock, customers, quotes and invoices. It is written in C and keeps everything in
flat files. It has been in production for years, so most work here means changing
live billing behaviour safely.

@AGENTS.md

`AGENTS.md`, imported above, holds the rules and commands shared with every coding
agent. This file explains how the code fits together and how to work on it with
Claude Code.

## How the code is organised

| File in `app/src/` | What it does |
|---|---|
| `main.c` | The global tables, all menus and screens, and the quote and sale flows |
| `calc.c` | Pricing. `calc_quote` takes numbers and fills in a `QUOTE`, with no input or output, so it can be unit tested directly |
| `dbfile.c` | Loads and saves the `.dat` files |
| `screen.c` | The screen header and keyboard input. `read_line` replaces `\|` with `/` so typed text cannot break a record |
| `globals.h` | The `VEHICLE`, `CUSTOMER` and `INVOICE` records, and the table size limits |

## How data moves through the app

- **Startup:** `main` calls `load_all`, which reads every data file into fixed-size
  global arrays. There is no database and no dynamic allocation.
- **Quote:** `build_quote` asks for the vehicle, customer, discount and trade-in.
  `calc_quote` prices it and `print_quote` displays it. Nothing is saved.
- **Sale:** `sell_vehicle` follows the same path and asks for confirmation. It then
  copies the amounts from the `QUOTE` into an `INVOICE`, marks the vehicle as sold,
  and saves the invoice, stock and id files.
- **Viewing an invoice:** `view_invoice` shows the stored amounts. It looks up the
  customer and vehicle only to show their names.

The quote and sell screens share `build_quote` and `print_quote`, so a change to
either one appears on both.

## Where a change usually lands

- **A pricing rule:** `calc_quote` and the `QUOTE` struct, `print_quote`, and a unit
  test in `app/tests/unit/` using worked amounts.
- **A stored field:** the struct in `globals.h`, then the matching `load_` and `save_`
  functions in `dbfile.c`, with the field added at the end of the record. Check the
  blank-field trap in `AGENTS.md` first.
- **A menu option or prompt:** the relevant function in `main.c`. New prompts shift the
  keystrokes, so check which `.keys` scenarios are affected.
- **Anything staff can see:** expect the integration baseline to change, and treat
  each changed line as something a reviewer needs to approve.

## Working with Claude Code

Start from what the system does today. Read the relevant spec in `openspec/specs/`,
follow the code path, and check `git log --follow` for why it works that way. This
codebase has several rules that look like bugs and were deliberate, and comments
that look reliable and are not.

Behaviour changes go through these commands:

| Command | Use it to |
|---|---|
| `/opsx:explore` | Think through an unclear request before committing to an approach |
| `/opsx:propose <name>` | Create the proposal, delta specs, design and tasks |
| `/opsx:update` | Revise a proposal after review |
| `/opsx:apply` | Implement the reviewed tasks |
| `/opsx:sync` | Merge delta specs into the main specs without archiving |
| `/opsx:archive` | Finish a change and merge its specs |

Stop after `/opsx:propose` so a person can review the decisions before any code is
written.

Merge pull requests with the `merge-and-tag` skill. It also creates the version tag
that starts CD, so a hook blocks any other way of merging.

When reporting work:

- Say what you ran and what it showed. If something was not run, say so.
- Do not call a new test useful until you have seen it fail for the right reason.
- If the baseline changes, show the diff and explain each change instead of
  re-recording it.

## Setting up

You need a C compiler, `make` and a Unix-like shell: Linux, macOS, or WSL on
Windows. The OpenSpec CLI also needs Node.js. The README has the install commands.

This file is shared by everyone who works on the repository. Personal details such
as local paths, shell workarounds and credentials belong in your own
`~/.claude/CLAUDE.md`.
