# Fleet discount evidence

This folder shows [TICKET-142](../TICKET-142.md) working in the real app, written as use cases so the business can read them and check them.

| Start here | What it holds |
|---|---|
| [use-cases.md](use-cases.md) | Ten use cases, each with its scenario, steps, real screens and tests |
| [diagrams.md](diagrams.md) | ASCII diagrams, from marking a customer to the stored invoice and the release |
| [images/](images/) | 29 screens from the real app |
| [transcripts/](transcripts/) | The text behind every image, and the data file checks |
| [capture/](capture/) | The scripts that produced them |

## The ticket, checked

| The ticket says | Shown in | What the evidence shows |
|---|---|---|
| Staff can mark a customer as fleet, new or existing | [UC-01](use-cases.md#uc-01-mark-an-existing-customer-as-fleet), [UC-03](use-cases.md#uc-03-add-a-new-fleet-customer) | Greenway Taxis marked from the Customers menu, and Fleet Co added as fleet |
| 4% off the vehicle price, with fees not discounted | [UC-05](use-cases.md#uc-05-quote-a-fleet-customer) | 439.80 off 10995.00, with delivery still 150.00 and the registration fee still 55.00 |
| Its own line on quotes and invoices | [UC-05](use-cases.md#uc-05-quote-a-fleet-customer), [UC-06](use-cases.md#uc-06-sell-to-a-fleet-customer) | A "Fleet discount" line on both |
| A fleet quote has that line and the correct total | [UC-05](use-cases.md#uc-05-quote-a-fleet-customer) | Totals of 12901.24, 13188.60 and 12719.80, each worked out again separately |
| Non-fleet quotes and invoices are unchanged, to the penny | [UC-07](use-cases.md#uc-07-customers-who-are-not-fleet) | 13 screens on v2.6 and v2.7, with no line different apart from the version, and identical data files |
| Existing data files load without conversion | [UC-08](use-cases.md#uc-08-existing-invoices-and-data-files) | The sample files load as they are, and old rows are byte-identical after a save |
| Existing invoices still display correctly | [UC-08](use-cases.md#uc-08-existing-invoices-and-data-files) | Invoice 50232 reads the same before and after Greenway Taxis became fleet |

Two use cases go beyond the ticket, because the feature depends on them. [UC-09](use-cases.md#uc-09-a-fleet-customer-with-no-email) shows the BUG-002 fix, and [UC-10](use-cases.md#uc-10-roll-back-to-v26-and-return) shows what a rollback does and what it costs.

CI also [passed on the last commit of pull request #4](https://github.com/ghav1995/dealerdesk/actions/runs/42174733945).

## How it was captured

- **The real app.** Version 2.7 was built from `28b4830`, the merge of pull request #4. Version 2.6 was built from `4d5b7b4`, the merge of pull request #3.
- **Typed as staff type.** Each use case sends its keystrokes through a pseudo-terminal, so answers appear on screen as they do for staff.
- **Throwaway data.** Each use case starts from a copy of the sample data, so `app/data` is never touched.
- **Real restarts.** Each session is a new process, so "after a restart" means the app was stopped and started again.
- **No empty evidence.** A screen that does not appear stops the script, so keystrokes out of step cannot quietly produce nothing.

The images are drawn from the transcripts by a headless browser, so they are not screenshots of a terminal window. The yellow highlight is the only thing added.

## How it was checked

Evidence can be wrong too, so it was checked against things that do not depend on it:

- **The amounts.** The 9 quotes and 7 invoices on these screens were recalculated from the pricing rules, separately from the app's code, and all match to the penny.
- **The words.** Every scenario in the use cases is the exact text of a spec scenario, every test named exists, and every data block matches a transcript line for line.
- **The comparison.** UC-07 has a control. With a fleet customer, the same keystrokes show differences, so the comparison can fail.
- **The tests.** With the rate wrongly set to 5%, the unit tests and 18 behaviour scenarios fail.

Reading the first capture critically also changed it. It claimed that Greenway's `F` survived v2.6, but in that run v2.6 had only read the file, so nothing was being tested. In the final capture v2.6 adds a customer first, which rewrites the file.

## What this does not show

- **A deployment.** This covers what the app does and whether the tests pass. The deploy stages are simulated, so nothing here shows the app running at a dealership.
- **Real customer data.** Everything runs on the sample data.
- **Every path.** The use cases cover the fleet feature. The 220 tested scenarios in `openspec/specs/` cover the rest of the app.
- **Other compilers.** These builds use gcc. Earlier releases were built with Borland, which was not tried.

## Running it again

```text
bash docs/evidences/capture/capture.sh    Linux or WSL, takes a few minutes
node docs/evidences/capture/render.js     needs Node, and Edge or Chrome
```

Invoices are dated the day they are created, so a new capture changes those dates.
