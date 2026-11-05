# BUG-015: Reserved vehicles can be sold to anyone

**Severity:** Low
**Status:** Open
**Area:** Invoices, stock

## Steps to reproduce

1. Choose Sell vehicle.
2. Enter reserved vehicle 1006 and customer 2001.
3. Answer Y to the confirmation.

## What happens today

The invoice is created and the vehicle is marked as sold, with no warning that it was reserved.

## Impact

A vehicle held for one customer could be sold to another. This may be intended, because a reservation does not record who it is for, so the sprint should confirm it with the sales team and can close this if so.

## Cause

`build_quote` in `main.c` only blocks sold vehicles.

## Scenarios

- `Known bug: BUG-015 reserved vehicle sold`
