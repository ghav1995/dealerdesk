# Tasks

Every task is one small commit that builds and passes `make test`. Where a task changes behaviour, write its tests first and see them fail for the right reason, then write the code.

## 1. Prepare the branch and pull request

- [x] 1.1 Change `check-coverage.sh` so scenarios in an active change are reported as pending without failing, and scenarios under a requirement an active change removes are skipped, then verify with a throwaway spec and test that a missing main scenario and an unknown test still fail the build.
- [x] 1.2 Archive `map-current-behaviour` with `openspec archive map-current-behaviour --yes`, and verify the main specs hold all 180 scenarios, `make test` passes, and `openspec validate add-fleet-discount --strict` no longer says archive would refuse this delta.
- [x] 1.3 Commit the planning artifacts on `feature/fleet-discount`, and verify `openspec validate --all --strict` and `make test` pass.
- [x] 1.4 Bump the version to v2.7 in `app/src/screen.c` and the README title as its own commit, and verify `make version` prints v2.7 and `make test` passes.
- [ ] 1.5 Push the branch and open a pull request into `master` on `ghav1995/dealerdesk`, and verify its base is the fork's `master` and CI passes, including the version check.

## 2. Fix BUG-002: blank customer details

- [x] 2.1 Replace the two `Known bug: BUG-002` tests with `Trade customer with no email stays Trade`, `Trade customer with no phone stays Trade`, `Retail customer with no phone or email`, `Blank details are kept by a later save` and `Record damaged by the old bug`, and see the first four fail.
- [x] 2.2 Make `load_customers` keep empty fields, using a C89 helper in `dbfile.c`, and verify the new tests pass, the short and unusual record scenarios still pass, and all six baselines pass unchanged.
- [x] 2.3 Capture the after print of the BUG-002 scenario from the real app, using the steps in `design.md`, to use in group 7.

## 3. Mark customers as fleet

- [x] 3.1 Write tests for `Retail customer marked as fleet`, `Marking an unknown customer`, `Fleet customer in the list`, `Fleet customer returned to retail`, `Fleet status after a restart`, `Marking a customer changes only that record`, and the changed navigation scenarios, and see them fail.
- [x] 3.2 Add the Customers menu option, the marking screen and the Fleet label in the list, re-record only `expected/customers.txt`, and verify its diff contains only the new menu line and the other five baselines are unchanged.
- [x] 3.3 Write the test `Trade customer refused` and see it fail, then refuse trade customers on the marking screen, and verify the data files stay unchanged.
- [x] 3.4 Capture the print of a Trade customer being refused from the real app, to use in group 7.

## 4. Ask the fleet question

- [x] 4.1 Write tests for `Fleet customer added`, `Trade customer is not asked the fleet question` and `Blank answer to the fleet question`, teach the add-customer step to answer the fleet question, and see the new tests fail.
- [x] 4.2 Add the question to `add_customer`, add its answer to `customers.keys`, re-record only `expected/customers.txt`, and verify its diff contains only the new prompt and the other five baselines are unchanged.

## 5. Fleet discount on quotes

- [x] 5.1 Add unit tests to `test_calc.c` for type `F`, using the worked amounts in the pricing spec and proving retail and trade results do not change, and see them fail.
- [x] 5.2 Add `fleet_disc` to `QUOTE` and calculate it in `calc_quote`, applying the salesman discount after it, and verify the unit tests pass and all six baselines pass unchanged.
- [x] 5.3 Write the fleet scenario tests for `pricing` and `quotes`, including `Discount after fleet discount`, `Fleet discount does not use up the salesman limit`, `Fleet quote heading` and `Fleet customer with no email stays Fleet`, and see the ones that depend on the screen fail.
- [x] 5.4 Show the "Fleet discount" line and the Fleet label in `print_quote`, and verify the tests pass and all six baselines pass unchanged.

## 6. Fleet discount on invoices

- [x] 6.1 Write tests for `Fleet sale amounts`, `Fleet sale with every deduction`, `Invoice with a fleet discount has twelve fields`, `Invoice with no fleet discount keeps eleven fields` and `Earlier invoices are unchanged by a fleet sale`, and see them fail.
- [x] 6.2 Add `fleet_disc` to `INVOICE`, store it in `sell_vehicle`, and load and save it as a twelfth field only when above zero, and verify the tests pass and the `sales` baseline is unchanged.
- [x] 6.3 Write tests for `Fleet invoice with no other discount`, `Fleet invoice with another discount`, `Invoice preview for a fleet customer`, `Earlier invoice after a customer becomes fleet`, `Fleet invoice after fleet status is removed` and `Invoice from an earlier version`, and see the display ones fail.
- [x] 6.4 Show the fleet line in `view_invoice`, with the discounts line only for other discounts on a fleet invoice, and verify the tests pass and the `invoices` baseline is unchanged.
- [x] 6.5 Write the four `business-workflows` scenario tests and verify they pass, breaking a throwaway copy to confirm they can fail.

## 7. Documentation with real prints

- [x] 7.1 Add `docs/fleet-discount.md` explaining the feature and both product decisions, with captured prints of the BUG-002 behaviour before and after, a Trade customer being refused, and a fleet quote and invoice, and verify each print matches a fresh run of the app.
- [x] 7.2 Update `BUG-002` with its before and after prints, the damaged-record warning and the `grep` command, set its status to Fixed in the file and the index, and verify the command finds a damaged row.
- [x] 7.3 Update the README pricing rules and customer type, and link `docs/fleet-discount.md`, and verify every statement against the app.
- [x] 7.4 Update `AGENTS.md` by narrowing the blank-field trap to `stock.dat`, removing the customer label trap, replacing the invoice discount trap, and removing the TICKET-142 section now its decisions live in `design.md`, and verify `grep` finds no stale claims.

## 8. Final checks

- [x] 8.1 Verify rollback by building the v2.6 code and running it on data files written by this version, confirming the results in the design's Data compatibility table, including the loss of the fleet line after v2.6 saves, and record the output in `docs/fleet-discount.md`.
- [ ] 8.2 Verify the ticket's acceptance criteria: only `expected/customers.txt` differs from `master` in the baseline, its diff contains only the menu line and the prompt, and `app/data` and the fixtures are unchanged.
- [ ] 8.3 Verify every commit builds and passes from a clean tree, and `make test` and `openspec validate --all --strict` pass.
- [ ] 8.4 Verify CI passes on the pull request and `make coverage` shows every pending scenario has a test.

## Workflow follow-up

- Tag `v2.6` and clear the old CD runs for v2.4 and v2.5 before merging, so the CD queue is free.
- Archive this change with `/opsx:archive` once the tasks are done and reviewed, which merges its specs into `openspec/specs/`, makes every scenario mandatory, and removes the BUG-002 requirement. Push the result to the pull request.
- Merge with the `merge-and-tag` skill, which creates the `v2.7` tag that starts CD. Never squash.
- Approve the CD stages through `prd`.
- After release, mark Greenway Taxis (2008) as a fleet customer, and tell sales staff to stop giving fleet customers a hand discount.
