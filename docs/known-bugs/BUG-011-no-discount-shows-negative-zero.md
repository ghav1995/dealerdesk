# BUG-011: No discount shows as -0.00

**Severity:** Low
**Status:** Open
**Area:** Invoices

## Steps to reproduce

1. Sell vehicle 1002 to customer 2001 with no discount.
2. Choose Invoices, then View invoice, and enter the new invoice number.

## What happens today

The discounts line shows -0.00.

## Impact

It looks wrong on an invoice, but no amount is affected.

## Cause

`view_invoice` in `main.c` prints `-p->disc`, and negating zero gives negative zero, which `printf` shows with a minus sign.

## Scenarios

- `Known bug: BUG-011 no discount shows as -0.00`
