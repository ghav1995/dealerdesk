# Scenarios for openspec/specs/stock/spec.md

Scenario "Reserving a vehicle"
  Given "the sample showroom data"
  When  "I reserve or release vehicle 1002"
  Then  "the screen shows \"Vehicle 1002 is now RESERVED.\""
  And   "vehicle 1002 is saved with status \"1\""

Scenario "Reserving a sold vehicle"
  Given "the sample showroom data"
  When  "I reserve or release vehicle 1001"
  Then  "the screen shows \"Vehicle is already sold.\""
  And   "the data files are unchanged"

Scenario "Sold vehicle"
  Given "the sample showroom data"
  When  "I try to quote vehicle 1001"
  Then  "the screen shows \"Vehicle is already sold.\""

Scenario "Reserved vehicle"
  Given "the sample showroom data"
  When  "I quote vehicle 1006 for customer 2003"
  Then  "the total is 23029.00"

Scenario "Different case"
  Given "the sample showroom data"
  When  "I search for plate \"lk19 xrt\""
  Then  "the screen shows \"No vehicle with plate lk19 xrt\""
