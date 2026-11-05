# BUG-013: Comments are lost when a file is saved

**Severity:** Low
**Status:** Open
**Area:** Data files

## Steps to reproduce

1. Add a line starting with `#` to `data/stock.dat`.
2. Start the app and change the price of any vehicle.
3. Open `data/stock.dat`.

## What happens today

The comment line is gone.

## Impact

The loader skips comments, which suggests they are allowed, but a note someone leaves in a file disappears at the next save. No vehicle data is affected.

## Cause

`save_stock` in `dbfile.c` rewrites the file from memory, and comments are not kept when it loads. The other files behave the same way.

## Scenarios

- `Known bug: BUG-013 comment lost on save`
