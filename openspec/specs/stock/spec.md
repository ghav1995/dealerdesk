# stock Specification

## Purpose

Defines how DealerDesk tracks vehicles from arrival to sale, including the states
that decide whether a vehicle can be quoted or sold.

## Requirements

### Requirement: Vehicle status
The system SHALL hold each vehicle as in stock, reserved or sold. Reserve/release
SHALL switch between in stock and reserved, and SHALL refuse a sold vehicle.

#### Scenario: Reserving a vehicle
- **WHEN** staff reserve a vehicle that is in stock
- **THEN** its status becomes reserved

#### Scenario: Reserving a sold vehicle
- **WHEN** staff reserve a sold vehicle
- **THEN** the system says it is already sold and nothing changes

### Requirement: Quoting and selling by status
The system SHALL refuse to quote or sell a sold vehicle. Vehicles in stock and
reserved vehicles SHALL both be available to quote and sell.

#### Scenario: Sold vehicle
- **WHEN** staff enter a sold vehicle on the quote screen
- **THEN** the system says it is already sold

#### Scenario: Reserved vehicle
- **WHEN** staff quote a reserved vehicle
- **THEN** the quote is produced as normal

### Requirement: Registration plates
The system SHALL store plates exactly as typed, and SHALL find a plate only by an
exact match, including case and spaces. This protects cherished plates.

#### Scenario: Different case
- **WHEN** staff search for lk19 xrt and the plate is stored as LK19 XRT
- **THEN** no vehicle is found
