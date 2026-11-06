# Fleet discount diagrams

How the fleet discount works, from marking a customer to the stored invoice. The amounts come from the real runs in [use-cases.md](use-cases.md).

- [The journey at a glance](#the-journey-at-a-glance)
- [Customer types](#customer-types)
- [Marking a customer](#marking-a-customer)
- [Adding a customer](#adding-a-customer)
- [How a quote is priced](#how-a-quote-is-priced)
- [The path through the code](#the-path-through-the-code)
- [What is stored](#what-is-stored)
- [Rolling back](#rolling-back)
- [How the ticket was delivered](#how-the-ticket-was-delivered)

## The journey at a glance

```text
  1. MARK                 2. QUOTE                3. SELL                 4. INVOICE
  Who is fleet?           What do they pay?       Make it final           Keep it as issued

 +-----------------+    +-----------------+    +-----------------+    +-----------------+
 | Customer type   |    | 4% off the list |    | Same pricing    |    | Shows only what |
 | becomes F       |--->| price, on its   |--->| as the quote,   |--->| was stored, and |
 |                 |    | own line        |    | Y to confirm    |    | never re-prices |
 +-----------------+    +-----------------+    +-----------------+    +-----------------+
          |                      |                      |                      ^
          v                      v                      v                      |
   customers.dat            nothing saved          invoices.dat ---------------+
                                                   stock.dat (sold)
```

## Customer types

Every customer has one letter. Fleet is a third letter, not a new field, which is what keeps a rollback safe.

```text
  Customers > 4. Mark / unmark fleet customer

  +--------------+  "Customer 2008 is now a fleet customer."         +--------------+
  | R  Retail    | ------------------------------------------------> | F  Fleet     |
  | no discount  | <------------------------------------------------ | 4% off list  |
  +--------------+  "Customer 2008 is no longer a fleet customer."   +--------------+

  +--------------+
  | T  Trade     |  "Trade customers cannot be fleet customers."
  | 10% off list |  Nothing changes, so nobody drops from 10% to 4% by accident.
  +--------------+
```

## Marking a customer

One menu option does both jobs, like Reserve / release on the Stock menu. What it does depends on the customer's type.

```text
  Customers > 4  --->  Customer ID : ____
                               |
       +--------------+--------+--------+---------------+
       |              |                 |               |
   not found        type T            type F          type R
       |              |                 |               |
       v              v                 v               v
  "Customer not    "Trade customers   becomes R,      becomes F,
   found."          cannot be fleet   saved now       saved now
                    customers."
  Nothing saved    Nothing saved
```

## Adding a customer

The fleet question only appears after a "no" to the trade question, so a customer can never be both.

```text
  Customers > 2  --->  Name, Phone, Email
                               |
                               v
                     Trade customer (Y/N)?
                        |              |
                        Y              N or ENTER
                        |              |
                        v              v
                    type T     Fleet customer (Y/N)?
                                  |              |
                                  Y              N or ENTER
                                  |              |
                                  v              v
                              type F          type R
```

## How a quote is priced

The customer discount comes off first, then the salesman discount applies to what is left. The fleet discount does not use up the 15% limit, because saving that allowance is the point of the ticket.

```text
  Customer type          T  Trade       F  Fleet       R  Retail
  Customer discount      10% of list    4% of list     none
  Salesman discount      up to 15% of what is left, for all three
  Delivery and reg fee   never discounted
```

Vehicle 1007 for Greenway Taxis, with a 5% salesman discount and a 1000.00 trade-in:

```text
  List price                  12750.00
  Fleet discount                -510.00     4% of 12750.00
                             ----------
  After the fleet discount    12240.00
  Salesman discount             -612.00     5% of 12240.00
                             ----------
  Net price                   11628.00
  Delivery                      +150.00     not discounted
                             ----------
  Amount VAT applies to       11778.00
  VAT 20%                      +2355.60     20% of 11778.00
  Registration fee               +55.00     not discounted, no VAT
  Trade-in                     -1000.00
                             ==========
  TOTAL                       13188.60
```

The real screen for this quote is in [UC-05](use-cases.md#uc-05-quote-a-fleet-customer).

## The path through the code

```text
  main.c                            calc.c                     dbfile.c
  ------                            ------                     --------

  mark_fleet()  ........ sets the customer's type ...........> save_customers()
                                                               customers.dat

  build_quote()
    find_cust() gets the type
    calc_quote(q, price, type, discount, trade-in)
       ------------------------->   if the type is F:
                                      fleet_disc = rnd2(list * 0.04)
                                    disc = % of (list - trade - fleet)
       <-------- QUOTE ----------
  print_quote()
    shows "Fleet discount" when fleet_disc is above 0

  sell_vehicle()
    INVOICE.disc       = trade + fleet + salesman
    INVOICE.fleet_disc = fleet  ...............................> save_invoices()
                                                               invoices.dat, twelfth
                                                               field only when above 0

  view_invoice()
    shows the stored amounts, and uses the customer only for their name
```

## What is stored

`customers.dat` keeps its five fields. Only the last one has a new value.

```text
  2008|Greenway Taxis|01632 960702|fleet@greenwaytaxis.example|F
  id   name           phone        email                       type: R, T or F
```

`invoices.dat` keeps its eleven fields, and only an invoice with a fleet discount has a twelfth. The discount field still holds every discount added together, so an older version reads the right net price and total.

```text
  50234|2026-11-06|1007|2008|12750.00|1122.00|11628.00|2355.60|205.00|1000.00|13188.60|510.00
  no    date       veh  cust list     disc    net      VAT     fees   trade-in total   fleet
                                      |                                                |
                                      510.00 fleet + 612.00 salesman                   510.00 fleet
```

## Rolling back

A rollback puts the old binary back on the same data files. This is what v2.6 does with each thing v2.7 writes, confirmed by running real v2.6 in [UC-10](use-cases.md#uc-10-roll-back-to-v26-and-return).

```text
  v2.7 wrote                 v2.6 shows                 After returning to v2.7
  ------------------------   ------------------------   -----------------------------
  Customer type F            Retail, full price         Fleet, as long as it was kept
  Twelve-field invoice       One discounts line,        Fleet line, unless v2.6 saved
                             same total                 invoices (see below)
  Eleven-field invoice       Unchanged                  Unchanged

  If v2.6 saves ...          It costs ...
  ------------------------   ---------------------------------------------------------
  customers                  Nothing for a full record: the F survives.
                             A blank email is damaged for good, as it was before v2.7.
  invoices                   The twelfth field. The invoice loses its separate fleet
                             line, and every amount stays correct.
```

## How the ticket was delivered

```text
  TICKET-142
      |
      v
  /opsx:propose  --->  proposal, specs, design, tasks  --->  a person reviews them
      |
      v
  Each scenario becomes a test that has to fail first
      |
      v
  /opsx:apply    --->  code in small commits
      |
      v
  /opsx:archive  --->  specs merged, every scenario now mandatory
      |
      v
  Pull request into master  --->  CI: version is master plus 0.1, then make test
      |                                       |
      |                                       +---> fails: it cannot merge
      v
  merge-and-tag  --->  merge commit, then a version tag on master
      |
      v
  CD starts from the tag
      |
      v
  verify ---> tests ---> dev ---> test ---> qa ---> prd
                         each stage waits for an approval, and the deploy is simulated
```
