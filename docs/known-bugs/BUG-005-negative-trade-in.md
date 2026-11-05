# BUG-005: A negative trade-in adds to the total

**Severity:** Medium
**Status:** Open
**Area:** Pricing

## Steps to reproduce

1. Choose Quote.
2. Enter vehicle 1002 and customer 2001.
3. Enter no discount and a trade-in of -500.00.

## What happens today

The quote shows a trade-in of 500.00, and the total rises to 13929.00 from 13429.00.

## Impact

A typing mistake charges the customer more. It is less likely than BUG-004, but the app accepts it just as quietly.

## Cause

`build_quote` does not check the trade-in, while the salesman discount is limited in `calc_quote`.

## Scenarios

- `Known bug: BUG-005 negative trade-in increases the total`
