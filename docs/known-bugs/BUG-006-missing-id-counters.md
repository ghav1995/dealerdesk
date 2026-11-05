# BUG-006: A missing next_ids.dat reuses ids

**Severity:** Medium
**Status:** Open
**Area:** Data files

## Steps to reproduce

1. Delete `data/next_ids.dat`.
2. Start the app and add a vehicle.
3. Add a second vehicle.

## What happens today

The first vehicle gets id 1000 and the second gets 1001, which already belongs to another vehicle. `stock.dat` then holds two vehicles with the same id.

## Impact

Lookups by id find the first match, so the new vehicle cannot be reached by id. Customers and invoices fall back to their starting numbers in the same way, and duplicate invoice numbers would be worse.

## Cause

`load_ids` in `dbfile.c` silently keeps the starting numbers set in `main.c` when the file is missing, and never checks them against the highest existing id.

## Scenarios

- `Known bug: BUG-006 duplicate vehicle id`
