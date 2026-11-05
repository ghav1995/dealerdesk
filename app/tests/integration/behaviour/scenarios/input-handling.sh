# Scenarios for openspec/specs/input-handling/spec.md

Scenario "Number with text after it"
  Given "the sample showroom data"
  When  "I type \"1abc\" on the main menu"
  Then  "the screen shows \"Reserve / release vehicle\""

Scenario "Id with text after it"
  Given "the sample showroom data"
  When  "I quote vehicle 1002abc for customer 2001x"
  Then  "the screen shows \"Vehicle  : yf20 hbn\""
  And   "the screen shows \"Customer : Sarah Whitfield\""

Scenario "Text typed as a year"
  Given "the sample showroom data"
  When  "I add a vehicle with year \"abc\""
  Then  "vehicle 1013 is saved with year \"0\""

Scenario "Amount with pence"
  Given "the sample showroom data"
  When  "I change the price of vehicle 1002 to \"12.5\""
  Then  "vehicle 1002 is saved with price \"12.50\""

Scenario "Amount with a leading space"
  Given "the sample showroom data"
  When  "I change the price of vehicle 1002 to \" 7\""
  Then  "vehicle 1002 is saved with price \"7.00\""

Scenario "Amount in scientific notation"
  Given "the sample showroom data"
  When  "I change the price of vehicle 1002 to \"1e2\""
  Then  "vehicle 1002 is saved with price \"100.00\""

Scenario "Amount with a currency sign"
  Given "the sample showroom data"
  When  "I change the price of vehicle 1002 to \"£100\""
  Then  "the screen shows \"Price not changed.\""

Scenario "Text typed as an amount"
  Given "the sample showroom data"
  When  "I change the price of vehicle 1002 to \"abc\""
  Then  "the screen shows \"Price not changed.\""

Scenario "Known bug: BUG-003 list price typed with a comma"
  Given "the sample showroom data"
  When  "I add a vehicle with list price \"10,995\""
  Then  "vehicle 1013 is saved with price \"10.00\""

Scenario "Known bug: BUG-003 new price typed with a comma"
  Given "the sample showroom data"
  When  "I change the price of vehicle 1002 to \"1,000\""
  Then  "vehicle 1002 is saved with price \"1.00\""

Scenario "Known bug: BUG-003 trade-in typed with a comma"
  Given "the sample showroom data"
  When  "I quote vehicle 1002 for customer 2001 with 1,000 trade-in"
  Then  "the trade-in is -1.00"
  And   "the total is 13428.00"
