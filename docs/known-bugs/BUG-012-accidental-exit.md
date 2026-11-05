# BUG-012: ENTER or letters on the main menu exit the app

**Severity:** Low
**Status:** Open
**Area:** Navigation

## Steps to reproduce

1. Start the app.
2. Press ENTER without typing anything, or type letters and press ENTER.

## What happens today

The app says "Goodbye." and exits. On a submenu, the same input goes back to the main menu.

## Impact

Staff can leave the app by accident. No data is lost, because every change is saved straight away.

## Cause

`read_int` in `screen.c` uses `atoi`, which gives 0 for blank or non-numeric input, and 0 means Exit on the main menu.

## Scenarios

- `Known bug: BUG-012 ENTER on the main menu exits`
- `Known bug: BUG-012 letters on the main menu exit`
