# Spec Delta

## MODIFIED Requirements

### Requirement: Salesman discount
The system SHALL apply the salesman discount percentage to the list price less any trade or fleet discount, rounded to the penny. It SHALL reduce a percentage above 15 to 15 and a negative percentage to 0, without warning and without a manager PIN.

#### Scenario: Discount after trade discount
- **WHEN** a trade customer gets 10% on a vehicle listed at 10000.00
- **THEN** the trade discount is 1000.00 and the salesman discount is 900.00

#### Scenario: Discount above the limit
- **WHEN** 20% is entered on a vehicle listed at 10000.00
- **THEN** the discount shown is 15.0% and the amount is 1500.00

#### Scenario: Discount after fleet discount
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff quote vehicle 1007, listed at 12750.00, for customer 2008 with 5% discount
- **THEN** the fleet discount is -510.00 and the salesman discount is -612.00, which is 5% of 12240.00

#### Scenario: Fleet discount does not use up the salesman limit
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff quote vehicle 1007 for customer 2008 with 20% discount
- **THEN** the fleet discount is -510.00, the discount shown is 15.0% at -1836.00, and the total is 12719.80

## ADDED Requirements

### Requirement: Fleet discount
The system SHALL give fleet customers a discount of 4% of the list price, rounded to the penny. It SHALL apply automatically, and SHALL NOT apply to delivery or the registration fee.

#### Scenario: Fleet customer with no other discount
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff quote vehicle 1002, listed at 10995.00, for customer 2008 with no discount and no trade-in
- **THEN** the fleet discount is -439.80, net is 10555.20, VAT is 2141.04 and the total is 12901.24

#### Scenario: Fleet customer on another vehicle
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff quote vehicle 1007, listed at 12750.00, for customer 2008 with no discount and no trade-in
- **THEN** the fleet discount is -510.00, net is 12240.00, VAT is 2478.00 and the total is 14923.00

#### Scenario: Fleet customer with a discount and a trade-in
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff quote vehicle 1007 for customer 2008 with 5% discount and a 1000.00 trade-in
- **THEN** net is 11628.00, VAT is 2355.60 and the total is 13188.60

#### Scenario: Fees are not discounted for a fleet customer
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff quote vehicle 1002 for customer 2008
- **THEN** delivery is still 150.00 and the registration fee is still 55.00

#### Scenario: Fleet discount rounds to the penny
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer and a vehicle listed at 1234.56
- **WHEN** staff quote that vehicle for customer 2008
- **THEN** the fleet discount is -49.38, net is 1185.18, VAT is 267.04 and the total is 1657.22

#### Scenario: Retail customer gets no fleet discount
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002 for customer 2001
- **THEN** the quote has no fleet discount line and the total is 13429.00

#### Scenario: Trade customer gets no fleet discount
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1003 for customer 2002
- **THEN** the quote has no fleet discount line and the total is 17509.60
