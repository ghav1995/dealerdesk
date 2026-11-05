# Spec Delta

## ADDED Requirements

### Requirement: Listing vehicles
The system SHALL offer one list of unsold vehicles and one of all vehicles, each showing id, plate, make, model, year, miles, price and status, followed by how many there are.

#### Scenario: Stock list leaves out sold vehicles
- **GIVEN** the sample showroom data
- **WHEN** staff list stock
- **THEN** the title is Stock List and the screen shows "9 vehicle(s)"
- **AND** sold vehicle 1001 is not listed

#### Scenario: All vehicles list includes sold vehicles
- **GIVEN** the sample showroom data
- **WHEN** staff list all vehicles
- **THEN** the title is All Vehicles and the screen shows "12 vehicle(s)"
- **AND** vehicle 1001 is shown as SOLD

#### Scenario: Status labels
- **GIVEN** the sample showroom data
- **WHEN** staff list all vehicles
- **THEN** vehicle 1002 is shown as IN STOCK and vehicle 1006 as RESERVED

#### Scenario: Long models are cut in the list
- **GIVEN** the sample showroom data
- **WHEN** staff list all vehicles
- **THEN** vehicle 1001 shows the model as "Fiesta 1.0 EcoBoost Ze"

### Requirement: Adding vehicles
The system SHALL ask for the plate, make, model, year, mileage, cost and list price, and save the vehicle as in stock with the next vehicle id.

#### Scenario: Vehicle added to stock
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with the plate AB12 CDE and the list price 6500.00
- **THEN** the system shows "Vehicle 1013 added."
- **AND** the vehicle is in stock at 6500.00

#### Scenario: Added plate keeps its case
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with the plate ab12 cde
- **THEN** the plate is saved as ab12 cde

### Requirement: Refusing a vehicle
The system SHALL refuse a vehicle with a blank plate, or a list price of zero or less, after asking for every detail. It SHALL save nothing and SHALL NOT use up a vehicle id.

#### Scenario: Blank plate
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with a blank plate
- **THEN** the system shows "Plate and list price are required."
- **AND** the data files are unchanged

#### Scenario: Zero list price
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with the list price 0
- **THEN** the system shows "Plate and list price are required."
- **AND** the data files are unchanged

#### Scenario: Negative list price
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with the list price -1
- **THEN** the system shows "Plate and list price are required."
- **AND** the data files are unchanged

#### Scenario: List price that is not a number
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with the list price £100
- **THEN** the system shows "Plate and list price are required."
- **AND** the data files are unchanged

### Requirement: Stock capacity
The system SHALL hold at most 500 vehicles, and SHALL refuse a new one before asking for any details.

#### Scenario: Stock file full
- **GIVEN** a stock file holding 500 vehicles
- **WHEN** staff choose Add vehicle
- **THEN** the system shows "Stock file is full!"
- **AND** does not ask for a plate

### Requirement: Finding a vehicle by plate
The system SHALL show the id, vehicle, mileage, price and status of each vehicle with exactly the plate entered.

#### Scenario: Plate found
- **GIVEN** the sample showroom data
- **WHEN** staff search for the plate yf20 hbn
- **THEN** the screen shows id 1002, Vauxhall Corsa 1.2 SE (2020), mileage 21455, price 10995.00 and status IN STOCK

#### Scenario: Plate not found
- **GIVEN** the sample showroom data
- **WHEN** staff search for the plate ZZ99 ZZZ
- **THEN** the system shows "No vehicle with plate ZZ99 ZZZ"

#### Scenario: Blank plate search
- **GIVEN** the sample showroom data
- **WHEN** staff search with a blank plate
- **THEN** the system shows "No vehicle with plate"

### Requirement: Changing a price
The system SHALL show the vehicle and its current price, then save a new price above zero. Otherwise it SHALL leave the price unchanged.

#### Scenario: Price changed
- **GIVEN** the sample showroom data
- **WHEN** staff change the price of vehicle 1002 to 11250.50
- **THEN** the screen shows the current price 10995.00 and "Price updated."
- **AND** the price is saved as 11250.50

#### Scenario: Blank new price
- **GIVEN** the sample showroom data
- **WHEN** staff press ENTER at the new price for vehicle 1002
- **THEN** the system shows "Price not changed."
- **AND** the data files are unchanged

#### Scenario: Zero new price
- **GIVEN** the sample showroom data
- **WHEN** staff change the price of vehicle 1002 to 0
- **THEN** the system shows "Price not changed."

#### Scenario: Negative new price
- **GIVEN** the sample showroom data
- **WHEN** staff change the price of vehicle 1002 to -5
- **THEN** the system shows "Price not changed."

#### Scenario: Price change for an unknown vehicle
- **GIVEN** the sample showroom data
- **WHEN** staff change the price of vehicle 9999
- **THEN** the system shows "Vehicle not found."

#### Scenario: Sold vehicle can be repriced
- **GIVEN** the sample showroom data
- **WHEN** staff change the price of sold vehicle 1001 to 12345
- **THEN** the system shows "Price updated."

### Requirement: Reserving and releasing
The system SHALL switch an in-stock vehicle to reserved, and a reserved vehicle back to in stock.

#### Scenario: Reserved vehicle released
- **GIVEN** a vehicle that has been reserved
- **WHEN** staff choose Reserve / release for it again
- **THEN** the system shows "Vehicle 1002 is now IN STOCK."

#### Scenario: Reserve for an unknown vehicle
- **GIVEN** the sample showroom data
- **WHEN** staff reserve vehicle 9999
- **THEN** the system shows "Vehicle not found."

### Requirement: Duplicate plates
The system SHALL accept a plate that is already in stock, and a search SHALL show every vehicle with that plate. This is known bug BUG-010.

#### Scenario: Known bug: BUG-010 same plate added twice
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with the plate LK19 XRT, which already exists
- **THEN** the system shows "Vehicle 1013 added."
- **AND** a search for LK19 XRT shows two vehicles

### Requirement: Unchecked vehicle details
The system SHALL accept a negative cost price without warning. This is known bug BUG-014.

#### Scenario: Known bug: BUG-014 negative cost price
- **GIVEN** the sample showroom data
- **WHEN** staff add a vehicle with the cost price -500
- **THEN** the vehicle is saved with the cost -500.00
