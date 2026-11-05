# Tasks

Every task is one small commit. These tests describe existing code, so they pass once written. In place of a failing test first, each capability group ends by breaking a throwaway copy of the code and confirming the group's tests fail.

## 1. Open the pull request

- [x] 1.1 Commit the planning artifacts on `feature/map-system-behaviour`, leaving out `app/data`, and verify `openspec validate --all --strict` passes.
- [x] 1.2 Bump the version to v2.5 in `app/src/screen.c` and the README title as its own commit, and verify `make version` prints v2.5 and `make test` passes.
- [ ] 1.3 Push the branch and open a pull request into `master` on `ghav1995/dealerdesk`, and verify its base is the fork's `master` and CI passes, including the version check.

## 2. Scenario test harness

- [x] 2.1 Add `app/tests/integration/behaviour/steps.sh` and `run.sh` with the `Scenario`, `Given`, `When`, `Then` and `And` functions, a private data folder per scenario, and one working scenario, and verify it passes and leaves `app/data` untouched.
- [x] 2.2 Make an unrecognised sentence and a failed `Then` fail the run with a readable message, and verify both by running a deliberately wrong scenario.
- [x] 2.3 Add a `make test-behaviour` target, include it in `make test`, and verify `make test` runs it from a clean tree.
- [x] 2.4 Add a coverage script that lists spec scenarios with no test and tests with no scenario, in report-only mode, and verify it reports all 180 scenarios except the working one.
- [x] 2.5 Document the harness in the repository map and commands in `AGENTS.md`, and in the README, and verify the documented commands run as written.

## 3. Pricing

- [x] 3.1 Write scenario tests for the 9 existing pricing scenarios, naming `Half a penny` in a comment in `test_calc.c`, and verify they pass.
- [x] 3.2 Write scenario tests for the 9 new pricing scenarios, including BUG-004 and BUG-005, and verify they pass.
- [x] 3.3 Change the VAT rate and the trade rate in a throwaway copy, and verify the pricing tests fail.

## 4. Quotes

- [x] 4.1 Write scenario tests for the 10 quotes scenarios and verify they pass.
- [x] 4.2 Make a throwaway copy save data during a quote and allow sold vehicles to be quoted, and verify the quotes tests fail.

## 5. Invoices

- [x] 5.1 Write scenario tests for the 6 existing invoices scenarios and verify they pass.
- [x] 5.2 Write scenario tests for selling and recording a sale, including BUG-004 and BUG-015, and verify they pass.
- [x] 5.3 Write scenario tests for capacity, listing and viewing invoices, including BUG-011, and verify all 25 invoices scenarios pass.
- [x] 5.4 Make a throwaway copy skip marking the vehicle as sold and recalculate the total when viewing, and verify the invoices tests fail.

## 6. Data files

- [x] 6.1 Write scenario tests for the 4 existing data-files scenarios and verify they pass.
- [x] 6.2 Write scenario tests for restarts and id counters, and verify they pass.
- [ ] 6.3 Write scenario tests for missing files, short records and line endings, and verify they pass.
- [ ] 6.4 Write scenario tests for BUG-001, BUG-006, BUG-007, BUG-008 and BUG-013, and verify all 30 data-files scenarios pass.
- [ ] 6.5 Make a throwaway copy skip saving the id counters and change a field separator, and verify the data-files tests fail.

## 7. Customers

- [ ] 7.1 Write scenario tests for the 4 existing customers scenarios and verify they pass.
- [ ] 7.2 Write scenario tests for the 12 new customers scenarios, including BUG-002, and verify all 16 pass.
- [ ] 7.3 Make a throwaway copy allow a blank name and make the search ignore case, and verify the customers tests fail.

## 8. Stock

- [ ] 8.1 Write scenario tests for the 5 existing stock scenarios and verify they pass.
- [ ] 8.2 Write scenario tests for listing, adding and refusing vehicles, and verify they pass.
- [ ] 8.3 Write scenario tests for capacity, finding, repricing and reserving, including BUG-010 and BUG-014, and verify all 29 stock scenarios pass.
- [ ] 8.4 Make a throwaway copy upper-case plates and allow a zero list price, and verify the stock tests fail.

## 9. Input handling

- [ ] 9.1 Write scenario tests for numbers, money and BUG-003, and verify they pass.
- [ ] 9.2 Write scenario tests for yes/no answers, long text, pipes and input ending early, and verify all 23 input-handling scenarios pass.
- [ ] 9.3 Make a throwaway copy stop replacing pipes and accept only upper case Y, and verify the input-handling tests fail.

## 10. Navigation

- [ ] 10.1 Write scenario tests for menus, headers, invalid choices and going back, and verify they pass.
- [ ] 10.2 Write scenario tests for pausing, Help, BUG-009 and BUG-012, and verify all 21 navigation scenarios pass.
- [ ] 10.3 Remove a menu option and change a Help line in a throwaway copy, and verify the navigation tests fail.

## 11. Business workflows

- [ ] 11.1 Write scenario tests for the 8 business-workflows scenarios and verify they pass.
- [ ] 11.2 Make a throwaway copy let a sale use a stale price, and verify the workflow tests fail.

## 12. Known bugs folder

- [ ] 12.1 Add `docs/known-bugs/README.md` with the severity scale, a file template and an index of all 15 bugs, link it from the README, and verify every link resolves.
- [ ] 12.2 Add the files for the High bugs, BUG-001 to BUG-004, and verify each one's reproduction steps by running them.
- [ ] 12.3 Add the files for the Medium bugs, BUG-005 to BUG-009, and verify each one's reproduction steps by running them.
- [ ] 12.4 Add the files for the Low bugs, BUG-010 to BUG-015, and verify each one's reproduction steps by running them.
- [ ] 12.5 Verify every `BUG-NNN` in the specs has a file, and every file names scenarios that exist in the specs.

## 13. Final checks

- [ ] 13.1 Make the coverage script fail the build and run it from `make test`, and verify it passes with all 180 scenarios covered.
- [ ] 13.2 Verify the guarantee: `git diff master -- app/src` shows only the version line, and `git diff master -- app/tests/integration/expected app/tests/integration/scenarios app/data` is empty.
- [ ] 13.3 Verify `make test` and `openspec validate --all --strict` pass from a clean tree, CI passes on the pull request, and record how long CI takes.

## Workflow follow-up

- Archive the change with `/opsx:archive` once the tasks are done and reviewed, which merges the delta specs into `openspec/specs/`, and push the result to the pull request.
- Merge the pull request with a merge commit, never a squash.
- Approve the CD stages through `prd`, which creates the `v2.5` tag.
