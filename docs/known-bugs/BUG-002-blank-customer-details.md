# BUG-002: Blank phone or email loses Trade status after a restart

**Severity:** High
**Status:** Fixed in v2.7
**Area:** Data files, customers

## Steps to reproduce

1. Choose Customers, then Add customer.
2. Enter a name, leave the email blank, and answer Y to the trade question.
3. Exit and start the app again.
4. Choose Quote, and quote vehicle 1002 for the new customer.

## What used to happen

The customer showed as Retail, and the quote had no trade discount. The total was 13429.00 instead of the trade price. With a blank phone, the email also appeared in the phone column. Captured from v2.6:

```text
  ID    NAME                       PHONE          EMAIL                        TYPE
  2002  Marlow Motors Ltd          01632 960118   buying@marlowmotors.example  Trade
  2009  No Email Ltd               01632 960123   T                            Retail
```

```text
  QUOTATION (valid 7 days)
  ----------------------------------------------
  Customer : No Email Ltd (Retail)
  Vehicle  : yf20 hbn Vauxhall Corsa 1.2 SE
  ----------------------------------------------
  List price                   10995.00
  Net price                    10995.00
  Delivery                       150.00
  VAT 20%                       2229.00
  Registration fee                55.00
  ==============================================
  TOTAL                        13429.00
```

## What happens now

The customer keeps their type and pays the correct price. Captured from v2.7:

```text
  ID    NAME                       PHONE          EMAIL                        TYPE
  2002  Marlow Motors Ltd          01632 960118   buying@marlowmotors.example  Trade
  2009  No Email Ltd               01632 960123                                Trade
```

```text
  QUOTATION (valid 7 days)
  ----------------------------------------------
  Customer : No Email Ltd (Trade)
  Vehicle  : yf20 hbn Vauxhall Corsa 1.2 SE
  ----------------------------------------------
  List price                   10995.00
  Trade discount               -1099.50
  Net price                     9895.50
  Delivery                       150.00
  VAT 20%                       2009.10
  Registration fee                55.00
  ==============================================
  TOTAL                        12109.60
```

## Impact

Trade customers with a blank field were overcharged by their 10% discount, which was 1319.40 on this car, and staff were not told. A fleet customer with no email would have lost their 4% the same way.

## Records already damaged

The damage could become permanent. Once anyone saved a customer after the restart, the wrong values were written to `customers.dat`:

```text
2009|No Email Ltd|01632 960123|T|R
```

The fix cannot repair these rows, because the app cannot be sure what they used to say. They load exactly as stored, so those customers stay Retail until someone corrects them. This command finds them:

```text
grep -E '\|[TF]\|R$' data/customers.dat
```

[docs/fleet-discount.md](../fleet-discount.md) explains how to correct a row.

## Cause

`dbfile.c` split records with `strtok`, which skips empty fields, so the type moved into the wrong column and fell back to Retail. `add_customer` only requires a name.

## Fix

`load_customers` now uses `next_field`, which keeps empty fields. `load_stock` still uses `strtok`, so [BUG-001](BUG-001-blank-vehicle-details.md) remains open.

## Scenarios

- `Trade customer with no email stays Trade`
- `Trade customer with no phone stays Trade`
- `Fleet customer with no email stays Fleet`
- `Retail customer with no phone or email`
- `Blank details are kept by a later save`
- `Record damaged by the old bug`
