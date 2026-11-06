# Spec Delta

## MODIFIED Requirements

### Requirement: Submenus
The system SHALL offer a submenu for stock, customers and invoices, and each SHALL include 0 to go back.

#### Scenario: Stock menu options
- **GIVEN** the sample showroom data
- **WHEN** staff choose Stock
- **THEN** the menu offers 1 List stock, 2 List all vehicles, 3 Add vehicle, 4 Find by plate, 5 Change price, 6 Reserve / release vehicle and 0 Back

#### Scenario: Customers menu options
- **GIVEN** the sample showroom data
- **WHEN** staff choose Customers
- **THEN** the menu offers 1 List customers, 2 Add customer, 3 Find customer, 4 Mark / unmark fleet customer and 0 Back

#### Scenario: Invoices menu options
- **GIVEN** the sample showroom data
- **WHEN** staff choose Invoices
- **THEN** the menu offers 1 List invoices, 2 View invoice and 0 Back

### Requirement: Invalid choices
The system SHALL show "Invalid option" for a number that is not on the current menu, wait for ENTER, and show the same menu again.

#### Scenario: Unknown option on the main menu
- **GIVEN** the sample showroom data
- **WHEN** staff type 6 on the main menu
- **THEN** the system shows "Invalid option"
- **AND** the main menu is shown again after ENTER

#### Scenario: Negative option on the main menu
- **GIVEN** the sample showroom data
- **WHEN** staff type -1 on the main menu
- **THEN** the system shows "Invalid option"

#### Scenario: Unknown option on the stock menu
- **GIVEN** the sample showroom data
- **WHEN** staff type 7 on the stock menu
- **THEN** the system shows "Invalid option"
- **AND** the stock menu is shown again after ENTER

#### Scenario: Unknown option on the customers menu
- **GIVEN** the sample showroom data
- **WHEN** staff type 5 on the customers menu
- **THEN** the system shows "Invalid option"

#### Scenario: Unknown option on the invoices menu
- **GIVEN** the sample showroom data
- **WHEN** staff type 3 on the invoices menu
- **THEN** the system shows "Invalid option"
