# BUG-014: A negative cost price is accepted

**Severity:** Low
**Status:** Open
**Area:** Stock

## Steps to reproduce

1. Choose Stock, then Add vehicle.
2. Enter a cost price of -500.
3. Open `data/stock.dat`.

## What happens today

The vehicle is saved with a cost of -500.00, with no warning.

## Impact

The cost is stored but not shown or used anywhere since reports were removed, so nothing is affected today. It would matter if margin reports came back.

## Cause

`add_vehicle` in `main.c` checks the list price but not the cost.

## Scenarios

- `Known bug: BUG-014 negative cost price`
