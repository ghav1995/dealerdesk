# invoices Specification

## Purpose

Defines how a sale becomes an invoice, and guarantees that an issued invoice keeps
showing the amounts it was issued with.

## Requirements

### Requirement: Selling a vehicle
The system SHALL show an invoice preview and ask for confirmation. On confirmation
it SHALL save an invoice with the next invoice number and today's date, and mark
the vehicle as sold. If not confirmed, it SHALL change nothing.

#### Scenario: Confirmed sale
- **WHEN** staff answer Y to the confirmation
- **THEN** an invoice is saved and the vehicle status becomes sold

#### Scenario: Cancelled sale
- **WHEN** staff answer anything other than Y
- **THEN** no invoice is saved and the vehicle status does not change

### Requirement: Invoice amounts are stored
The system SHALL store the list price, combined discounts, net price, VAT, combined fees, trade-in and total on the invoice when it is created. Combined discounts SHALL include any fleet discount, and the fleet discount SHALL also be stored on its own.

#### Scenario: Combined discounts
- **WHEN** a sale has a trade discount and a salesman discount
- **THEN** the invoice stores the two added together as one discount amount

#### Scenario: Fleet sale amounts
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff sell vehicle 1002 to customer 2008 with no discount and no trade-in
- **THEN** the invoice stores list 10995.00, discount 439.80, net 10555.20, VAT 2141.04, fees 205.00, total 12901.24 and fleet discount 439.80

#### Scenario: Fleet sale with every deduction
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff sell vehicle 1007 to customer 2008 with 5% discount and a 1000.00 trade-in
- **THEN** the invoice stores discount 1122.00, net 11628.00, VAT 2355.60, trade-in 1000.00, total 13188.60 and fleet discount 510.00

### Requirement: Issued invoices do not change
The system SHALL display an invoice from its stored amounts. Later changes to a
vehicle price or customer SHALL NOT change the amounts on an issued invoice.

#### Scenario: Greenway invoice from 2021
- **WHEN** staff view invoice 50232
- **THEN** it shows list 10495.00, discounts -839.60, net 9655.40, fees 205.00, VAT 1961.08 and total 11821.48

#### Scenario: Vehicle price changed after sale
- **WHEN** the price of a sold vehicle is changed and its invoice is viewed
- **THEN** the invoice shows the original amounts

### Requirement: Fleet status does not change issued invoices
The system SHALL display an invoice from what was stored when it was issued, whatever the customer's fleet status is now.

#### Scenario: Earlier invoice after a customer becomes fleet
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff view invoice 50232, issued before they became fleet
- **THEN** it shows list 10495.00, discounts -839.60, net 9655.40 and total 11821.48
- **AND** there is no fleet discount line

#### Scenario: Fleet invoice after fleet status is removed
- **GIVEN** vehicle 1002 sold to fleet customer 2008, who is then returned to retail
- **WHEN** staff view invoice 50233
- **THEN** it still shows a fleet discount of -439.80 and the total 12901.24

### Requirement: Invoice display
The system SHALL show a trade-in line only when the invoice has a trade-in. It SHALL show the discounts line on every invoice with no fleet discount, including when it is 0.00. An invoice with a fleet discount SHALL show a "Fleet discount" line, and a discounts line only for any other discounts.

#### Scenario: Invoice with a trade-in
- **WHEN** staff view invoice 50230
- **THEN** a trade-in line shows -1500.00 and the total is 9331.30

#### Scenario: Fleet invoice with no other discount
- **GIVEN** vehicle 1002 sold to fleet customer 2008 with no other discount
- **WHEN** staff view invoice 50233
- **THEN** the screen shows a line labelled "Fleet discount" with -439.80 and the total 12901.24
- **AND** there is no discounts line

#### Scenario: Fleet invoice with another discount
- **GIVEN** vehicle 1007 sold to fleet customer 2008 with 5% discount
- **WHEN** staff view invoice 50233
- **THEN** the screen shows a fleet discount of -510.00 and discounts of -612.00

#### Scenario: Invoice preview for a fleet customer
- **GIVEN** Greenway Taxis (2008) marked as a fleet customer
- **WHEN** staff reach the preview for selling vehicle 1002 to customer 2008
- **THEN** the preview shows a fleet discount of -439.80 and the total 12901.24

### Requirement: Selling uses the quote flow
The system SHALL find the vehicle and customer as the quote screen does, show the amounts titled "INVOICE PREVIEW", and refuse a vehicle or customer that cannot be used.

#### Scenario: Invoice preview
- **GIVEN** the sample showroom data
- **WHEN** staff sell vehicle 1002 to customer 2001 with no discount
- **THEN** the preview is titled "INVOICE PREVIEW" and shows the total 13429.00 before asking for confirmation

#### Scenario: Selling an unknown vehicle
- **GIVEN** the sample showroom data
- **WHEN** staff sell vehicle 9999
- **THEN** the system shows "Vehicle not found."
- **AND** the data files are unchanged

#### Scenario: Selling to an unknown customer
- **GIVEN** the sample showroom data
- **WHEN** staff sell vehicle 1002 to customer 9999
- **THEN** the system shows "Customer not found."
- **AND** the data files are unchanged

#### Scenario: Selling a sold vehicle
- **GIVEN** a vehicle that has just been sold
- **WHEN** staff try to sell it again
- **THEN** the system shows "Vehicle is already sold."
- **AND** no second invoice is created

### Requirement: Recording a sale
The system SHALL save the invoice with the next invoice number and today's date, mark the vehicle as sold, and move the invoice counter on.

#### Scenario: First sale gets the next number
- **GIVEN** the sample showroom data
- **WHEN** staff confirm a sale
- **THEN** the system shows "Invoice 50233 created."
- **AND** the invoice is saved with today's date

#### Scenario: Retail sale amounts
- **GIVEN** the sample showroom data
- **WHEN** staff sell vehicle 1002 to customer 2001 with no discount and no trade-in
- **THEN** the invoice stores list 10995.00, discount 0.00, net 10995.00, VAT 2229.00, fees 205.00, trade-in 0.00 and total 13429.00

#### Scenario: Trade sale amounts
- **GIVEN** the sample showroom data
- **WHEN** staff sell vehicle 1004 to customer 2002 with no other discount
- **THEN** the invoice stores list 16750.00, discount 1675.00, net 15075.00, VAT 3045.00, fees 205.00 and total 18325.00

#### Scenario: Trade sale with every deduction
- **GIVEN** the sample showroom data
- **WHEN** staff sell vehicle 1004 to customer 2002 with 10% discount and a 500.00 trade-in
- **THEN** the invoice stores discount 3182.50, net 13567.50, VAT 2743.50, trade-in 500.00 and total 16016.00

#### Scenario: Second sale gets the following number
- **GIVEN** a sale has just been confirmed
- **WHEN** staff confirm another sale
- **THEN** the system shows "Invoice 50234 created."

### Requirement: Reserved vehicles can be sold
The system SHALL sell a reserved vehicle to any customer. This is known bug BUG-015.

#### Scenario: Known bug: BUG-015 reserved vehicle sold
- **GIVEN** the sample showroom data
- **WHEN** staff sell reserved vehicle 1006 to customer 2001
- **THEN** the system shows "Invoice 50233 created."
- **AND** the vehicle is saved as sold

### Requirement: Negative invoices
The system SHALL save an invoice with a negative total when the trade-in is larger than the amount due. This is known bug BUG-004.

#### Scenario: Known bug: BUG-004 invoice saved with a negative total
- **GIVEN** the sample showroom data
- **WHEN** staff sell vehicle 1002 to customer 2001 with a 99999.00 trade-in
- **THEN** the invoice is saved with the total -86570.00

### Requirement: Invoice capacity
The system SHALL hold at most 2000 invoices, and SHALL refuse a sale before asking for any details.

#### Scenario: Invoice file full
- **GIVEN** an invoice file holding 2000 invoices
- **WHEN** staff choose Sell vehicle
- **THEN** the system shows "Invoice file is full!"
- **AND** does not ask for a vehicle

### Requirement: Listing invoices
The system SHALL list every invoice with its number, date, vehicle id, customer name and total, followed by how many there are.

#### Scenario: Full invoice list
- **GIVEN** the sample showroom data
- **WHEN** staff list invoices
- **THEN** the screen shows 50230, 2021-02-11, 1009, David Okafor and 9331.30
- **AND** the screen shows "3 invoice(s)"

#### Scenario: Customer no longer on file in the list
- **GIVEN** the sample showroom data without customer 2003
- **WHEN** staff list invoices
- **THEN** invoice 50230 shows the customer as (unknown) and keeps the total 9331.30

### Requirement: Viewing an invoice
The system SHALL show the invoice number, date, customer, vehicle and stored amounts, and SHALL say so when the number does not exist.

#### Scenario: Invoice with every line
- **GIVEN** the sample showroom data
- **WHEN** staff view invoice 50230
- **THEN** the screen shows date 2021-02-11, David Okafor and DE18 PQR Peugeot 308 1.2 PureTech Allure
- **AND** shows list 9295.00, discounts -464.75, net 8830.25, fees 205.00 and VAT 1796.05

#### Scenario: Invoice with no trade-in
- **GIVEN** the sample showroom data
- **WHEN** staff view invoice 50231
- **THEN** the screen has no trade-in line and the total is 14809.60

#### Scenario: Unknown invoice number
- **GIVEN** the sample showroom data
- **WHEN** staff view invoice 99999
- **THEN** the system shows "Invoice not found."

#### Scenario: Customer and vehicle no longer on file
- **GIVEN** the sample showroom data without customer 2003 or vehicle 1009
- **WHEN** staff view invoice 50230
- **THEN** the customer shows as (unknown), the vehicle shows as ?, and the total is still 9331.30

### Requirement: Zero discount display
The system SHALL show an invoice with no discount as "Discounts -0.00". This is known bug BUG-011.

#### Scenario: Known bug: BUG-011 no discount shows as -0.00
- **GIVEN** a vehicle sold with no discount
- **WHEN** staff view its invoice
- **THEN** the discounts line shows -0.00
