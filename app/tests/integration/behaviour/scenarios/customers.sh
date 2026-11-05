# Scenarios for openspec/specs/customers/spec.md

Scenario "Customer list"
  Given "the sample showroom data"
  When  "I list customers"
  Then  "the line for \"2002\" shows \"Marlow Motors Ltd\""
  And   "the line for \"2002\" shows \"Trade\""
  And   "the line for \"2001\" shows \"Sarah Whitfield\""
  And   "the line for \"2001\" shows \"Retail\""

Scenario "Trade customer added"
  Given "the sample showroom data"
  When  "I add a customer with name \"Trade Co\" and trade answer \"Y\""
  Then  "customer 2009 is saved with type \"T\""

Scenario "Name missing"
  Given "the sample showroom data"
  When  "I add a customer with name \"\""
  Then  "the screen shows \"Name is required.\""
  And   "the data files are unchanged"

Scenario "Search by part of a name"
  Given "the sample showroom data"
  When  "I search customers for \"Taxis\""
  Then  "the screen shows \"Greenway Taxis\""
  And   "the screen shows \"1 match(es)\""
