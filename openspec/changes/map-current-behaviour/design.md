# Design

## Context

See `proposal.md` for why. This design covers how the 180 scenarios get asserted, and how known bugs are recorded, without changing the app.

What shapes the approach:

- The app is a C program driven through its keyboard, and most logic is in `static` functions in `main.c`. Tests have to drive the real program from outside.
- `app/tests/integration/` already holds a byte-for-byte baseline. It proves nothing has changed, but its keystroke files are unreadable, and each scenario runs as one process, so it cannot test a restart.
- The app reads `data/` relative to where it starts, so a test can give it a private folder.
- `make test` is the single command used by people and CI. The tests must run on Linux, macOS and WSL with nothing extra installed.

Every outcome in the specs was observed by running the app on throwaway data, except where listed under Risks.

## Goals / Non-Goals

**Goals:**

- Assert every scenario in `openspec/specs/` and in this change, in language a person can read.
- Make a missing test fail the build, so the record stays complete.
- Give the sprint a prioritised list of known bugs.

**Non-Goals:**

- Replacing the existing baseline, which remains the proof of no change.
- Testing internal functions. The tests only use what staff can see and what ends up in the data files.

## Decisions

### Decision: Write scenarios as plain bash in Given/When/Then sentences

New tests live in `app/tests/integration/behaviour/`, one file per capability, for example:

```bash
Scenario "Retail quote with a discount and a trade-in"
  Given "the sample showroom data"
  When  "I quote vehicle 1002 for customer 2001 with 5% discount and 1000.00 trade-in"
  Then  "the total is 11769.30"
```

`steps.sh` turns each sentence into keystrokes or a check, and a sentence it does not recognise fails the test, so a typo cannot become a test that silently passes.

Alternatives rejected:

- `behave`: real Gherkin, but `.feature` files are not needed and it adds Python to a project with no test dependencies.
- A C framework such as Cgreen: scenarios would be C code, which is harder to read, and C would have to launch and drive the program.
- More `.keys` files: this is the format that needs replacing.

### Decision: Each When is one app session

A `When` builds its keystrokes, runs the app until its input ends, and records the screen. The data folder is kept between sessions, so every `When` is effectively a restart, and restart scenarios need no special support. The app exits cleanly when input ends, so steps do not type their way back out of menus.

This also removes the mistake that hid the `sales` scenario failure: a step owns its exact keystrokes, and error paths get their own steps, such as "I try to quote sold vehicle 1001".

Alternative rejected: one long session per scenario, because leftover keystrokes can drift into menu choices.

### Decision: Keep the existing baseline exactly as it is

The new tests sit beside `run.sh`, `scenarios/` and `expected/`, which are not moved or edited. The two answer different questions: the baseline asks whether anything changed, and scenarios ask whether a behaviour holds. Leaving it untouched is also the evidence for the guarantee.

Alternative rejected: moving it into a `baseline/` folder, which is tidier but makes the guarantee harder to check.

### Decision: Assert known bugs as they behave today

A `Known bug:` scenario passes while the bug exists. Fixing the bug makes that test fail, so a fix has to change its test and spec on purpose, and its file in `docs/known-bugs/` is updated in the same change.

Alternative rejected: expected-failure tests, which hide the real behaviour and leave CI unable to notice a bug changing.

### Decision: Match tests to specs by scenario name

Each spec scenario has exactly one test with the same name. A check run by `make test` fails if a scenario has no test, or a test has no scenario. A scenario that a unit test covers carries the same name in a comment in that test, which applies to `Half a penny`.

The check becomes mandatory only in the last task group, because it cannot pass until every scenario has a test.

Alternative rejected: counting tests, which would not notice a missing scenario hidden by an extra test.

### Decision: Only new scenarios use GIVEN steps

The 28 existing scenarios stay as WHEN/THEN, and their tests add the sample data as a `Given`. All new requirements are ADDED, so no existing requirement is touched.

Alternative rejected: rewriting existing scenarios with MODIFIED, which adds review noise and no information.

### Decision: Known bugs live in `docs/known-bugs/`

The folder has a `README.md` index, sorted by severity, and one `BUG-NNN-short-name.md` per bug. Each file gives the severity, steps to reproduce, what happens today, the impact and the scenarios covering it. A fix updates the status in the file rather than deleting it.

Alternatives rejected: GitHub issues, which would not travel with the repository if it is submitted as a zip, and a folder inside `openspec/`, which holds behaviour rather than work to do.

### Decision: Rate severity by harm to the business

| Severity | Meaning |
|---|---|
| High | Wrong money, or data silently lost, in normal daily use |
| Medium | Wrong result only in unusual conditions, or staff are misled |
| Low | An annoyance, with no effect on money or stored data |

| Bug | Summary | Severity |
|---|---|---|
| BUG-001 | Blank make or model loses the price after a restart | High |
| BUG-002 | Blank phone or email loses Trade status after a restart | High |
| BUG-003 | Comma in an amount cuts it short | High |
| BUG-004 | Trade-in above the amount due gives a negative total | High |
| BUG-005 | Negative trade-in adds to the total | Medium |
| BUG-006 | Missing `next_ids.dat` reuses ids | Medium |
| BUG-007 | Wrong folder starts empty and reports failed saves as done | Medium |
| BUG-008 | Saving drops vehicles past the 500 limit | Medium |
| BUG-009 | Help screen states wrong rules | Medium |
| BUG-010 | Same plate accepted twice | Low |
| BUG-011 | No discount shows as -0.00 | Low |
| BUG-012 | ENTER or letters on the main menu exit the app | Low |
| BUG-013 | Comments lost when a file is saved | Low |
| BUG-014 | Negative cost price accepted | Low |
| BUG-015 | Reserved vehicles can be sold to anyone | Low |

Whether each is a bug is a judgement. BUG-015 may be intended, and the sprint can close it as such.

### Decision: Break the code on purpose instead of watching tests fail first

These tests describe code that already exists, so they pass as soon as they are written. For each task group, a deliberate change to a throwaway copy of the code must make that group's tests fail, which is the evidence they can fail.

### Assumptions

- "Assert" means automated tests in this change, as the proposal says.
- The sample data in `app/tests/integration/fixtures/data` is the "sample showroom data" in every scenario.
- Bugs found while writing tests are added to the specs and `docs/known-bugs/`. They are not fixed here.

## Risks / Trade-offs

- **A few outcomes were reasoned, not observed.** "Long values are cut in the list", "New customer can be quoted" and the workflows were not run before the specs were written. → If a test disagrees, the app is right and the spec is corrected.
- **The step library becomes a private language.** → Keep sentences few and reusable, and keep them in one file.
- **The suite grows slowly.** About 180 scenarios start the app more than once each. → Each run is a short process. Measured with all 180 in place, `make test` takes about 3 seconds locally, and the CI job about 9 seconds.
- **The pull request is large.** → One commit per task, grouped by capability, so it can be read in order.
- **Time.** 180 tests are a lot of work when TICKET-142 and `NOTES.md` are still to come. → Task groups run money and data first, so stopping early still leaves the most valuable part done, and the coverage check stays optional until the last group.
- **A test for a bug can look like approval.** → The `Known bug:` name and `docs/known-bugs/` make the status clear.

## Migration Plan

There is nothing to migrate. Data formats and logic do not change, so an older binary and this one read the same files in both directions, and the rollback in `docs/RELEASE.txt` is unaffected.

The pull request merges through the normal CD pipeline, and `prd` approval creates the `v2.5` tag. Rolling back means returning to `v2.4`, which behaves the same apart from the number on screen.
