# BUG-008: Saving drops vehicles past the 500 limit

**Severity:** Medium
**Status:** Open
**Area:** Data files

## Steps to reproduce

1. Use a `stock.dat` holding 510 vehicles.
2. Start the app and change the price of any vehicle.
3. Count the lines in `stock.dat`.

## What happens today

The file holds 500 vehicles. The other 10 are gone, with no warning.

## Impact

The app stops adding vehicles at 500, so this needs a file already over the limit, for example one edited by hand. If it happens, data is lost for good. The customer and invoice limits load the same way.

## Cause

`load_stock` in `dbfile.c` stops at `MAX_VEH`, and `save_stock` rewrites the whole file from what was loaded.

## Scenarios

- `Known bug: BUG-008 save drops vehicles over the limit`
