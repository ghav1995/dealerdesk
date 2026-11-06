# quotes Specification

## Purpose
Defines the quote flow: which vehicles and customers can be quoted, what the quote shows, and the promise that producing a quote changes nothing.

## Requirements

### Requirement: Finding the vehicle and customer
The system SHALL ask for a vehicle, then a customer, then a discount and a trade-in, and SHALL stop as soon as a vehicle or customer cannot be used.

#### Scenario: Unknown vehicle
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 9999
- **THEN** the system shows "Vehicle not found."
- **AND** does not ask for a customer

#### Scenario: Sold vehicle stops the quote
- **GIVEN** the sample showroom data
- **WHEN** staff quote sold vehicle 1001
- **THEN** the system shows "Vehicle is already sold."
- **AND** does not ask for a customer

#### Scenario: Unknown customer
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002 for customer 9999
- **THEN** the system shows "Customer not found."
- **AND** does not ask for a discount

### Requirement: Quote contents
The system SHALL show the title "QUOTATION (valid 7 days)", the customer and their type, the vehicle, and every amount from list price to total.

#### Scenario: Retail quote heading
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002 for customer 2001
- **THEN** the quote is titled "QUOTATION (valid 7 days)"
- **AND** shows the customer as Sarah Whitfield (Retail) and the vehicle as yf20 hbn Vauxhall Corsa 1.2 SE

#### Scenario: Trade quote heading
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1004 for customer 2002
- **THEN** the quote shows the customer as Marlow Motors Ltd (Trade)

#### Scenario: Quote lines
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002 for customer 2001 with no discount and no trade-in
- **THEN** the quote shows list price 10995.00, net price 10995.00, delivery 150.00, VAT 2229.00, registration fee 55.00 and total 13429.00

### Requirement: Optional quote lines
The system SHALL show a trade discount, salesman discount or trade-in line only when that amount applies.

#### Scenario: No optional lines
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002 for customer 2001 with no discount and no trade-in
- **THEN** the quote has no trade discount line, no discount line and no trade-in line

#### Scenario: All optional lines
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1004 for customer 2002 with 10% discount and a 500.00 trade-in
- **THEN** the quote shows trade discount -1675.00, discount (10.0%) -1507.50 and trade-in -500.00

### Requirement: Quotes save nothing
The system SHALL NOT change any data file, or use up any id, when it produces a quote.

#### Scenario: Data unchanged after a quote
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002 for customer 2001 with 5% discount and a 1000.00 trade-in
- **THEN** the data files are unchanged

#### Scenario: Same vehicle quoted twice
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002 for customer 2001 and then for customer 2002
- **THEN** both quotes are produced
- **AND** the vehicle stays in stock
