# Spec Delta

## MODIFIED Requirements

### Requirement: Invoice amounts are stored
The system SHALL store the list price, combined discounts, net price, VAT, combined fees, trade-in and total on the invoice when it is created. Combined discounts SHALL include any fleet discount, and the fleet discount SHALL also be stored on its own.

#### Scenario: Combined discounts
- **WHEN** a sale has a trade discount and a salesman discount
- **THEN** the invoice stores the two added together as one discount amount

#### Scenario: Fleet sale amounts
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff sell vehicle 1002 to customer 2008 with no discount and no trade-in
- **THEN** the invoice stores list 10995.00, discount 439.80, net 10555.20, VAT 2141.04, fees 205.00, total 12901.24 and fleet discount 439.80

#### Scenario: Fleet sale with every deduction
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff sell vehicle 1007 to customer 2008 with 5% discount and a 1000.00 trade-in
- **THEN** the invoice stores discount 1122.00, net 11628.00, VAT 2355.60, trade-in 1000.00, total 13188.60 and fleet discount 510.00

### Requirement: Invoice display
The system SHALL show a trade-in line only when the invoice has a trade-in. It SHALL show the discounts line on every invoice with no fleet discount, including when it is 0.00. An invoice with a fleet discount SHALL show a "Fleet discount" line, and a discounts line only for any other discounts.

#### Scenario: Invoice with a trade-in
- **WHEN** staff view invoice 50230
- **THEN** a trade-in line shows -1500.00 and the total is 9331.30

#### Scenario: Fleet invoice with no other discount
- **GIVEN** vehicle 1002 sold to fleet customer 2008 with no other discount
- **WHEN** staff view invoice 50233
- **THEN** the screen shows a line labelled "Fleet discount" with -439.80 and the total 12901.24
- **AND** there is no discounts line

#### Scenario: Fleet invoice with another discount
- **GIVEN** vehicle 1007 sold to fleet customer 2008 with 5% discount
- **WHEN** staff view invoice 50233
- **THEN** the screen shows a fleet discount of -510.00 and discounts of -612.00

#### Scenario: Invoice preview for a fleet customer
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff reach the preview for selling vehicle 1002 to customer 2008
- **THEN** the preview shows a fleet discount of -439.80 and the total 12901.24

## ADDED Requirements

### Requirement: Fleet status does not change issued invoices
The system SHALL display an invoice from what was stored when it was issued, whatever the customer's fleet status is now.

#### Scenario: Earlier invoice after a customer becomes fleet
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff view invoice 50232, issued before they became fleet
- **THEN** it shows list 10495.00, discounts -839.60, net 9655.40 and total 11821.48
- **AND** there is no fleet discount line

#### Scenario: Fleet invoice after fleet status is removed
- **GIVEN** vehicle 1002 sold to fleet customer 2008, who is then returned to retail
- **WHEN** staff view invoice 50233
- **THEN** it still shows a fleet discount of -439.80 and the total 12901.24
