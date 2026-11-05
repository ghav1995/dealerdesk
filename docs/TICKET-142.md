# TICKET-142: Fleet discount on quotes and invoices

**Requested by:** Sales Director
**Priority:** High, needed for the new fleet contracts starting next month

## Background

We are signing fleet deals with local businesses (taxi firms, rental companies,
delivery services). Greenway Taxis is the first one.

Today sales staff give fleet customers their discount by hand, using the
salesman discount field. That is applied inconsistently, and it uses up the
discount the salesperson has left to negotiate with.

## What we need

1. Sales staff can mark a customer as a **fleet** customer, both when adding a
   new customer and for existing ones like Greenway Taxis.
2. Fleet customers automatically get **4% off the vehicle price**. Fees
   (delivery, registration) are not discounted.
3. The fleet discount appears as **its own line** on quotes and invoices, the
   same way the trade discount does.
4. Everything that exists today must keep working exactly as it does now.

## Acceptance criteria

- A quote for a fleet customer shows a "Fleet discount" line and the correct total.
- Quotes and invoices for non-fleet customers are unchanged, to the penny.
- Existing data files load without any manual conversion.
- Existing invoices still display correctly.
