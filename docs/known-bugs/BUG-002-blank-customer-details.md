# BUG-002: Blank phone or email loses Trade status after a restart

**Severity:** High
**Status:** Open
**Area:** Data files, customers

## Steps to reproduce

1. Choose Customers, then Add customer.
2. Enter a name, leave the email blank, and answer Y to the trade question.
3. Exit and start the app again.
4. Choose Quote, and quote vehicle 1002 for the new customer.

## What happens today

The customer shows as Retail, and the quote has no trade discount. The total is 13429.00 instead of the trade price.

With a blank phone, the email also appears in the phone column.

## Impact

Trade customers are overcharged by their 10% discount, and staff are not told. TICKET-142 is affected too, because a fleet customer with no email would lose fleet status the same way.

## Cause

`dbfile.c` splits records with `strtok`, which skips empty fields, so the type moves into the wrong column and falls back to Retail. `add_customer` only requires a name.

## Scenarios

- `Known bug: BUG-002 trade customer with no email becomes Retail`
- `Known bug: BUG-002 trade customer with no phone becomes Retail`
