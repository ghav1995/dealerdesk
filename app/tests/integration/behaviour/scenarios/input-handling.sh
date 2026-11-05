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

Scenario "Upper case Y"
  Given "the sample showroom data"
  When  "I add a customer with trade answer \"Y\""
  Then  "customer 2009 is saved with type \"T\""

Scenario "Lower case y"
  Given "the sample showroom data"
  When  "I add a customer with trade answer \"y\""
  Then  "customer 2009 is saved with type \"T\""

Scenario "The word yes"
  Given "the sample showroom data"
  When  "I answer \"yes\" to selling vehicle 1002 to customer 2001"
  Then  "the screen shows \"Invoice 50233 created.\""

Scenario "The word no"
  Given "the sample showroom data"
  When  "I answer \"no\" to selling vehicle 1002 to customer 2001"
  Then  "the screen shows \"Sale cancelled.\""

Scenario "Any other word"
  Given "the sample showroom data"
  When  "I answer \"x\" to selling vehicle 1002 to customer 2001"
  Then  "the screen shows \"Sale cancelled.\""

Scenario "Blank answer"
  Given "the sample showroom data"
  When  "I add a customer with trade answer \"\""
  Then  "customer 2009 is saved with type \"R\""

Scenario "Long plate"
  Given "the sample showroom data"
  When  "I add a vehicle with plate \"ABCDEFGHIJKLMNOP\" and make \"Ford\""
  Then  "vehicle 1013 is saved with plate \"ABCDEFGHIJK\""
  And   "vehicle 1013 is saved with make \"Ford\""

Scenario "Long customer name"
  Given "the sample showroom data"
  When  "I add a customer with name \"NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\""
  Then  "customer 2009 is saved with name \"NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\""

Scenario "Pipe in a plate and a make"
  Given "the sample showroom data"
  When  "I add a vehicle with plate \"A|B\" and make \"F|d\""
  Then  "vehicle 1013 is saved with plate \"A/B\""
  And   "vehicle 1013 is saved with make \"F/d\""

Scenario "Input ends at a menu"
  Given "the sample showroom data"
  When  "input ends on the main menu"
  Then  "the app exits with status 0"
  And   "the screen does not show \"Goodbye.\""

Scenario "Input ends while adding a vehicle"
  Given "the sample showroom data"
  When  "input ends after the make is typed"
  Then  "the data files are unchanged"

Scenario "Input ends during a quote"
  Given "the sample showroom data"
  When  "input ends after the vehicle id is typed on the quote screen"
  Then  "the data files are unchanged"
