# invoices Specification

## Purpose

Defines how a sale becomes an invoice, and guarantees that an issued invoice keeps
showing the amounts it was issued with.

## Requirements

### Requirement: Selling a vehicle
The system SHALL show an invoice preview and ask for confirmation. On confirmation
it SHALL save an invoice with the next invoice number and today's date, and mark
the vehicle as sold. If not confirmed, it SHALL change nothing.

#### Scenario: Confirmed sale
- **WHEN** staff answer Y to the confirmation
- **THEN** an invoice is saved and the vehicle status becomes sold

#### Scenario: Cancelled sale
- **WHEN** staff answer anything other than Y
- **THEN** no invoice is saved and the vehicle status does not change

### Requirement: Invoice amounts are stored
The system SHALL store the list price, combined discounts, net price, VAT, combined
fees, trade-in and total on the invoice when it is created.

#### Scenario: Combined discounts
- **WHEN** a sale has a trade discount and a salesman discount
- **THEN** the invoice stores the two added together as one discount amount

### Requirement: Issued invoices do not change
The system SHALL display an invoice from its stored amounts. Later changes to a
vehicle price or customer SHALL NOT change the amounts on an issued invoice.

#### Scenario: Greenway invoice from 2021
- **WHEN** staff view invoice 50232
- **THEN** it shows list 10495.00, discounts -839.60, net 9655.40, fees 205.00, VAT 1961.08 and total 11821.48

#### Scenario: Vehicle price changed after sale
- **WHEN** the price of a sold vehicle is changed and its invoice is viewed
- **THEN** the invoice shows the original amounts

### Requirement: Invoice display
The system SHALL show a trade-in line only when the invoice has a trade-in. It
SHALL show the discounts line on every invoice, including when it is 0.00.

#### Scenario: Invoice with a trade-in
- **WHEN** staff view invoice 50230
- **THEN** a trade-in line shows -1500.00 and the total is 9331.30
