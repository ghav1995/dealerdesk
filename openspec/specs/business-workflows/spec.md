# business-workflows Specification

## Purpose
Defines the end-to-end journeys staff follow across several operations, including every path a vehicle can take from arrival to sale.

## Requirements

### Requirement: Vehicle lifecycle
The system SHALL move a vehicle from in stock to sold, directly or through reserved, and SHALL treat sold as final for reserving, quoting and selling.

#### Scenario: Add a vehicle and sell it
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle at 6500.00 and sell it to customer 2001
- **THEN** invoice 50233 shows list price 6500.00
- **AND** the vehicle is left out of the stock list and shown as SOLD in the list of all vehicles

#### Scenario: Reserve a vehicle and sell it
- **GIVEN** the sample showroom data
- **WHEN** staff reserve vehicle 1002 and sell it to customer 2001
- **THEN** invoice 50233 is created and the vehicle is shown as SOLD

#### Scenario: Reserve, release and sell a vehicle
- **GIVEN** the sample showroom data
- **WHEN** staff reserve vehicle 1002, release it and sell it to customer 2001
- **THEN** invoice 50233 is created and the vehicle is shown as SOLD

#### Scenario: Nothing further can happen to a sold vehicle
- **GIVEN** vehicle 1002 sold
- **WHEN** staff try to reserve it, quote it and sell it
- **THEN** each attempt shows "Vehicle is already sold."

### Requirement: New customer journey
The system SHALL let a customer added today be quoted and sold to straight away.

#### Scenario: Add a customer and sell to them
- **GIVEN** the sample showroom data
- **WHEN** staff add retail customer 2009 and sell vehicle 1002 to them
- **THEN** the invoice list shows that customer's name on invoice 50233

### Requirement: Fleet customer journey
The system SHALL carry a customer's fleet status from adding or marking them through to the quote, the sale and the issued invoice, across restarts.

#### Scenario: New fleet customer buys a vehicle
- **GIVEN** a fleet customer added as customer 2009
- **WHEN** staff sell vehicle 1002 to customer 2009, the app is restarted and staff view invoice 50233
- **THEN** the invoice shows a fleet discount of -439.80 and the total 12901.24

#### Scenario: Greenway becomes a fleet customer
- **GIVEN** the sample showroom data
- **WHEN** staff mark customer 2008 as a fleet customer and sell vehicle 1007 to them
- **THEN** the invoice shows a fleet discount of -510.00 and the total 14923.00
- **AND** invoice 50232 still shows discounts of -839.60

#### Scenario: Fleet status removed before a sale
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer and then returned to retail
- **WHEN** staff quote vehicle 1002 for customer 2008
- **THEN** the quote has no fleet discount line and the total is 13429.00

#### Scenario: Fleet customer with no email buys after a restart
- **GIVEN** a fleet customer added as customer 2009 with no email
- **WHEN** the app is restarted and staff sell vehicle 1002 to customer 2009
- **THEN** the invoice is saved with fleet discount 439.80 and total 12901.24

### Requirement: Quote before sale
The system SHALL price a sale from the vehicle's price at the moment of the sale, not from an earlier quote.

#### Scenario: Price changes between quote and sale
- **GIVEN** vehicle 1002 quoted at the list price 10995.00
- **WHEN** staff change its price to 11250.50 and sell it to customer 2001
- **THEN** the invoice stores the list price 11250.50

#### Scenario: Cancelled sale leaves the vehicle available
- **GIVEN** a sale of vehicle 1002 that staff cancelled
- **WHEN** staff sell vehicle 1002 to customer 2002
- **THEN** the system shows "Invoice 50233 created."

### Requirement: Issued invoice stays fixed through later changes
The system SHALL keep showing an invoice's original amounts after everything around it has changed.

#### Scenario: Invoice unchanged by a price change and a restart
- **GIVEN** a sale recorded as invoice 50233 with the total 13429.00
- **WHEN** staff change the price of that vehicle and the app is restarted
- **THEN** invoice 50233 still shows the total 13429.00
