# Proposal

## Why

Fleet deals with local businesses are about to start, with Greenway Taxis first. Staff give these customers their discount by hand today, which the ticket says "is applied inconsistently, and it uses up the discount the salesperson has left to negotiate with". This change makes the discount automatic, and it is the feature TICKET-142 asks for.

## What Changes

Each change below answers one line of the ticket.

| Ticket | Change |
|---|---|
| "Sales staff can mark a customer as a **fleet** customer, both when adding a new customer and for existing ones like Greenway Taxis." | Add Customer asks a fleet question after the trade question. A new Customers menu option marks or unmarks an existing customer |
| "Fleet customers automatically get **4% off the vehicle price**. Fees (delivery, registration) are not discounted." | Quotes and sales take 4% off the list price for fleet customers. The salesman discount applies to what is left and is still limited to 15% |
| "The fleet discount appears as **its own line** on quotes and invoices, the same way the trade discount does." | Quotes, invoice previews and issued invoices show a "Fleet discount" line |
| "Everything that exists today must keep working exactly as it does now." | See below. One deliberate exception is the BUG-002 fix |

Also in this change:

- **Fix BUG-002 for all customers.** A blank phone or email currently loses the customer's type after a restart, so a fleet customer with no email would silently lose their 4%. Fixing how `customers.dat` is read also means a trade customer with a blank field keeps Trade.
- **Document both decisions with real prints.** `docs/fleet-discount.md` shows the BUG-002 behaviour before and after, and a Trade customer being refused, using captured output from the app.
- **Archive `map-current-behaviour` first.** Its 152 scenarios are not yet in `openspec/specs/`, and this change modifies some of them.
- **Bump the version to v2.7**, because every pull request must be `master` plus 0.1.

### What stays the same

- Quotes, invoices and totals for retail and trade customers, to the penny. The one exception is a customer with a blank phone or email, who is currently overcharged by BUG-002.
- Issued invoices. They display their stored amounts, so invoice 50232, Greenway's 8% hand discount from 2021, stays exactly as it is after Greenway becomes a fleet customer.
- Files with no fleet data. `customers.dat` keeps its five fields, and an invoice with no fleet discount keeps its eleven.
- Existing data files load with no conversion, and the previous version can still read files this version writes.
- The Help screen, the stock screens and the sell flow, apart from the fleet line.

### What staff will notice

- A "Fleet customer (Y/N)?" prompt when adding a non-trade customer.
- A new option on the Customers menu.
- The Fleet label, and the "Fleet discount" line for fleet customers.
- The version number in the screen header.

### Left open by the ticket

These are decided in `design.md`:

- Whether a customer can be both Trade and Fleet. **Decided by the product owner: Trade customers are refused, and the refusal is documented.**
- What happens when a fleet customer has a blank phone or email. **Decided by the product owner: fix it for all customers, and document it.**
- How fleet status is stored.
- Whether fleet status can be removed.
- Whether the salesman discount applies before or after the fleet discount.
- How an invoice with a fleet discount but no other discount shows its discounts line.

### Out of scope

- Any other known bug. BUG-001 is the same fault in `stock.dat`, but it does not affect fleet customers, so it stays for the sprint.
- Repairing customer records that BUG-002 has already damaged.
- Changing the Help screen, which would need its own change under BUG-009.
- A different discount rate per customer.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `customers`: Adds the fleet customer type, the fleet question and marking existing customers. Replaces the BUG-002 requirement with blank details surviving a restart.
- `pricing`: Adds the 4% fleet discount and applies the salesman discount after it.
- `quotes`: Adds the Fleet label and the "Fleet discount" line.
- `invoices`: Stores the fleet discount and shows it on its own line.
- `data-files`: Adds the `F` customer type and an optional twelfth invoice field, compatible in both directions.
- `navigation`: Adds the new Customers menu option.
- `business-workflows`: Adds the end-to-end fleet journey.

## Impact

- **Code:** `app/src/calc.c`, `calc.h`, `dbfile.c`, `globals.h`, `main.c`, and the version in `screen.c`.
- **Data files:** new values only for fleet customers and fleet invoices. No conversion is needed.
- **Tests:** new unit and scenario tests. The `customers` baseline is re-recorded, because that screen changes on purpose. All other baselines must pass unchanged, which is the proof that non-fleet behaviour has not moved.
- **Test tooling:** the coverage check learns about requirements a change removes, which every sprint bug fix will need too.
- **Docs:** `docs/fleet-discount.md`, the README pricing rules, `AGENTS.md`, and BUG-002 in `docs/known-bugs/`.
- **Operations:** staff need to be told to stop giving fleet customers a hand discount, or they will receive both.
