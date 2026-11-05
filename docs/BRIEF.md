# DealerDesk take-home challenge

## The situation

You've just joined a team that maintains **DealerDesk**, a menu-driven terminal
application written in C. Car dealerships use it every day to manage stock,
customers, quotes and invoices. It has been in production for years and it works.

The problem is changing it. There are no tests, no CI and no reliable build,
and nobody trusts the documentation. Every change is slow and nervous, and
releases are done by hand. The team wants that to stop.

You use AI coding agents every day, and the team is counting on you to show how
they can help on exactly this kind of codebase.

## Your task

1. **Improve how changes get delivered on this codebase.** You decide what
   matters most and how far to take it.
2. **Ship [TICKET-142](TICKET-142.md)** (fleet discount) through whatever you built.

## Ground rules

- Use any AI tools you like (Claude Code, GitHub Copilot, Cursor, or anything
  else). We expect you to.
- Any test framework, build tool or CI provider is fine. GitHub Actions is the
  easiest for us to look at, but it's not required.
- Dealership staff rely on this app as it is. Apart from the new feature, they
  should not notice your changes.
- You have one week. We suggest spending around 6 to 8 hours. We are not
  expecting everything to be done, so choose what to do first.
- Commit as you go. We read the history as well as the final state.
- If the ticket or the code leaves something unclear, make a reasonable call
  and write it down.

## What to send back

A Git repository (a link, or a zip that includes the `.git` folder) containing:

- your changes, with their full commit history
- your agent setup, committed to the repo: instruction or context files
  (`CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `.cursor/rules`,
  and so on), prompts, custom commands or skills, and any scripts, workflows or
  MCP servers you built
- a `NOTES.md` of no more than two pages covering:
  - what you changed, and why you prioritised it that way
  - how you worked with the agent(s), including at least one time it got
    something wrong and how you caught it
  - the assumptions you made
  - what you would do next with more time

## The technical interview

We'll spend about 45 minutes going through your submission together. Be ready
to run things live, walk us through your commits, and talk about the calls you
made.

## Getting started

Start with the README. Good luck, and have fun with it.
