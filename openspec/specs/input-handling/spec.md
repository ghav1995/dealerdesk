# input-handling Specification

## Purpose
Defines how DealerDesk turns what staff type into numbers, money, yes/no answers and text, including input that is blank, malformed or too long, and input that ends early.

## Requirements

### Requirement: Whole numbers
The system SHALL read a whole number from the start of what is typed, and SHALL read blank or non-numeric input as 0.

#### Scenario: Number with text after it
- **GIVEN** the sample showroom data
- **WHEN** staff type 1abc on the main menu
- **THEN** the system opens the stock menu

#### Scenario: Id with text after it
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002abc for customer 2001x
- **THEN** the quote is for vehicle 1002 and customer 2001

#### Scenario: Text typed as a year
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with the year abc
- **THEN** the year is saved as 0

### Requirement: Money
The system SHALL read an amount from the start of what is typed, ignoring leading spaces, and SHALL read blank or non-numeric input as 0.

#### Scenario: Amount with pence
- **GIVEN** the sample showroom data
- **WHEN** staff change the price of vehicle 1002 to 12.5
- **THEN** the price is saved as 12.50

#### Scenario: Amount with a leading space
- **GIVEN** the sample showroom data
- **WHEN** staff change the price of vehicle 1002 to " 7"
- **THEN** the price is saved as 7.00

#### Scenario: Amount in scientific notation
- **GIVEN** the sample showroom data
- **WHEN** staff change the price of vehicle 1002 to 1e2
- **THEN** the price is saved as 100.00

#### Scenario: Amount with a currency sign
- **GIVEN** the sample showroom data
- **WHEN** staff change the price of vehicle 1002 to £100
- **THEN** the system shows "Price not changed."

#### Scenario: Text typed as an amount
- **GIVEN** the sample showroom data
- **WHEN** staff change the price of vehicle 1002 to abc
- **THEN** the system shows "Price not changed."

### Requirement: Commas in money
The system SHALL stop reading an amount at a comma, so the rest of the amount is lost without warning. This is known bug BUG-003.

#### Scenario: Known bug: BUG-003 list price typed with a comma
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with the list price 10,995
- **THEN** the vehicle is saved with the price 10.00

#### Scenario: Known bug: BUG-003 new price typed with a comma
- **GIVEN** the sample showroom data
- **WHEN** staff change the price of vehicle 1002 to 1,000
- **THEN** the price is saved as 1.00

#### Scenario: Known bug: BUG-003 trade-in typed with a comma
- **GIVEN** the sample showroom data
- **WHEN** staff quote vehicle 1002 for customer 2001 with the trade-in 1,000
- **THEN** the quote shows a trade-in of -1.00 and a total of 13428.00

### Requirement: Yes and no answers
The system SHALL read an answer as yes when it starts with Y or y, and as no otherwise.

#### Scenario: Upper case Y
- **GIVEN** the sample showroom data
- **WHEN** staff answer Y to the trade question when adding a customer
- **THEN** the customer is saved as type T

#### Scenario: Lower case y
- **GIVEN** the sample showroom data
- **WHEN** staff answer y to the trade question when adding a customer
- **THEN** the customer is saved as type T

#### Scenario: The word yes
- **GIVEN** the sample showroom data
- **WHEN** staff answer yes to the sale confirmation
- **THEN** the invoice is created

#### Scenario: The word no
- **GIVEN** the sample showroom data
- **WHEN** staff answer no to the sale confirmation
- **THEN** the sale is cancelled

#### Scenario: Any other word
- **GIVEN** the sample showroom data
- **WHEN** staff answer x to the sale confirmation
- **THEN** the sale is cancelled

#### Scenario: Blank answer
- **GIVEN** the sample showroom data
- **WHEN** staff press ENTER at the trade question when adding a customer
- **THEN** the customer is saved as type R

### Requirement: Text that is too long
The system SHALL keep only as much text as a field can hold, without warning, and SHALL discard the rest so the next prompt is not affected.

#### Scenario: Long plate
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with the plate ABCDEFGHIJKLMNOP and the make Ford
- **THEN** the plate is saved as ABCDEFGHIJK
- **AND** the make is saved as Ford

#### Scenario: Long customer name
- **GIVEN** the sample showroom data
- **WHEN** staff add a customer with a name of 60 characters
- **THEN** the first 47 characters are saved

### Requirement: Pipe characters
The system SHALL replace a `|` with `/` in any text typed at a prompt.

#### Scenario: Pipe in a plate and a make
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with the plate A|B and the make F|d
- **THEN** the vehicle is saved with the plate A/B and the make F/d

### Requirement: Input ending early
The system SHALL exit with a success status, without saying "Goodbye." and without saving unfinished work, when its input ends.

#### Scenario: Input ends at a menu
- **GIVEN** the sample showroom data
- **WHEN** input ends on the main menu
- **THEN** the app exits with status 0 and does not say "Goodbye."

#### Scenario: Input ends while adding a vehicle
- **GIVEN** the sample showroom data
- **WHEN** input ends after the make is typed
- **THEN** the data files are unchanged

#### Scenario: Input ends during a quote
- **GIVEN** the sample showroom data
- **WHEN** input ends after the vehicle id is typed on the quote screen
- **THEN** the data files are unchanged
