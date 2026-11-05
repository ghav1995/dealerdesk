# DealerDesk: agent instructions

DealerDesk is a C terminal app that car dealerships use every day. It works, but
it has no safety net and its documentation cannot be trusted. Change it the way
you would change a live billing system: prove what it does today, specify what
should change, then change only that.

The goals are in [docs/BRIEF.md](docs/BRIEF.md) and
[docs/TICKET-142.md](docs/TICKET-142.md).

## Commands

Run these from the repository root, on Linux, macOS or WSL.

    make build              compile app/dealerdesk
    make run                start the app from app/
    make test               unit and integration tests
    make test-unit          pricing tests only
    make test-integration   replay scripted sessions against the baseline
    make golden             re-record the baseline (see rule 2)
    openspec validate --all --strict

## Repository map

    app/src/                 main.c (menus, screens), calc.c (pricing),
                             dbfile.c (flat files), screen.c (terminal input)
    app/data/                sample data, rewritten whenever the app runs
    app/tests/unit/          test_*.c, plain C with no framework
    app/tests/integration/   scenarios/*.keys are keystrokes, expected/*.txt is
                             the baseline, fixtures/data is the starting data
    openspec/specs/          what the system does today
    openspec/changes/        proposed changes, one folder each
    .github/workflows/       ci.yml runs make test on pull requests and master

## What to trust

When sources disagree, trust them in this order:

1. Invoices in the data files, and what the compiled program does.
2. Git history, for why (`git log --follow -p app/src/calc.c`).
3. `openspec/specs/`.
4. Anything else. Comments, the in-app Help screen and old docs have all been
   wrong here, so verify them before relying on them.

These claims are false, and all of them are still in the code:

| Claim | Where | Reality |
|---|---|---|
| Trade discount is 5% | Help screen, `calc.c` header | 10% since 8ffd2ad, confirmed by invoice 50231 |
| Manager PIN above 10% | Help screen, `calc.c` header | Removed in a42d118. Silently capped at 15% |
| VAT is on list price | `calc.c` header | 20% of net plus delivery (9dc21bb, 3a46905) |
| Plates are upper-cased | Help screen, `main.c` header | Stored as typed (76169d5). Find is exact and case-sensitive |
| Data is in `C:\DEALERDESK\DATA` | `dbfile.c` header | `data/` relative to the working directory |

Do not fix the Help screen in passing. Staff can see it, so it needs its own
specified change.

## Rules

1. **Staff must not notice anything except the requested feature.** Every screen,
   prompt, total and saved file stays byte-identical unless a spec says otherwise.
2. **A changed baseline is a behaviour change.** Never run `make golden` to get a
   failing test to pass. Understand the diff first. Only re-record for a change
   the spec calls for, and commit the new baseline with that change.
3. **Data files must stay compatible in both directions.** The new binary loads
   every existing file without conversion. The rollback in `docs/RELEASE.txt`
   puts the old binary back on the same data, so it must also still load files
   the new binary wrote without losing or corrupting anything. Only append
   fields, never reorder or repurpose them.
4. **Issued invoices are historical records.** Display what was stored. Never
   recalculate an invoice or read current customer or vehicle details to decide
   how much it was for.
5. **Tests never touch `app/data`.** If you run the app by hand, restore it with
   `git checkout -- app/data`, and never commit changes to it unless a spec says so.
6. **Keep the code portable C.** Match the existing style: C89 declarations at the
   top of a block, `/* */` comments, no new dependencies. Releases have been built
   with an old Borland compiler. Compile with no new warnings.
7. **Money stays in the existing model:** doubles, rounded with `rnd2()` at the
   points `calc_quote` already rounds. Do not change how an existing amount is
   rounded, because one penny on an invoice counts as a regression.
8. **Keep secrets out of the repository, logs and chat.** This includes tokens in
   command lines and in files under `.claude/`.
9. **This is a fork.** `origin` is the fork. `upstream` is read-only. Never open a
   pull request against the original repository.

## Spec-driven workflow

Any change to behaviour goes through OpenSpec. Refactors, tests and tooling that
leave behaviour identical do not need a change proposal.

1. `/opsx:explore` if the request is unclear. Read the code and history first.
2. `/opsx:propose <change-name>` writes the proposal, delta specs, design and
   tasks. Stop here until a human has reviewed them. Unclear points need a
   decision recorded in `design.md`, not a silent guess.
3. Turn each spec scenario into a test and watch it fail.
4. `/opsx:apply` implements the tasks, one small commit at a time.
5. `make test` and `openspec validate --all --strict` must pass.
6. `/opsx:archive` merges the delta specs into `openspec/specs/`.

Commits are read as part of the work. Keep each one small and buildable, with an
imperative subject and a body explaining why. Never mix a refactor with a
behaviour change.

## Known traps

- **Blank fields shift columns.** `dbfile.c` splits with `strtok`, which skips
  empty fields, and `add_customer` only requires a name. `id|name|phone||T` loads
  with email `T` and falls back to type `R`, so a trade customer with no email
  loses their discount after a restart. Anything stored after an optional field
  is at risk.
- **Customer type labels are hard-coded.** `print_cust_row` and `print_quote` use
  `type == 'T' ? "Trade" : "Retail"`, so any new type prints as Retail until both
  change.
- **Invoices keep one combined discount.** `INVOICE.disc` is the trade and
  salesman discounts added together. The quote screen shows them separately, but
  the invoice screen can only show the total.
- **`save_*` rewrites whole files.** An old binary drops any field it does not
  know about the moment it saves.
- **Reserved vehicles can still be sold.** `build_quote` only blocks sold vehicles.
  This may be a bug, but it is today's behaviour, so leave it.
- **A scenario can pass without testing anything.** The `.keys` files must follow
  each flow exactly. An error path stops asking questions, so leftover keystrokes
  become menu choices and a stray `0` exits the app, and the rest of the scenario
  never runs. When adding a scenario, check its last step is in `expected/`, and
  break the code on purpose to confirm the scenario fails.

## TICKET-142: what the change must settle

Fleet is the next change. Its design must decide these points explicitly:

- **How fleet is stored.** A new customer type `F` keeps the file format and
  passes through a rollback, but cannot be combined with Trade. A new field can be
  combined, but an old binary drops it when it saves.
- **Marking existing customers.** No edit-customer screen exists. Greenway Taxis
  (2008) needs one, and the new prompts must not disturb existing flows.
- **Trade customers marked as fleet.** Decide between refusing, replacing or
  stacking. The ticket does not say.
- **Order of calculation.** 4% of list price, rounded with `rnd2()`, like the trade
  discount. The salesman discount then applies to what is left. It must not count
  towards the 15% limit, since saving that allowance is the point of the ticket.
- **The invoice screen.** A "Fleet discount" line needs the amount stored with the
  invoice, in an appended field. Rows without it mean no fleet discount.
- **Invoice 50232.** Greenway's 8% hand discount from 2021 must keep displaying
  exactly as it does now, even after Greenway becomes a fleet customer.
- **The blank-field trap.** A fleet customer with no email must stay fleet after a
  restart.

The test for "unchanged to the penny" is the integration baseline: it was recorded
before the ticket, so non-fleet scenarios must pass without being re-recorded.

## Definition of done

- `make build` shows no new warnings, and `make test` passes.
- `openspec validate --all --strict` passes.
- Every spec scenario has a test that failed before the change.
- README and specs match the new behaviour.
- Anything a human would want to know is in the change's `design.md`: assumptions,
  decisions and anything left undone.

## Log agent mistakes

When an agent gets something wrong, note what happened and how it was caught.
`NOTES.md` has to report at least one real example, so tell the human at the time
instead of quietly fixing it.
