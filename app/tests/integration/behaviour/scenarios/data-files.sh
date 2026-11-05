# Scenarios for openspec/specs/data-files/spec.md

Scenario "Started from the application folder"
  Given "the sample showroom data"
  When  "I list stock"
  Then  "the screen shows \"9 vehicle(s)\""

Scenario "Pipe typed into a field"
  Given "the sample showroom data"
  When  "I add a customer with name \"A|B Ltd\""
  Then  "customer 2009 is saved with name \"A/B Ltd\""

Scenario "Windows line endings"
  Given "the sample showroom data"
  And   "the stock file has CRLF line endings"
  When  "I list stock"
  Then  "the screen shows \"9 vehicle(s)\""

Scenario "Vehicle added"
  Given "the sample showroom data"
  When  "I add a vehicle with plate \"AB12 CDE\""
  Then  "stock.dat contains \"1013|AB12 CDE|\""
  And   "next_ids.dat contains \"vehicle=1014\""
