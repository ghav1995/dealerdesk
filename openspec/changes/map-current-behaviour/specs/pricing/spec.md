# Spec Delta

## ADDED Requirements

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
