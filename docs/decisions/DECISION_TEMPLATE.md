# Decision Record Template

Copy this file to `docs/decisions/DEC-NNNN-short-slug.md`, fill every field, and
delete the guidance in italics.

Every field is required. A field with nothing useful to say is itself a signal —
usually that the decision is not ready, or that it is smaller than a decision
record.

---

**Decision ID:** DEC-NNNN

*Sequential, zero-padded to four digits, never reused. If this resolves an entry
in `ENGINE_OPEN_QUESTIONS.md`, name it here too: `DEC-0003 (resolves Q1)`.*

**Date:** YYYY-MM-DD

*The date the decision was made, not the date the code landed.*

**Question:**

*One sentence, phrased as a question, in the same words the question was asked
in. If it resolves an open question, this should match that entry's wording so
the two are searchable together. A question that takes a paragraph to state is
usually two questions.*

---

## Context

*What is true today, and why this is being decided now rather than later.
Include the current behaviour precisely — file and line where it helps — so a
reader in a year can tell what changed without archaeology.*

### What systems exposed this?

*Name the authored systems, and what specifically in them raised the question.
This field exists because a decision made from one system is weaker evidence
than a decision made from two, and the record should make that visible rather
than hide it behind confident prose.*

*If only one system exposed it, say so. If a pattern involved has a single
confirmed instance, say that too — `AUTHORING_SYSTEMS.md` §13 tracks instance
counts.*

## Options considered

*At least two, each with its rationale and its cost. "Do nothing" and "leave it
as it is" are legitimate options and should be listed when they were genuinely
on the table.*

**A. ...** — *rationale. Cost.*

**B. ...** — *rationale. Cost.*

## Decision

*Which option, stated plainly. No hedging. If the decision is conditional
("B now, revisit if X"), state the condition precisely enough that someone can
tell whether it has occurred.*

## Why alternatives were rejected

*One paragraph per rejected option, addressing it on its merits. An alternative
dismissed without a reason will be proposed again in six months by someone who
cannot tell it was already considered.*

*If an option was rejected on a principle rather than a trade-off — "this would
make an element a wire", "this would turn exploration into assessment" — name
the principle.*

## Consequences

*What becomes true, including the parts that are worse. A record listing only
benefits is a rationalisation, not a decision.*

*Cover: what the engine now does; what authors must now do differently; what
becomes harder; what this forecloses.*

## Systems affected

*Every authored system that must change, plus any that were checked and found
not to need changing — the second list is as useful as the first. Note whether
each change has been made, and where the tests that hold it live.*

| System | Change required | Status |
|---|---|---|
| Password Security | ... | done / not needed / pending |
| Phishing | ... | done / not needed / pending |

---

*If this record is later superseded, append a line at the top of the file —
`**Superseded by DEC-NNNN, YYYY-MM-DD.**` — and leave everything else intact.
Records are not edited after the fact and are not deleted; the reasoning that
turned out to be wrong is the most useful part of the archive.*
