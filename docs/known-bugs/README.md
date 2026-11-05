# Known bugs

Bugs found while mapping how DealerDesk behaves, for the sprint to address. None of them has been fixed.

Each bug has a test that asserts what the app does today, in a scenario named `Known bug: ...`. That test passes while the bug exists, so fixing a bug makes its test fail. A fix must change the test and the spec on purpose, and update the status in the bug's file.

## Severity

| Severity | Meaning |
|---|---|
| High | Wrong money, or data silently lost, in normal daily use |
| Medium | Wrong result only in unusual conditions, or staff are misled |
| Low | An annoyance, with no effect on money or stored data |

## Index

| Bug | Summary | Severity | Status |
|---|---|---|---|
| [BUG-001](BUG-001-blank-vehicle-details.md) | Blank make or model loses the price after a restart | High | Open |
| [BUG-002](BUG-002-blank-customer-details.md) | Blank phone or email loses Trade status after a restart | High | Open |
| [BUG-003](BUG-003-comma-in-amounts.md) | A comma cuts an amount short | High | Open |
| [BUG-004](BUG-004-trade-in-above-amount-due.md) | A trade-in above the amount due gives a negative total | High | Open |
| [BUG-005](BUG-005-negative-trade-in.md) | A negative trade-in adds to the total | Medium | Open |
| [BUG-006](BUG-006-missing-id-counters.md) | A missing `next_ids.dat` reuses ids | Medium | Open |
| [BUG-007](BUG-007-wrong-working-folder.md) | The wrong folder starts empty and reports failed saves as done | Medium | Open |
| [BUG-008](BUG-008-files-over-the-limit.md) | Saving drops vehicles past the 500 limit | Medium | Open |
| [BUG-009](BUG-009-help-screen-wrong-rules.md) | The Help screen states wrong rules | Medium | Open |
| [BUG-010](BUG-010-duplicate-plates.md) | The same plate is accepted twice | Low | Open |
| [BUG-011](BUG-011-no-discount-shows-negative-zero.md) | No discount shows as -0.00 | Low | Open |
| [BUG-012](BUG-012-accidental-exit.md) | ENTER or letters on the main menu exit the app | Low | Open |
| [BUG-013](BUG-013-comments-lost-on-save.md) | Comments are lost when a file is saved | Low | Open |
| [BUG-014](BUG-014-negative-cost-price.md) | A negative cost price is accepted | Low | Open |
| [BUG-015](BUG-015-reserved-vehicles-sold.md) | Reserved vehicles can be sold to anyone | Low | Open |

## Adding a bug

Name the file `BUG-NNN-short-name.md`, add it to the index, and use these sections:

```markdown
# BUG-NNN: Short description

**Severity:** High, Medium or Low
**Status:** Open
**Area:** The part of the app affected

## Steps to reproduce

## What happens today

## Impact

## Cause

## Scenarios
```

`Scenarios` lists the exact scenario names that assert the bug, so the bug and its tests can be found from each other.
