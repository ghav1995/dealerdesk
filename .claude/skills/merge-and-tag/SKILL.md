---
name: merge-and-tag
description: Merge a DealerDesk pull request and create its version tag with a full description. Use this every time a pull request is merged, whenever someone says merge, land, ship, release, finish or complete a PR, or asks to create the version or tag after a merge, even if they do not mention tags. Also use it to tag a pull request that was merged without one. Do not merge any other way, because a version with no tag never starts the CD pipeline.
---

# Merge and tag

The version tag is what starts CD, and every stage deploys that tag. A tag cannot be
moved once it is pushed, so the description has to be right the first time. That is
why you write it before merging and the script checks it before touching anything.

Only merge when someone has asked you to. A person approves each CD stage, so never
approve one yourself.

Run these from a bash shell in the repository root.

## 1. Check the pull request

    bash .claude/skills/merge-and-tag/scripts/merge-and-tag.sh check <pr>

This changes nothing. It stops if the pull request is not ready, for example if the
`test` check has not passed or the branch is behind `master`. Fix the cause. Do not
look for another way to merge.

## 2. Write the description

Write it for someone deciding whether to deploy or roll back this version, who has
not read the pull request. Work from evidence, in this order:

- `git log --no-merges <previous-tag>..<pr-head>`, including commit bodies
- `git diff --stat <previous-tag> <pr-head>`, then the diff of anything staff could see
- changes under `app/tests/integration/expected/`, because a changed baseline is a
  behaviour change that the description must explain
- the pull request body, and `design.md` in any OpenSpec change it includes

Save it to a temporary file outside the repository, using exactly this structure. The
script refuses anything else.

    DealerDesk vX.Y: <what this version does, in one line>

    ## Summary
    What changed and why.

    ## Staff-visible changes
    Screens, prompts and totals that differ.

    ## Pricing and invoices
    Any change to how an amount is calculated, stored or shown.

    ## Data files and rollback
    Whether files stay compatible both ways, and anything an older binary would lose.

    ## Tests
    What was added, and what the integration baseline did.

    ## Delivery and documentation
    Workflows, specs, README and agent rules.

    ## Not in this version
    Known gaps and work left for later.

Fill in every section. If nothing changed, say so and give the evidence, because an
explicit "no change" is what the reader came for:

    ## Pricing and invoices
    No change. `app/src/calc.c` is byte-identical to v2.4 and the baseline did not move.

Leave out the commit list and the file counts. The script adds those itself, so they
cannot be mistyped.

## 3. Merge and tag

    bash .claude/skills/merge-and-tag/scripts/merge-and-tag.sh run <pr> <notes-file>

The script checks the pull request and the description, merges with a merge commit,
then creates the annotated tag from the merge commit on `master` and pushes it.

If it fails after the merge, fix the cause and run the same command again. It sees
that the pull request is merged and goes straight to tagging.

If a permission check blocks the script, stop and tell the user what it was doing. Do
not reach the same result another way.

## 4. Report

Tell the user the merge commit, the tag and the CD link, and show them the
description. The first CD stage is now waiting for their approval.
