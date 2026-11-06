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
    make test-behaviour     run the Given/When/Then scenarios
    make coverage           list spec scenarios with no test
    make golden             re-record the baseline (see rule 2)
    make version            print the current version
    openspec validate --all --strict

## Repository map

    app/src/                 main.c (menus, screens), calc.c (pricing),
                             dbfile.c (flat files), screen.c (terminal input)
    app/data/                sample data, rewritten whenever the app runs
    app/tests/unit/          test_*.c, plain C with no framework
    app/tests/integration/   scenarios/*.keys are keystrokes, expected/*.txt is
                             the baseline, fixtures/data is the starting data
    app/tests/integration/behaviour/
                             scenarios/*.sh hold one Given/When/Then test per spec
                             scenario, with the same name. steps.sh defines what
                             each sentence does
    openspec/specs/          what the system does today
    openspec/changes/        proposed changes, one folder each
    docs/fleet-discount.md   how the fleet discount works, with the decisions behind it
    docs/known-bugs/         bugs for the sprint, one file each, indexed by severity
    .github/workflows/       ci.yml runs make test. cd.yml starts from a version tag,
                             runs it, then deploys that tag to simulated dev, test,
                             qa and prd, each approved. rollback.yml returns prd to
                             a tag, and tag-guard.yml deletes tags not on master

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
   The only exception is the version number (see Versioning).
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
   pull request against the original repository. On a fork, `gh pr create` can
   default to the parent, so name the fork with `--repo` and check the target.

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

## Branches and pull requests

`master` is protected, so it only changes through a merged pull request. Nobody
can push to it directly, including admins.

1. Branch from `master` as `feature/<short-name>`.
2. Push the branch and open a pull request into `master` on the fork.
3. CI runs `make test` on every push to the branch. The `test` check must pass and
   the branch must be up to date with `master` before it can merge.
4. Merge with the `merge-and-tag` skill. It uses a merge commit, and never squashes
   because the individual commits are read as part of the work, then creates the
   version tag. Agents without skills follow
   `.claude/skills/merge-and-tag/SKILL.md` by hand.

The tag starts the CD pipeline, so a merge on its own deploys nothing.

## Versioning

The minor version goes up by one when a pull request is created, for example v2.3
to v2.4. That is one bump per pull request: individual changes do not bump it, and
neither do later pushes to the same pull request. CI fails unless the version is
exactly the version on `master` plus 0.1, read from the screen header in
`.github/scripts/check-version.sh`. Make the bump its own commit and use the same
number everywhere:

- `app/src/screen.c`: the header shown on every screen
- `README.md`: the title

To confirm, run `git grep -n -E 'v[0-9]+\.[0-9]+' -- app/src README.md`. Every
line should show the new number. If the version is added anywhere else, add that
file to this list.

Leave `docs/RELEASE.txt` alone. Its "Last release" line records what was really
deployed, so it only changes when someone does a real release.

A bump needs no OpenSpec change. The integration baseline masks the header
version, so never run `make golden` for a bump.

## Tags and rollback

A tag marks a version cut from `master` straight after its pull request merged. It
starts the CD pipeline, and every stage deploys that tag. The tag comes first, so it
does not prove the version reached `prd`: a version that fails `qa` keeps its tag,
and its CD run shows how far it got.

- Tags are annotated, named after the version, such as `v2.4`, and carry a full
  description of what changed.
- The `merge-and-tag` skill creates them, on `master`, after the merge. Never tag
  any other way. CD refuses a tag that is not on `master`, does not match the version
  in the code, or has an incomplete description (see
  `.github/scripts/check-tag-notes.sh`).
- A repository ruleset stops a `v*` tag being moved, so a description cannot be
  corrected after the push. `tag-guard.yml` deletes any `v*` tag that is not on
  `master`. A tag can still be deleted by hand.
- Every merged version is new, because CI requires `master` plus 0.1 (see
  Versioning), so every merge can be tagged.
- To deploy a tag again, run the CD workflow from that tag.
- To roll back, run the Rollback workflow with a tag whose CD run reached `prd`. It
  checks the tag is on `master` and goes straight to the `prd` approval, but it does
  not check the version reached `prd`, so the approver must. `docs/RELEASE.txt` has
  the steps for a real rollback.
- After a rollback, fix forward with a new pull request and a new version. Data files
  must still load on the older version (see rule 3).

## Known traps

Every known bug is in `docs/known-bugs/`, with a `Known bug:` scenario that asserts what the
app does today. That test passes while the bug exists, so a fix must change the test, the
spec and the bug's file on purpose.

- **Blank fields still shift columns in `stock.dat`.** `load_stock` splits with
  `strtok`, which skips empty fields, so a blank make or model moves every later
  field along and the price reads as 0.00 after a restart (BUG-001). `load_customers`
  uses `next_field`, which keeps them. Use it for anything with an optional field.
- **`INVOICE.disc` holds every discount added together.** That includes any fleet
  discount, which is also stored on its own in `fleet_disc`. The invoice screen
  cannot separate trade and salesman discounts.
- **`save_*` rewrites whole files.** An old binary drops any field it does not
  know about the moment it saves.
- **Reserved vehicles can still be sold.** `build_quote` only blocks sold vehicles.
  This may be a bug, but it is today's behaviour, so leave it.
- **A scenario can pass without testing anything.** The `.keys` files must follow
  each flow exactly. An error path stops asking questions, so leftover keystrokes
  become menu choices and a stray `0` exits the app, and the rest of the scenario
  never runs. When adding a scenario, check its last step is in `expected/`, and
  break the code on purpose to confirm the scenario fails.

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
