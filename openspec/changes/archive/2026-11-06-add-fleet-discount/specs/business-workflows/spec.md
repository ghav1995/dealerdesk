# Spec Delta

## ADDED Requirements

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
