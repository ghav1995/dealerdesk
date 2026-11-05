# BUG-004: A trade-in above the amount due gives a negative total

**Severity:** High
**Status:** Open
**Area:** Pricing, invoices

## Steps to reproduce

1. Choose Sell vehicle.
2. Enter vehicle 1002 and customer 2001.
3. Enter no discount and a trade-in of 99999.00.
4. Answer Y to the confirmation.

## What happens today

The preview shows a total of -86570.00, and the invoice is saved with that total.

## Impact

A mistyped trade-in creates an issued invoice with a negative total. Issued invoices are permanent records, and the app has no way to correct one.

## Cause

`calc_quote` in `calc.c` subtracts the trade-in without checking it against the amount due, and `build_quote` does not check the value entered.

## Scenarios

- `Known bug: BUG-004 trade-in larger than the total`
- `Known bug: BUG-004 invoice saved with a negative total`
