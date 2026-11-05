# BUG-009: The Help screen states wrong rules

**Severity:** Medium
**Status:** Open
**Area:** Navigation

## Steps to reproduce

1. Choose Help on the main menu.

## What happens today

Three statements on the screen are false:

| Help says | The app does |
|---|---|
| Trade customers receive a 5% trade discount | Applies 10%, confirmed by invoice 50231 |
| Salesman discounts above 10% require a manager PIN | Asks for no PIN, and reduces anything above 15% to 15% |
| Plates are converted to upper case automatically | Stores plates exactly as typed |

## Impact

Staff can quote customers the wrong discount or expect a check that no longer exists. A customer told 5% would actually get 10%.

## Cause

The code changed in 2016 and 2019, and the Help text in `main.c` was never updated. Correcting it changes what staff see, so it needs its own change.

## Scenarios

- `Known bug: BUG-009 Help gives the wrong trade discount`
- `Known bug: BUG-009 Help describes a removed manager PIN`
- `Known bug: BUG-009 Help says plates become upper case`
