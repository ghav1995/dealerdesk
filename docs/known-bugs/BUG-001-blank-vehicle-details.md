# BUG-001: Blank make or model loses the price after a restart

**Severity:** High
**Status:** Open
**Area:** Data files, stock

## Steps to reproduce

1. Choose Stock, then Add vehicle.
2. Enter a plate, leave the make blank, and enter a list price of 2000.00.
3. Exit and start the app again.
4. Choose Stock, then Find by plate, and enter the plate.

## What happens today

The vehicle's details shift by one column when the file is read. The price shows as 0.00, and the model appears as the make.

The vehicle can still be sold. Selling it produces an invoice with a list price of 0.00 and a total of 235.00, which is the fees and the VAT on delivery.

A blank model has the same effect.

## Impact

A £2,000 car can be invoiced for £235. Nothing warns staff, and the app accepts a blank make or model when the vehicle is added.

## Cause

`dbfile.c` splits records with `strtok`, which skips empty fields, so every later field moves one column to the left. `add_vehicle` only requires a plate and a list price.

## Scenarios

- `Known bug: BUG-001 blank make loses the price`
- `Known bug: BUG-001 blank model loses the price`
- `Known bug: BUG-001 vehicle sold at the lost price`
