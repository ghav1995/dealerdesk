# Spec Delta

## ADDED Requirements

### Requirement: Listing customers
The system SHALL list every customer with their id, name, phone, email and type, followed by how many there are.

#### Scenario: Full customer list
- **GIVEN** the sample showroom data
- **WHEN** staff list customers
- **THEN** the screen shows 2002, Marlow Motors Ltd, 01632 960118, buying@marlowmotors.example and Trade
- **AND** the screen shows "8 customer(s)"

#### Scenario: Long values are cut in the list
- **GIVEN** a customer whose name is longer than 26 characters
- **WHEN** staff list customers
- **THEN** the list shows the first 26 characters of the name
- **AND** the saved name is unchanged

### Requirement: Finding customers by name
The system SHALL list the customers whose name contains the search text, followed by how many matched. Blank text SHALL match every customer.

#### Scenario: Search with no match
- **GIVEN** the sample showroom data
- **WHEN** staff search for zzz
- **THEN** the screen shows "0 match(es)"

#### Scenario: Search with blank text
- **GIVEN** the sample showroom data
- **WHEN** staff search with blank text
- **THEN** the screen shows "8 match(es)"

#### Scenario: Search is case sensitive
- **GIVEN** the sample showroom data
- **WHEN** staff search for taxis
- **THEN** the screen shows "0 match(es)"

#### Scenario: Search finds text inside a name
- **GIVEN** the sample showroom data
- **WHEN** staff search for Car
- **THEN** the screen shows A1 Car Sales and "1 match(es)"

### Requirement: Adding customers
The system SHALL save a new customer with the next customer id, including when the phone and email are blank.

#### Scenario: Retail customer added
- **GIVEN** the sample showroom data
- **WHEN** staff add a customer and answer N to the trade question
- **THEN** the system shows "Customer 2009 added."
- **AND** the customer is saved as type R

#### Scenario: Customer ids carry on after a refused customer
- **GIVEN** the sample showroom data
- **WHEN** staff try to add a customer with no name and then add one with a name
- **THEN** the system shows "Customer 2009 added."

#### Scenario: New customer can be quoted
- **GIVEN** the sample showroom data
- **WHEN** staff add a trade customer and quote vehicle 1002 for them straight away
- **THEN** the quote shows a trade discount of -1099.50

### Requirement: Customer list capacity
The system SHALL hold at most 500 customers, and SHALL refuse a new one before asking for any details.

#### Scenario: Customer file full
- **GIVEN** a customer file holding 500 customers
- **WHEN** staff choose Add customer
- **THEN** the system shows "Customer file is full!"
- **AND** does not ask for a name

### Requirement: Blank customer details after a restart
The system SHALL lose a customer's trade type after a restart if their phone or email is blank, because the columns shift when the file is read. This is known bug BUG-002.

#### Scenario: Known bug: BUG-002 trade customer with no email becomes Retail
- **GIVEN** a trade customer added with no email
- **WHEN** the app is restarted and staff quote vehicle 1002 for them
- **THEN** the customer shows as Retail
- **AND** the quote has no trade discount and the total is 13429.00

#### Scenario: Known bug: BUG-002 trade customer with no phone becomes Retail
- **GIVEN** a trade customer added with no phone
- **WHEN** the app is restarted and staff list customers
- **THEN** the email appears in the phone column and the customer shows as Retail
