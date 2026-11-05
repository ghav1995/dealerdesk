# BUG-010: The same plate is accepted twice

**Severity:** Low
**Status:** Open
**Area:** Stock

## Steps to reproduce

1. Choose Stock, then Add vehicle.
2. Enter the plate LK19 XRT, which already exists.
3. Choose Find by plate, and enter LK19 XRT.

## What happens today

The app shows "Vehicle 1013 added.", and the search shows two vehicles.

## Impact

Plates identify a vehicle, so a duplicate is probably a mistake. Staff can still tell them apart by id.

## Cause

`add_vehicle` in `main.c` does not check existing plates.

## Scenarios

- `Known bug: BUG-010 same plate added twice`
