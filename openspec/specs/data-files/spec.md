# data-files Specification

## Purpose

Defines the flat files DealerDesk reads and writes. Live dealership data is held
in these formats, so any change has to stay compatible with existing files.

## Requirements

### Requirement: Data location
The system SHALL read and write its files in `data/`, relative to the directory it
is started from.

#### Scenario: Started from the application folder
- **WHEN** the app starts in a folder containing `data/`
- **THEN** it uses the files in that folder

### Requirement: Record formats
The system SHALL store one record per line, with fields separated by `|`, in the
order listed here. Money SHALL be written with two decimal places.

- `stock.dat`: id, plate, make, model, year, mileage, cost, price, status
- `customers.dat`: id, name, phone, email, type
- `invoices.dat`: no, date, vehicle id, customer id, list, discount, net, VAT, fees, trade-in, total
- `next_ids.dat`: `vehicle=`, `customer=` and `invoice=` lines

#### Scenario: Pipe typed into a field
- **WHEN** staff type a `|` at any prompt
- **THEN** it is replaced with `/`, so it cannot create an extra field

### Requirement: Tolerant loading
The system SHALL accept LF and CRLF line endings, and SHALL skip blank lines and
lines starting with `#`. A missing number SHALL load as 0, and a missing customer
type SHALL load as R.

#### Scenario: Windows line endings
- **WHEN** a data file has CRLF line endings
- **THEN** it loads the same as a file with LF line endings

### Requirement: Immediate saving
The system SHALL save each change as soon as it is made, by rewriting the whole
affected file.

#### Scenario: Vehicle added
- **WHEN** staff add a vehicle
- **THEN** `stock.dat` and `next_ids.dat` are rewritten before the next prompt
