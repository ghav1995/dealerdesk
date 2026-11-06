# Design

## Context

See `proposal.md` for why. This design explains how the fleet discount fits a codebase with these constraints:

- `customers.dat` holds a one-letter type, and `calc_quote` already takes that letter.
- `invoices.dat` keeps all discounts as one amount, so an invoice cannot show a fleet line today.
- `docs/RELEASE.txt` rolls back by putting the old binary on the same data files, so an older version must be able to read what this version writes.
- The `strtok` reader in `dbfile.c` skips empty fields, which is BUG-002.
- `map-current-behaviour` is not archived, and this change modifies requirements that only exist there.

## Goals / Non-Goals

**Goals:**

- Make the ticket's four acceptance criteria provable by tests.
- Keep retail and trade output byte-identical, with the BUG-002 fix as the one stated exception.
- Keep rollback to v2.6 safe.

**Non-Goals:**

- Repairing damaged customer records.
- A general edit-customer screen.
- Fixing BUG-001, or changing how `stock.dat` or `invoices.dat` are parsed.

## Decisions

### Decision: Store fleet as customer type F

`customers.dat` keeps its five fields, and fleet customers get the type `F`.

This is what makes rollback safe. Version 2.6 treats any type other than `T` as Retail with no discount, and it writes the letter back unchanged, so an `F` customer survives a save by the old binary. `calc_quote` needs no new parameter, because it already receives the type.

Alternative rejected: a sixth field. An old binary would drop it on its next save, silently removing fleet status, which breaks rule 3 in `AGENTS.md`. It would also allow Trade and Fleet together, which the product owner ruled out.

### Decision: Trade customers cannot be fleet (product owner)

Marking a trade customer shows "Trade customers cannot be fleet customers." and changes nothing. The Add Customer flow only asks the fleet question when the trade answer was no, so the two can never combine.

Alternatives rejected: replacing Trade with Fleet, which would cut a customer's discount from 10% to 4% on one wrong keystroke, and stacking both, which needs the sixth field above.

The cost is that a customer truly moving from Trade to Fleet needs a new record, because no edit-customer screen exists. `docs/fleet-discount.md` shows the refusal with a real print.

### Decision: Fix BUG-002 for all customers (product owner)

`load_customers` stops using `strtok` and splits on `|` with a small helper that keeps empty fields. `strsep` is not used, because it is not portable C. Only `customers.dat` changes.

This is needed because a fleet customer with no email would otherwise lose their 4% after a restart. A trade customer with a blank field now also keeps Trade, so their total drops to the correct trade price. That is the one place a non-fleet total changes, and the ticket's "unchanged, to the penny" does not cover it literally. It was accepted because those customers are being overcharged today, and the sample data has no such rows, so the baseline does not move.

Alternatives rejected: requiring a phone and email for fleet, which leaves customers with blank details unable to become fleet, and fixing fleet rows only, which keeps a known overcharge and adds an odd special case.

What happens today, captured from v2.6 on throwaway data:

```text
Customer 2009 added.
2009|No Email Ltd|01632 960123||T

  ID    NAME                       PHONE          EMAIL                        TYPE
  2002  Marlow Motors Ltd          01632 960118   buying@marlowmotors.example  Trade
  2009  No Email Ltd               01632 960123   T                            Retail

  QUOTATION (valid 7 days)
  ----------------------------------------------
  Customer : No Email Ltd (Retail)
  Vehicle  : yf20 hbn Vauxhall Corsa 1.2 SE
  ----------------------------------------------
  List price                   10995.00
  Net price                    10995.00
  Delivery                       150.00
  VAT 20%                       2229.00
  Registration fee                55.00
  ==============================================
  TOTAL                        13429.00
```

The same car for a trade customer with full details totals 12109.60, so this customer is overcharged by 1319.40.

### Decision: Do not repair records the bug has already damaged

The capture also showed that the damage becomes permanent. After a restart, the next save of any customer rewrites the row:

```text
2009|No Email Ltd|01632 960123|T|R
```

Reading that row correctly gives an email of `T` and the type `R`, which is exactly what it now says. It can be spotted by eye, but guessing at repairs inside a billing system is riskier than leaving it. `docs/fleet-discount.md` gives a command to find such rows so a person can correct them:

```text
grep -E '\|[TF]\|R$' data/customers.dat
```

Alternative rejected: repairing rows on load, which could rewrite a genuine record and would change data no one asked to change.

### Decision: Mark and unmark from one Customers menu option

Option 4 on the Customers menu, "Mark / unmark fleet customer", asks for a customer id and switches retail to fleet or fleet back to retail. It follows Reserve / release on the Stock menu, which staff already know.

Alternative rejected: mark only. With no edit-customer screen, a mistake could never be undone. The ticket does not ask for unmarking, so this is an assumption.

### Decision: Ask the fleet question after the trade question

`add_customer` asks "Fleet customer (Y/N)?" only when the trade answer was no. The name check still happens after all the prompts, as it does today.

Alternative rejected: one combined question, which would change the prompt every trade customer sees.

### Decision: Take 4% off the list price, then apply the salesman discount

`calc_quote` gains a `fleet_disc` calculated as `rnd2(list * 0.04)`, in the same place and style as the trade discount. The salesman percentage then applies to the list price less both, and the existing 15% limit does not count the fleet discount, because saving that allowance is the point of the ticket.

Alternative rejected: applying the salesman discount to the full list price, which would give a fleet customer more off than a trade customer gets from the same percentage, and differs from how trade works.

### Decision: Keep `disc` as all discounts, and append the fleet amount

`INVOICE.disc` stays "all discounts together", and a new `fleet_disc` is added. `save_invoices` writes it as a twelfth field only when it is above zero, and `load_invoices` treats a missing field as zero.

Keeping it in `disc` means an old binary still shows the correct net price and total. Writing the field only when needed keeps every non-fleet record byte-identical, which the `sales` baseline proves.

Alternatives rejected: leaving fleet out of `disc`, which makes the amounts on an old binary stop adding up, and always writing the twelfth field, which changes every invoice row on the next save.

### Decision: Hide the discounts line on a fleet invoice with nothing else to show

An invoice with a fleet discount shows "Fleet discount", then "Discounts" only if `disc` minus the fleet amount is above zero. Otherwise it would print `-0.00`, which is BUG-011. Non-fleet invoices are untouched, so BUG-011 stays for the sprint.

### Decision: Teach the coverage check about changes in progress

`make test` fails if a spec scenario has no test, but two things now need more care:

- A delta scenario cannot have a test on the same commit that adds it to the plan, so scenarios in an active change are reported as pending and do not fail the build until they are archived.
- Removing a requirement, as BUG-002 does, leaves its scenarios in the main specs until archive, so the check skips scenarios under a requirement an active change removes.

Every sprint bug fix hits the second case, so this is worth doing once. Archiving before merge then makes every scenario mandatory again.

Alternative rejected: keeping old test names until archive, which leaves tests with names that say the opposite of what they assert.

### Decision: Re-record only the customers baseline

The customers screen changes on purpose, so `customers.keys` gains an answer to the fleet question and `expected/customers.txt` is re-recorded. The other five baselines must pass untouched. That is the proof of "non-fleet quotes and invoices are unchanged, to the penny". The diff of `customers.txt` may only contain the new menu line and the new prompt.

The scenario step for adding a customer must answer the fleet question, or input would end before the customer is saved.

### Decision: Document decisions with captured prints

`docs/fleet-discount.md` explains the feature and the two product decisions, using output captured from the real app, never typed by hand. It covers the BUG-002 behaviour before and after, a Trade customer being refused, and a fleet quote and invoice. BUG-002's file shows the same before and after, and its status becomes Fixed.

### Assumptions

- A customer can be unmarked, as above.
- Help text stays as it is. A fleet line could be added, but the screen already has three false statements, and BUG-009 should fix it as one change.
- The rate is one fixed 4%, as the ticket says.
- Quotes do not record the customer's status, so a quote is priced by their status at that moment.
- Rollback checks use v2.6, the version this replaces.

## Data compatibility

| Written by | Read by | Result |
|---|---|---|
| v2.6 or earlier | v2.7 | Loads with no conversion. Invoices with eleven fields have no fleet discount |
| v2.7, customer type `F` | v2.6 | Shows as Retail with no discount, and the `F` survives its saves |
| v2.7, invoice with twelve fields | v2.6 | Reads the first eleven. Net, VAT and total are correct, and discounts show as one amount |
| v2.7, invoice saved again by v2.6 | v2.6 or v2.7 | v2.6 drops the twelfth field, so that invoice loses its separate fleet line. All amounts stay correct |
| v2.7, blank phone or email | v2.6 | Misread as it is today, because that is the bug |

The fourth row is a real but small loss: if v2.6 saves after a rollback, fleet invoices show their discount in the combined line. No money changes, and rule 3's limit on an old binary dropping unknown fields makes this unavoidable with an appended field.

While rolled back to v2.6, fleet customers get no automatic discount. Staff would need to apply it by hand until v2.7 returns.

## Risks / Trade-offs

- **Hand discounts on top of the fleet discount.** A salesperson used to typing 4% or 8% would now give both. → The proposal asks for staff to be told, and the quote shows the separate fleet line.
- **Non-fleet staff see a new prompt.** Everyone adding a retail customer presses ENTER once more. → The ticket asks for this, and a blank answer means no.
- **Damaged records stay damaged.** → A documented command finds them, and they stay readable.
- **A re-recorded baseline could hide a real change.** → Only `customers.txt` may change, and only the two expected kinds of line. The final check confirms the other baselines are untouched.
- **BUG-001 remains.** The same fault still affects `stock.dat`. → It stays in `docs/known-bugs/`, and the new helper can be reused to fix it.
- **Pipeline queue.** `v2.6` has no tag yet, and old CD runs are still queued. → Both are dealt with before this merges, as the Migration Plan says.

## Migration Plan

1. Tag `v2.6`, and clear the old CD runs for v2.4 and v2.5, so the queue is free.
2. Merge with the `merge-and-tag` skill, which creates the `v2.7` tag that starts CD.
3. Approve the CD stages.
4. On release, mark Greenway Taxis (2008) as a fleet customer. Their earlier invoice does not change.
5. Tell sales staff to stop giving fleet customers a hand discount.

No data conversion is needed. To roll back, follow `docs/RELEASE.txt` and see Data compatibility above.
