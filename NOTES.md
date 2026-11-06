# Notes

DealerDesk works, but nobody could change it safely. It had no tests, no CI and
documentation nobody trusted. So I made it safe to change first, then shipped
TICKET-142 through what I built.

## What I changed, and why in this order

The fleet discount is a small feature. The real risk is breaking a live billing
system, so the safety net came first and the feature followed it, in five pull requests:

| PR | Version | What changed | Why at this point |
|---|---|---|---|
| #1 | v2.4 | Consistent structure, a build, tests recorded from the original app, CI and CD, agent files | Nothing else is safe without a baseline |
| #2 | v2.5 | Every behaviour as Given/When/Then: 180 tested scenarios, 15 known bugs, no behaviour change | I had to know what the app does first |
| #3 | v2.6 | A version tag starts the deployment, and one skill merges and tags | Releases had to be repeatable first |
| #4 | v2.7 | The fleet discount, reaching 220 tested scenarios | It now had a safety net and a route to release |
| #5 | v2.8 | `docs/evidences/`: use cases, diagrams and real screens | So the business can check it themselves |

The decisions I made along the way:

- **`master` only changes through a pull request**, even for admins, and never by squash,
  because the history is part of the work. Tests must pass, and CI requires the version to
  be `master` plus 0.1, so each pull request is one version.
- **The tag is what gets deployed**, from `master` through dev, test, qa and prd, with an
  approval at each stage. The deploy is simulated. Rollback means choosing an earlier tag.
- **Given/When/Then in plain shell scripts**, so a C app gains no framework.
- **Fix BUG-002 for all customers.** Otherwise a fleet customer with no email loses the
  discount after a restart. This is the one place a non-fleet total changes: trade
  customers with a blank field stop being overcharged.
- **Refuse to make a Trade customer fleet**, so one wrong keystroke cannot cut a discount
  from 10% to 4%.

[docs/fleet-discount.md](docs/fleet-discount.md) shows the last two with real prints. To
prove "unchanged, to the penny", five of the six screen baselines did not change, and the
sixth changed only for the new menu option and prompt. I also ran the real v2.6 binary on
files written by v2.7 to prove the rollback.

## How I worked with the agents

I used Claude Code. `AGENTS.md` holds the rules for any agent, including what to trust and
which claims in the code are false. `CLAUDE.md` adds how the code fits together, and skills
and commands are in `.claude/`.

Every behaviour change followed a spec-based approach with OpenSpec: the agent writes the
proposal, specs, design and tasks, and stops until I have reviewed them. Each scenario
becomes a test, then the code follows in small commits. I made the calls; the agent did
the work and showed what it ran. A hook stops the agent merging outside the
`merge-and-tag` skill, though a merge on GitHub can still skip the tag.

It still got things wrong. Each time, the work looked finished and the proof was missing:

- **A test that tested nothing.** A sales scenario kept typing after an error stopped the
  questions, so a stray `0` exited the app, the trade sale never ran, and the test still
  passed. Breaking the code on purpose caught it: with the trade discount at 5%, the quote
  tests failed and the sales test did not. Deliberate breaks became a standard step. I
  later tidied the history, so this fix has no commit of its own.
- **Destructive tests with no safety in place.** To prove tags were protected, the agent
  relied on a rule GitHub refuses on a personal repository, and chained the "must be
  rejected" tests with no stop on failure. They really created `v9.9`, and moved and
  deleted `v2.3`, on my fork. Reading the output showed it, and the tag was restored.
  Lesson: check a guard exists before testing that it blocks something.
- **A design that undersold a risk.** It said a rollback would only misread customers with
  blank fields. Running the real v2.6 showed its next save damages them for good, so the
  docs were corrected.

## Assumptions

**The system contains errors, but many of them could be hidden features.** The history
shows rules that look like bugs and were deliberate: the manager PIN went because
"showrooms kept ringing for it". So instead of fixing everything, I documented everything
before acting. Every known bug went into `docs/known-bugs/` with a test of what the app
does today.

I wrote the behaviour tests so we can pair with the business and go through them. If
something is a bug, it goes into a sprint and ships as a minor release. Small releases make
a rollback smoother. Issued invoices are never rewritten, so a wrong one needs a
compensating transaction, which is far easier when only one small change could have caused
it.

For the ticket I assumed the following. The archived `design.md` has the full list.

- 4% comes off the list price, then the salesman discount applies to what is left. The 15%
  limit ignores the fleet discount, because protecting that allowance is the point.
- A customer can be unmarked, which the ticket does not ask for.
- Sales staff will be told to stop giving hand discounts, or fleet customers would get both.

## What I would do next with more time

1. **Call Phil.** The README says "Problems: ask Phil (ext. 214)", and Phil wrote most of
   the code and signed the last release. One call could settle which of the 14 open bugs
   are really hidden features. Then I would pair with the business on the rest, starting
   with the three High ones, and plan them as minor releases.
2. **Prove what is only configured.** At the time of writing, no tag has been through the
   new pipeline. A failing check blocking a merge and the tag protections are also untested.
3. **Make the deploy real.** A release is still a manual copy to a file server, and I only
   checked strict C89 with gcc, not the compiler real releases use.
4. **Run `openspec validate --strict` in CI.** It is manual today, and it caught a spec
   problem in the last archive.
