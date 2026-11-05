# customers Specification

## Purpose

Defines how DealerDesk records customers, and how a customer's type affects what
staff see and what the customer pays.

## Requirements

### Requirement: Customer types
The system SHALL record each customer as trade (T) or retail (R). It SHALL show T
as Trade, and any other value as Retail.

#### Scenario: Customer list
- **WHEN** staff list customers
- **THEN** Marlow Motors Ltd shows as Trade and Sarah Whitfield shows as Retail

### Requirement: Adding a customer
The system SHALL ask for a name, phone, email and whether the customer is trade.
It SHALL require a name, and SHALL NOT use up a customer id if the name is missing.

#### Scenario: Trade customer added
- **WHEN** staff enter a name and answer Y to the trade question
- **THEN** the customer is saved as type T with the next customer id

#### Scenario: Name missing
- **WHEN** staff leave the name blank
- **THEN** the system shows that a name is required and nothing is saved

### Requirement: Finding a customer
The system SHALL find customers whose name contains the search text, matching
upper and lower case exactly.

#### Scenario: Search by part of a name
- **WHEN** staff search for Taxis
- **THEN** Greenway Taxis is listed
