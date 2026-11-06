# pricing Specification

## Purpose

Defines how DealerDesk calculates a quote. An invoice is a saved quote, so these
rules set what customers are charged. Amounts come from issued invoices.

## Requirements

### Requirement: Trade discount
The system SHALL give customers of type T a trade discount of 10% of the list
price, rounded to the penny. Other customers SHALL get no trade discount.

#### Scenario: Trade customer
- **WHEN** a trade customer is quoted a vehicle listed at 13495.00 with no other discount
- **THEN** the trade discount is 1349.50 and the net price is 12145.50

#### Scenario: Retail customer
- **WHEN** a retail customer is quoted a vehicle listed at 13495.00 with no other discount
- **THEN** the trade discount is 0.00 and the net price is 13495.00

### Requirement: Salesman discount
The system SHALL apply the salesman discount percentage to the list price less
any trade discount, rounded to the penny. It SHALL reduce a percentage above 15
to 15 and a negative percentage to 0, without warning and without a manager PIN.

#### Scenario: Discount after trade discount
- **WHEN** a trade customer gets 10% on a vehicle listed at 10000.00
- **THEN** the trade discount is 1000.00 and the salesman discount is 900.00

#### Scenario: Discount above the limit
- **WHEN** 20% is entered on a vehicle listed at 10000.00
- **THEN** the discount shown is 15.0% and the amount is 1500.00

### Requirement: Fees
The system SHALL add a delivery charge of 150.00 and a registration fee of 55.00
to every quote. Discounts SHALL NOT apply to either fee.

#### Scenario: Fees on a discounted quote
- **WHEN** a quote has any discount
- **THEN** delivery is still 150.00 and the registration fee is still 55.00

### Requirement: VAT
The system SHALL charge VAT at 20% of the net price plus delivery, rounded to the
penny. The registration fee SHALL NOT carry VAT.

#### Scenario: VAT on net price plus delivery
- **WHEN** the net price is 8830.25
- **THEN** VAT is 1796.05, which is 20% of 8980.25

### Requirement: Total
The system SHALL calculate the total as net price plus delivery plus VAT plus
registration fee, less the trade-in value. A trade-in SHALL NOT reduce VAT.

#### Scenario: Retail sale with discount and trade-in
- **WHEN** a retail customer gets 5% on a vehicle listed at 9295.00 with a 1500.00 trade-in
- **THEN** the discount is 464.75, net is 8830.25, VAT is 1796.05 and the total is 9331.30

#### Scenario: Trade sale
- **WHEN** a trade customer buys a vehicle listed at 13495.00 with no other discount
- **THEN** VAT is 2459.10 and the total is 14809.60

### Requirement: Rounding
The system SHALL round discounts and VAT to the nearest penny, with half a penny
rounding up.

#### Scenario: Half a penny
- **WHEN** an amount of 10.125 is rounded
- **THEN** the result is 10.13

### Requirement: Worked retail totals
The system SHALL price retail quotes to the penny using the existing rules, with real vehicles from stock.

#### Scenario: Retail quote with no discount
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002, listed at 10995.00, for customer 2001 with no discount and no trade-in
- **THEN** net is 10995.00, VAT is 2229.00 and the total is 13429.00

#### Scenario: Retail quote with a discount and a trade-in
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002 for customer 2001 with 5% discount and a 1000.00 trade-in
- **THEN** the discount is -549.75, net is 10445.25, VAT is 2119.05 and the total is 11769.30

#### Scenario: Hand discount for a retail customer
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1007, listed at 12750.00, for customer 2008 with 8% discount
- **THEN** the discount is -1020.00, net is 11730.00, VAT is 2376.00 and the total is 14311.00

### Requirement: Worked trade totals
The system SHALL price trade quotes to the penny using the existing rules, with real vehicles from stock.

#### Scenario: Trade quote with no other discount
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1003, listed at 15995.00, for customer 2002 with no discount
- **THEN** the trade discount is -1599.50, net is 14395.50, VAT is 2909.10 and the total is 17509.60

#### Scenario: Trade quote with a discount and a trade-in
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1004, listed at 16750.00, for customer 2002 with 10% discount and a 500.00 trade-in
- **THEN** net is 13567.50, VAT is 2743.50 and the total is 16016.00

### Requirement: Salesman discount limits on real vehicles
The system SHALL apply the 15% limit and the floor of 0% to quotes for real vehicles.

#### Scenario: Discount above the limit on a real vehicle
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1005, listed at 15450.00, for customer 2001 with 20% discount
- **THEN** the quote shows discount (15.0%) -2317.50 and the total is 15994.00

#### Scenario: Negative discount on a real vehicle
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1005 for customer 2001 with -5% discount
- **THEN** the quote has no discount line and the total is 18775.00

### Requirement: Trade-in above the amount due
The system SHALL accept a trade-in larger than the amount due and show a negative total. This is known bug BUG-004.

#### Scenario: Known bug: BUG-004 trade-in larger than the total
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002 for customer 2001 with a 99999.00 trade-in
- **THEN** the total is -86570.00

### Requirement: Negative trade-in
The system SHALL accept a negative trade-in and add it to the total. This is known bug BUG-005.

#### Scenario: Known bug: BUG-005 negative trade-in increases the total
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002 for customer 2001 with a -500.00 trade-in
- **THEN** the quote shows a trade-in of 500.00 and the total is 13929.00
