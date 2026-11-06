# customers Specification

## Purpose

Defines how DealerDesk records customers, and how a customer's type affects what
staff see and what the customer pays.

## Requirements

### Requirement: Customer types
The system SHALL record each customer as trade (T), retail (R) or fleet (F). It SHALL show T as Trade, F as Fleet, and any other value as Retail.

#### Scenario: Customer list
- **WHEN** staff list customers
- **THEN** Marlow Motors Ltd shows as Trade and Sarah Whitfield shows as Retail

#### Scenario: Fleet customer in the list
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff list customers
- **THEN** Greenway Taxis shows as Fleet

### Requirement: Adding a customer
The system SHALL ask for a name, phone, email and whether the customer is trade, and SHALL ask whether they are fleet only if they are not trade. It SHALL require a name, and SHALL NOT use up a customer id if the name is missing.

#### Scenario: Trade customer added
- **WHEN** staff enter a name and answer Y to the trade question
- **THEN** the customer is saved as type T with the next customer id

#### Scenario: Name missing
- **WHEN** staff leave the name blank
- **THEN** the system shows that a name is required and nothing is saved

#### Scenario: Fleet customer added
- **GIVEN** the sample showroom data
- **WHEN** staff add a customer, answer N to the trade question and Y to the fleet question
- **THEN** the customer is saved as type F with the next customer id

#### Scenario: Trade customer is not asked the fleet question
- **GIVEN** the sample showroom data
- **WHEN** staff add a customer and answer Y to the trade question
- **THEN** the system does not show "Fleet customer (Y/N)?"

#### Scenario: Blank answer to the fleet question
- **GIVEN** the sample showroom data
- **WHEN** staff answer N to the trade question and press ENTER at the fleet question
- **THEN** the customer is saved as type R

### Requirement: Finding a customer
The system SHALL find customers whose name contains the search text, matching
upper and lower case exactly.

#### Scenario: Search by part of a name
- **WHEN** staff search for Taxis
- **THEN** Greenway Taxis is listed

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
- **WHEN** staff add a customer and answer N to the trade and fleet questions
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

### Requirement: Marking a fleet customer
The system SHALL let staff mark a retail customer as fleet and return a fleet customer to retail from the Customers menu, saving the change straight away.

#### Scenario: Retail customer marked as fleet
- **GIVEN** the sample showroom data
- **WHEN** staff mark customer 2008 as a fleet customer
- **THEN** the system shows "Customer 2008 is now a fleet customer."
- **AND** the customer is saved as type F

#### Scenario: Fleet customer returned to retail
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff choose to mark customer 2008 again
- **THEN** the system shows "Customer 2008 is no longer a fleet customer."
- **AND** the customer is saved as type R

#### Scenario: Marking an unknown customer
- **GIVEN** the sample showroom data
- **WHEN** staff mark customer 9999 as a fleet customer
- **THEN** the system shows "Customer not found."
- **AND** the data files are unchanged

#### Scenario: Fleet status after a restart
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** the app is restarted and staff list customers
- **THEN** Greenway Taxis shows as Fleet

### Requirement: Trade customers cannot be fleet
The system SHALL refuse to mark a trade customer as fleet, so no customer loses their trade discount by accident or holds both discounts.

#### Scenario: Trade customer refused
- **GIVEN** the sample showroom data
- **WHEN** staff mark customer 2002, a trade customer, as a fleet customer
- **THEN** the system shows "Trade customers cannot be fleet customers."
- **AND** the data files are unchanged

### Requirement: Customer list capacity
The system SHALL hold at most 500 customers, and SHALL refuse a new one before asking for any details.

#### Scenario: Customer file full
- **GIVEN** a customer file holding 500 customers
- **WHEN** staff choose Add customer
- **THEN** the system shows "Customer file is full!"
- **AND** does not ask for a name

### Requirement: Blank customer details survive a restart
The system SHALL keep each customer's fields in their own columns when a phone or email is blank, so the customer keeps their type after a restart.

#### Scenario: Trade customer with no email stays Trade
- **GIVEN** a trade customer added with no email
- **WHEN** the app is restarted and staff quote vehicle 1002 for them
- **THEN** the customer shows as Trade
- **AND** the trade discount is -1099.50 and the total is 12109.60

#### Scenario: Trade customer with no phone stays Trade
- **GIVEN** a trade customer added with no phone
- **WHEN** the app is restarted and staff list customers
- **THEN** the phone column is blank, the email is in the email column, and the customer shows as Trade

#### Scenario: Fleet customer with no email stays Fleet
- **GIVEN** a fleet customer added with no email
- **WHEN** the app is restarted and staff quote vehicle 1002 for them
- **THEN** the customer shows as Fleet
- **AND** the fleet discount is -439.80 and the total is 12901.24

#### Scenario: Retail customer with no phone or email
- **GIVEN** a retail customer added with no phone or email
- **WHEN** the app is restarted and staff list customers
- **THEN** the customer shows as Retail with a blank phone and email

#### Scenario: Blank details are kept by a later save
- **GIVEN** a trade customer added with no email
- **WHEN** the app is restarted and staff add another customer
- **THEN** the first customer's record still has a blank email and the type T

### Requirement: Records already damaged
The system SHALL read a customer record exactly as stored. Records that BUG-002 has already rewritten are not repaired.

#### Scenario: Record damaged by the old bug
- **GIVEN** a customer record "2100|Old Trade Ltd|01632 960123|T|R"
- **WHEN** staff list customers
- **THEN** the email shows as T and the customer shows as Retail
