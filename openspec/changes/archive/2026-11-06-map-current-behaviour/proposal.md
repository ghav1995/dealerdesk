# Proposal

## Why

The specs cover 28 scenarios, while the app has 15 operations, 26 prompts and many outcomes nobody has written down. Running the app has already found real money and data bugs that no spec mentions, such as a list price typed as `10,995` being saved as 10.00. Every later change, starting with TICKET-142, needs a complete and tested record of what the system does today, and the sprint needs a list of the bugs to address.

The request was to "map entirely the system to generate all given when then possible scenario", covering "all workflow".

## What Changes

- Record every operation once for each different outcome it can have, as GIVEN/WHEN/THEN scenarios.
- Record each kind of bad input once for the helper that reads it, because all 26 prompts share a few input functions.
- Record every path through the vehicle lifecycle, and everything that must survive a restart.
- Record end-to-end workflows that cross several operations, such as adding a vehicle, selling it and viewing its invoice.
- Record known bugs as they behave today, in scenarios named `Known bug: ...`.
- Document every known bug in a new `docs/known-bugs/` folder, with one file per bug, so the sprint can address them. Each file gives the severity, the steps to reproduce it, what happens today and the scenario that covers it.
- Assert every scenario and workflow with an automated test, including each known bug as it behaves today.
- Bump the version to v2.5, because every pull request must be `master` plus 0.1.

This comes to 180 scenarios, 28 existing and 152 new, covering 15 known bugs. The rules above decide what is complete, not the number.

### Guarantee: no behaviour changes

This change documents and asserts how the app behaves. It does not change how the app behaves.

- No application logic changes. The only difference in `app/src` is the version number in the screen header, which every pull request must change.
- That version number is the only thing staff can see change.
- No known bug is fixed, and no operation is added.
- The integration baseline is not re-recorded. Data file formats, the sample data and the in-app Help text stay as they are.

This can be checked at any time. `git diff master -- app/src` must show only the version line, and the existing integration baseline must pass unchanged.

### Out of scope

- Fixing any known bug. The sprint addresses each one in its own change.
- Adding new operations.
- TICKET-142, which follows in its own change.

## Capabilities

### New Capabilities

- `navigation`: Menus, moving between them, invalid choices and exiting the app.
- `input-handling`: How typed text becomes numbers, money and yes/no answers, including blank, non-numeric, negative and overlong input, and input ending early.
- `quotes`: The quote flow, including looking up vehicles and customers, the outcomes when they cannot be used, and the promise that a quote saves nothing.
- `business-workflows`: End-to-end journeys across several operations, including the full vehicle lifecycle.

### Modified Capabilities

- `stock`: Adds scenarios for listing, adding, finding, repricing and reserving vehicles, including their failure outcomes.
- `customers`: Adds scenarios for listing, adding and finding customers, including missing fields.
- `pricing`: Adds scenarios for trade-in values and for combinations of discounts, with amounts worked to the penny.
- `invoices`: Adds scenarios for confirming and cancelling sales, listing and viewing invoices, and capacity limits.
- `data-files`: Adds scenarios for restarts, missing files, the wrong working folder, blank fields, file limits and id counters.

## Impact

- **Specs:** new delta specs in this change, merged into `openspec/specs/` when it is archived.
- **Known bugs:** a new `docs/known-bugs/` folder for the sprint.
- **Tests:** new scenario tests in `app/tests/`. The existing integration baseline stays as it is.
- **Code:** one line in `app/src/screen.c` for the version bump. No other application code changes.
- **Docs:** the README title, for the version bump.
- **TICKET-142:** gains a complete baseline, including the blank-field bug it has to deal with.

## Open points for design

- How the scenario tests are written and run.
- Whether existing WHEN/THEN scenarios gain GIVEN steps, or only new ones use them.
- How each known bug's severity is rated, so the sprint can prioritise them.
- A test for a known bug passes while the bug exists, so fixing the bug must mean changing that test on purpose.
