# Scenarios for openspec/specs/pricing/spec.md

Scenario "Retail quote with a discount and a trade-in"
  Given "the sample showroom data"
  When  "I quote vehicle 1002 for customer 2001 with 5% discount and 1000.00 trade-in"
  Then  "the discount is -549.75"
  And   "the net price is 10445.25"
  And   "the VAT is 2119.05"
  And   "the total is 11769.30"
