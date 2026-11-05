# BUG-007: The wrong folder starts empty and reports failed saves as done

**Severity:** Medium
**Status:** Open
**Area:** Data files

## Steps to reproduce

1. Start the app from a folder with no `data/` folder.
2. Choose Stock, then List stock.
3. Choose Add vehicle, and add a vehicle.

## What happens today

The stock list shows "0 vehicle(s)" with no warning. Adding a vehicle shows "ERROR: cannot write next_ids.dat" and then "Vehicle 1000 added.", although nothing was saved.

## Impact

Staff could believe all their stock has gone, or keep working on changes that are lost when the app closes.

## Cause

The `load_` functions in `dbfile.c` treat a missing file as an empty list. The `save_` functions print an error but return nothing, so the screens report success anyway.

## Scenarios

- `Known bug: BUG-007 app starts empty`
- `Known bug: BUG-007 failed save reported as added`
