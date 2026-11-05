# Spec Delta

## Purpose

Defines how staff move around DealerDesk: the menus they see, what happens when a choice is not valid, and how they go back or leave the app.

## ADDED Requirements

### Requirement: Main menu
The system SHALL start on the main menu, offering Stock, Customers, Quote, Sell vehicle, Invoices, Help and Exit.

#### Scenario: Main menu options
- **GIVEN** the sample showroom data
- **WHEN** the app starts
- **THEN** the main menu offers 1 Stock, 2 Customers, 3 Quote, 4 Sell vehicle, 5 Invoices, 9 Help and 0 Exit

### Requirement: Submenus
The system SHALL offer a submenu for stock, customers and invoices, and each SHALL include 0 to go back.

#### Scenario: Stock menu options
- **GIVEN** the sample showroom data
- **WHEN** staff choose Stock
- **THEN** the menu offers 1 List stock, 2 List all vehicles, 3 Add vehicle, 4 Find by plate, 5 Change price, 6 Reserve / release vehicle and 0 Back

#### Scenario: Customers menu options
- **GIVEN** the sample showroom data
- **WHEN** staff choose Customers
- **THEN** the menu offers 1 List customers, 2 Add customer, 3 Find customer and 0 Back

#### Scenario: Invoices menu options
- **GIVEN** the sample showroom data
- **WHEN** staff choose Invoices
- **THEN** the menu offers 1 List invoices, 2 View invoice and 0 Back

### Requirement: Screen header
The system SHALL show the product name, the version and the screen title at the top of every screen.

#### Scenario: Header on the main menu
- **GIVEN** the sample showroom data
- **WHEN** the app starts
- **THEN** the header shows DEALERDESK, the current version and Main Menu

#### Scenario: Header on a list
- **GIVEN** the sample showroom data
- **WHEN** staff list stock
- **THEN** the header shows the title Stock List

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
- **WHEN** staff type 4 on the customers menu
- **THEN** the system shows "Invalid option"

#### Scenario: Unknown option on the invoices menu
- **GIVEN** the sample showroom data
- **WHEN** staff type 3 on the invoices menu
- **THEN** the system shows "Invalid option"

### Requirement: Going back and exiting
The system SHALL return to the main menu when staff type 0 on a submenu, and SHALL say "Goodbye." and exit when staff type 0 on the main menu.

#### Scenario: Back from a submenu
- **GIVEN** the sample showroom data
- **WHEN** staff type 0 on the stock menu
- **THEN** the main menu is shown

#### Scenario: ENTER on a submenu goes back
- **GIVEN** the sample showroom data
- **WHEN** staff press ENTER on the stock menu without typing anything
- **THEN** the main menu is shown

#### Scenario: Exit from the main menu
- **GIVEN** the sample showroom data
- **WHEN** staff type 0 on the main menu
- **THEN** the system says "Goodbye." and exits

### Requirement: Exiting by accident
The system SHALL treat ENTER or letters on the main menu as 0, and so exit. This is known bug BUG-012.

#### Scenario: Known bug: BUG-012 ENTER on the main menu exits
- **GIVEN** the sample showroom data
- **WHEN** staff press ENTER on the main menu without typing anything
- **THEN** the system says "Goodbye." and exits

#### Scenario: Known bug: BUG-012 letters on the main menu exit
- **GIVEN** the sample showroom data
- **WHEN** staff type abc on the main menu
- **THEN** the system says "Goodbye." and exits

### Requirement: Pausing
The system SHALL wait for a line of input after showing a result, and SHALL accept any text as that line.

#### Scenario: Text typed at a pause
- **GIVEN** the sample showroom data
- **WHEN** staff type some text at "Press ENTER to continue"
- **THEN** the system continues to the menu

### Requirement: Help screen
The system SHALL show a fixed help screen. Three of its statements are false, which is known bug BUG-009.

#### Scenario: Help says quotes last 7 days
- **GIVEN** the sample showroom data
- **WHEN** staff choose Help
- **THEN** the screen says quotes are valid for 7 days
- **AND** says a sold vehicle cannot be reserved or sold again

#### Scenario: Known bug: BUG-009 Help gives the wrong trade discount
- **GIVEN** the sample showroom data
- **WHEN** staff choose Help
- **THEN** the screen says trade customers receive 5%, while the app applies 10%

#### Scenario: Known bug: BUG-009 Help describes a removed manager PIN
- **GIVEN** the sample showroom data
- **WHEN** staff choose Help
- **THEN** the screen says discounts above 10% require a manager PIN, while the app asks for none

#### Scenario: Known bug: BUG-009 Help says plates become upper case
- **GIVEN** the sample showroom data
- **WHEN** staff choose Help
- **THEN** the screen says plates are converted to upper case, while the app stores them as typed
