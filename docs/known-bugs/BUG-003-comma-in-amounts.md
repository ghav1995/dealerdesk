# BUG-003: A comma cuts an amount short

**Severity:** High
**Status:** Open
**Area:** Input handling

## Steps to reproduce

1. Choose Stock, then Add vehicle.
2. Enter the list price as `10,995`.
3. Choose Stock, then Find by plate, and enter the plate.

## What happens today

The vehicle is saved with a price of 10.00. The same happens to a new price, where `1,000` becomes 1.00, and to a trade-in, where `1,000` takes only 1.00 off the total.

## Impact

Commas are a natural way to type these amounts. A vehicle can be listed at a fraction of its price, and a customer can lose most of their trade-in value, with no warning either way.

## Cause

`read_money` in `screen.c` uses `atof`, which stops at the first character it cannot read.

## Scenarios

- `Known bug: BUG-003 list price typed with a comma`
- `Known bug: BUG-003 new price typed with a comma`
- `Known bug: BUG-003 trade-in typed with a comma`
