# Spec Delta

## MODIFIED Requirements

### Requirement: Record formats
The system SHALL store one record per line, with fields separated by `|`, in the
order listed here. Money SHALL be written with two decimal places.

- `stock.dat`: id, plate, make, model, year, mileage, cost, price, status
- `customers.dat`: id, name, phone, email, type, where type is R, T or F
- `invoices.dat`: no, date, vehicle id, customer id, list, discount, net, VAT, fees, trade-in, total, fleet discount if any
- `next_ids.dat`: `vehicle=`, `customer=` and `invoice=` lines

#### Scenario: Pipe typed into a field
- **WHEN** staff type a `|` at any prompt
- **THEN** it is replaced with `/`, so it cannot create an extra field

#### Scenario: Invoice with a fleet discount has twelve fields
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff sell vehicle 1002 to customer 2008
- **THEN** the invoice record has twelve fields, and the twelfth is 439.80

#### Scenario: Invoice with no fleet discount keeps eleven fields
- **GIVEN** the sample showroom data
- **WHEN** staff sell vehicle 1002 to customer 2001
- **THEN** the invoice record has eleven fields

## ADDED Requirements

### Requirement: Existing data files need no conversion
The system SHALL load data files written by earlier versions as they are. An invoice with eleven fields SHALL load as having no fleet discount.

#### Scenario: Invoice from an earlier version
- **GIVEN** the sample showroom data
- **WHEN** staff view invoice 50231
- **THEN** the invoice has no fleet discount line and the total is 14809.60

#### Scenario: Earlier invoices are unchanged by a fleet sale
- **GIVEN** the sample showroom data
- **WHEN** staff mark customer 2008 as a fleet customer and sell vehicle 1002 to them
- **THEN** the records for invoices 50230, 50231 and 50232 are unchanged in `invoices.dat`

#### Scenario: Marking a customer changes only that record
- **GIVEN** the sample showroom data
- **WHEN** staff mark customer 2008 as a fleet customer
- **THEN** every other record in `customers.dat` is unchanged
