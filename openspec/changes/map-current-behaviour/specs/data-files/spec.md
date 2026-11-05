# Spec Delta

## ADDED Requirements

### Requirement: Changes survive a restart
The system SHALL keep every saved change after the app is closed and started again.

#### Scenario: Added vehicle after a restart
- **GIVEN** a vehicle added with the plate AB12 CDE
- **WHEN** the app is restarted and staff search for AB12 CDE
- **THEN** the vehicle is found

#### Scenario: Added customer after a restart
- **GIVEN** a customer added with a name, phone and email
- **WHEN** the app is restarted and staff search for that name
- **THEN** the customer is found

#### Scenario: Changed price after a restart
- **GIVEN** the price of vehicle 1002 changed to 11250.50
- **WHEN** the app is restarted and staff search for the plate yf20 hbn
- **THEN** the price is 11250.50

#### Scenario: Reservation after a restart
- **GIVEN** vehicle 1002 reserved
- **WHEN** the app is restarted and staff search for the plate yf20 hbn
- **THEN** the status is RESERVED

#### Scenario: Sale after a restart
- **GIVEN** vehicle 1002 sold
- **WHEN** the app is restarted and staff quote vehicle 1002
- **THEN** the system shows "Vehicle is already sold."

### Requirement: Id counters
The system SHALL carry vehicle, customer and invoice numbers on across restarts, and SHALL NOT reuse a number.

#### Scenario: Vehicle ids after a restart
- **GIVEN** vehicle 1013 added
- **WHEN** the app is restarted and staff add another vehicle
- **THEN** the system shows "Vehicle 1014 added."

#### Scenario: Customer ids after a restart
- **GIVEN** customer 2009 added
- **WHEN** the app is restarted and staff add another customer
- **THEN** the system shows "Customer 2010 added."

#### Scenario: Invoice numbers after a restart
- **GIVEN** invoice 50233 created
- **WHEN** the app is restarted and staff confirm another sale
- **THEN** the system shows "Invoice 50234 created."

### Requirement: Missing data files
The system SHALL start with an empty list when a data file is missing, and SHALL create the file on the next save.

#### Scenario: Stock file missing
- **GIVEN** the sample showroom data without `stock.dat`
- **WHEN** staff list stock
- **THEN** the screen shows "0 vehicle(s)"

#### Scenario: Customer file missing
- **GIVEN** the sample showroom data without `customers.dat`
- **WHEN** staff list customers
- **THEN** the screen shows "0 customer(s)"

#### Scenario: Invoice file missing
- **GIVEN** the sample showroom data without `invoices.dat`
- **WHEN** staff list invoices
- **THEN** the screen shows "0 invoice(s)"

#### Scenario: Missing file is created on save
- **GIVEN** the sample showroom data without `customers.dat`
- **WHEN** staff add a customer
- **THEN** `customers.dat` exists and holds that customer

### Requirement: Short and unusual records
The system SHALL load a record that has fields missing, leaving text blank and numbers at 0. It SHALL show an unknown customer type as Retail and an unknown vehicle status as ?.

#### Scenario: Customer record with fields missing
- **GIVEN** a customer record holding only an id and a name
- **WHEN** staff list customers
- **THEN** the customer is listed as Retail with a blank phone and email

#### Scenario: Vehicle record with fields missing
- **GIVEN** a vehicle record holding only an id and a plate
- **WHEN** staff list all vehicles
- **THEN** the vehicle is listed with price 0.00 and status IN STOCK

#### Scenario: Unknown customer type
- **GIVEN** a customer record with the type X
- **WHEN** staff list customers
- **THEN** the customer is listed as Retail

#### Scenario: Unknown vehicle status
- **GIVEN** a vehicle record with the status 7
- **WHEN** staff list all vehicles
- **THEN** the status is shown as ?

### Requirement: Saving rewrites the file
The system SHALL write a saved file with LF line endings, whatever the file used before.

#### Scenario: Windows line endings removed by a save
- **GIVEN** a stock file with CRLF line endings
- **WHEN** staff change a price
- **THEN** `stock.dat` no longer has any CRLF line endings

#### Scenario: Blank lines and comments are skipped on load
- **GIVEN** a customer file containing a blank line and a line starting with `#`
- **WHEN** staff list customers
- **THEN** the screen shows "8 customer(s)"

### Requirement: Blank vehicle details after a restart
The system SHALL misread a vehicle after a restart if its make or model is blank, because the columns shift when the file is read. Its price becomes 0.00. This is known bug BUG-001.

#### Scenario: Known bug: BUG-001 blank make loses the price
- **GIVEN** a vehicle added with a blank make and the list price 2000.00
- **WHEN** the app is restarted and staff search for its plate
- **THEN** the price is 0.00 and the vehicle details have shifted

#### Scenario: Known bug: BUG-001 blank model loses the price
- **GIVEN** a vehicle added with a blank model and the list price 2000.00
- **WHEN** the app is restarted and staff search for its plate
- **THEN** the price is 0.00 and the vehicle details have shifted

#### Scenario: Known bug: BUG-001 vehicle sold at the lost price
- **GIVEN** a vehicle added with a blank make and the list price 2000.00
- **WHEN** the app is restarted and staff sell it to customer 2001
- **THEN** the invoice shows list price 0.00 and total 235.00

### Requirement: Missing id counters
The system SHALL fall back to its starting numbers when `next_ids.dat` is missing, and so reuse ids that already exist. This is known bug BUG-006.

#### Scenario: Known bug: BUG-006 duplicate vehicle id
- **GIVEN** the sample showroom data without `next_ids.dat`
- **WHEN** staff add two vehicles
- **THEN** the second is given id 1001, which already belongs to another vehicle

### Requirement: Started in the wrong folder
The system SHALL start empty with no warning when there is no `data/` folder, and SHALL report a change as done even when saving it failed. This is known bug BUG-007.

#### Scenario: Known bug: BUG-007 app starts empty
- **GIVEN** a folder with no `data/` folder
- **WHEN** staff list stock
- **THEN** the screen shows "0 vehicle(s)" with no warning

#### Scenario: Known bug: BUG-007 failed save reported as added
- **GIVEN** a folder with no `data/` folder
- **WHEN** staff add a vehicle
- **THEN** the system shows "ERROR: cannot write next_ids.dat" and then "Vehicle 1000 added."

### Requirement: Files over the limit
The system SHALL load only the first 500 vehicles, and the next save SHALL drop the rest from the file. This is known bug BUG-008.

#### Scenario: Known bug: BUG-008 save drops vehicles over the limit
- **GIVEN** a stock file holding 510 vehicles
- **WHEN** staff change the price of one vehicle
- **THEN** `stock.dat` holds 500 vehicles

### Requirement: Comments in data files
The system SHALL drop comment lines from a data file when it saves that file. This is known bug BUG-013.

#### Scenario: Known bug: BUG-013 comment lost on save
- **GIVEN** a stock file containing a line starting with `#`
- **WHEN** staff change a price
- **THEN** `stock.dat` no longer contains that line
