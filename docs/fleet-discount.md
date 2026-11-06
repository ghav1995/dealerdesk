# Fleet discount

Fleet customers, such as taxi firms, rental companies and delivery services, get 4% off the vehicle price automatically. This page explains how to use it and the decisions behind it.

Every print below was captured by running the app, with blank lines removed.

## Using it

### Mark an existing customer

Choose **Customers**, then **4. Mark / unmark fleet customer**, and enter the customer id. The change is saved straight away.

```text
  1. List customers
  2. Add customer
  3. Find customer
  4. Mark / unmark fleet customer
  0. Back
```

```text
  DEALERDESK v2.7                               Fleet Customer
==============================================================
  Customer ID : 
  Customer 2008 is now a fleet customer.
  Press ENTER to continue...
```

The customer list then shows their type:

```text
  ID    NAME                       PHONE          EMAIL                        TYPE
  2001  Sarah Whitfield            07700 900412   s.whitfield@example.com      Retail
  2002  Marlow Motors Ltd          01632 960118   buying@marlowmotors.example  Trade
  2008  Greenway Taxis             01632 960702   fleet@greenwaytaxis.example  Fleet
```

If a customer was marked by mistake, choose the same option again to return them to Retail.

### Add a new fleet customer

**Add customer** asks about fleet after the trade question, but only if the answer was no. Answer N to the trade question and Y to the fleet question.

```text
Trade customer (Y/N)?   Fleet customer (Y/N)? 
Customer 2009 added.
2009|Fleet Co|01632 960125|buying@fleetco.example|F
```

Pressing ENTER at the fleet question means no.

## What the customer pays

- The discount is 4% of the list price, rounded to the penny.
- It is not taken off delivery or the registration fee.
- A salesman discount applies to what is left, and is still limited to 15%. The fleet discount does not use up that allowance.
- **Do not type a fleet discount by hand.** The customer would receive both.

For a vehicle listed at 12750.00, with a 5% salesman discount and a 1000.00 trade-in:

```text
  QUOTATION (valid 7 days)
  ----------------------------------------------
  Customer : Greenway Taxis (Fleet)
  Vehicle  : GJ19 VLA Skoda Octavia Estate 2.0 TDI SE
  ----------------------------------------------
  List price                   12750.00
  Fleet discount                -510.00
  Discount ( 5.0%)              -612.00
  Net price                    11628.00
  Delivery                       150.00
  VAT 20%                       2355.60
  Registration fee                55.00
  Trade-in                     -1000.00
  ==============================================
  TOTAL                        13188.60
```

The fleet discount is 4% of 12750.00. The salesman discount is 5% of the 12240.00 left. VAT is 20% of the net price plus delivery.

## Invoices

An invoice shows the fleet discount on its own line. The amount is stored with the invoice, so it does not depend on what the customer's status is later.

```text
  INVOICE 50233    Date: 2026-11-06
  ----------------------------------------------
  Customer : Greenway Taxis
  Vehicle  : yf20 hbn Vauxhall Corsa 1.2 SE
  ----------------------------------------------
  List price                   10995.00
  Fleet discount                -439.80
  Net price                    10555.20
  Fees                           205.00
  VAT                           2141.04
  ==============================================
  TOTAL                        12901.24
```

Invoices issued earlier do not change. This is Greenway's invoice from 2021, with its 8% hand discount, viewed after Greenway became a fleet customer:

```text
  INVOICE 50232    Date: 2021-03-29
  ----------------------------------------------
  Customer : Greenway Taxis
  Vehicle  : LK19 XRT Ford Fiesta 1.0 EcoBoost Zetec
  ----------------------------------------------
  List price                   10495.00
  Discounts                     -839.60
  Net price                     9655.40
  Fees                           205.00
  VAT                           1961.08
  ==============================================
  TOTAL                        11821.48
```

In `invoices.dat`, a fleet invoice has a twelfth field holding the fleet discount. Every other invoice keeps its eleven fields.

```text
50233|2026-11-06|1002|2008|10995.00|439.80|10555.20|2141.04|205.00|0.00|12901.24|439.80
```

## Decision: Trade customers cannot be fleet customers

The ticket does not say what happens if a Trade customer is marked as fleet. The product owner decided to refuse it.

A customer has one type, so allowing it would replace their 10% trade discount with 4% on a single wrong keystroke. The screen says why, and nothing changes:

```text
  DEALERDESK v2.7                               Fleet Customer
==============================================================
  Customer ID : 
  Trade customers cannot be fleet customers.
  Press ENTER to continue...
```

The record is the same before and after, and no data file changes:

```text
2002|Marlow Motors Ltd|01632 960118|buying@marlowmotors.example|T
```

There is no edit-customer screen, so a customer who really moves from Trade to Fleet needs a new record.

## Decision: Blank phone or email is fixed for every customer

This was known bug [BUG-002](known-bugs/BUG-002-blank-customer-details.md). A customer saved with a blank phone or email lost their type after a restart, so a fleet customer with no email would have silently lost their 4%. The product owner decided to fix it for all customers.

Here is a trade customer added with no email, then quoted after a restart.

**Before, on v2.6.** The email column shows `T`, the customer shows as Retail, and there is no trade discount:

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

**After, on this version.** The customer keeps Trade and pays the correct price:

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

The customer was being overcharged by 1319.40 on this car.

This is the one place a non-fleet total changes. The ticket says non-fleet totals stay "unchanged, to the penny", and the fix goes against that wording for these customers, because their old total was wrong.

### Records the bug already damaged

The bug did more than misread a record. The customer above was saved correctly:

```text
2009|No Email Ltd|01632 960123||T
```

On v2.6, once anyone saved a customer after the restart, the wrong values were written to the file:

```text
2009|No Email Ltd|01632 960123|T|R
```

On this version, the same record stays as it was saved. A row that is already damaged is read exactly as it is stored, because the app cannot be sure what it used to say, so the customer stays Retail:

```text
  ID    NAME                       PHONE          EMAIL                        TYPE
  2100  Old Trade Ltd              01632 960123   T                            Retail
```

Run this from the folder holding `data/` to find these rows:

```text
grep -E '\|[TF]\|R$' data/customers.dat
```

```text
2100|Old Trade Ltd|01632 960123|T|R
```

To correct a row, check the customer's real details, close the app, and edit the row. For the example above, a trade customer with no email becomes:

```text
2100|Old Trade Ltd|01632 960123||T
```

## After release

1. Mark Greenway Taxis (2008) as a fleet customer. Their earlier invoice does not change.
2. Tell sales staff to stop giving fleet customers a hand discount, or they will receive both.
3. Run the `grep` command above, and correct any damaged records.
