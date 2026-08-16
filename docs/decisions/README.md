# Decision Records

Engine and authoring decisions, recorded once and not revised.

## What belongs here

A decision record is written when a question about **engine semantics or
authoring rules** is settled — where the answer was not obvious, where a
reasonable person could have chosen otherwise, and where a future reader would
otherwise have to reconstruct the reasoning from code.

Most entries here will resolve a question from
[`../architecture/ENGINE_OPEN_QUESTIONS.md`](../architecture/ENGINE_OPEN_QUESTIONS.md).
That is the intended pipeline:

```
a system exposes something
        |
        v
ENGINE_OPEN_QUESTIONS.md      question recorded, options costed, not decided
        |
        v
DEC-NNNN                      decided, with reasoning and consequences
        |
        v
AUTHORING_SYSTEMS.md          the rule authors follow, if the decision changes one
```

**What does not belong here.** Implementation notes, phase reports, bug fixes,
and anything where there was only ever one sensible answer. If writing the
"Options considered" section is difficult because there were none, it was not a
decision.

## Naming

```
DEC-NNNN-short-slug.md        e.g. DEC-0001-route-selection-specificity.md
```

Sequential, zero-padded to four digits, never reused — a gap in the sequence is
better than an ID that means two things.

`DEC-` rather than `ADR-` is deliberate. `docs/architecture/` already reserves
`ADR-NNNN` for architecture decision records about components and their
boundaries. These are decisions about engine semantics and authoring rules,
which are a different kind of question, and keeping the prefixes distinct means
neither sequence has to know about the other.

## Lifecycle

1. A system exposes a question. It goes into `ENGINE_OPEN_QUESTIONS.md` with a
   *provisional lean*, not a decision. Leans are cheap and revisable; the entry
   exists so the question is decided deliberately rather than settled by
   whichever phase happens to hit it first.
2. Something forces the decision — usually the "What would force a decision"
   condition in that entry.
3. Copy `DECISION_TEMPLATE.md`, fill every field, commit.
4. **Remove the entry from `ENGINE_OPEN_QUESTIONS.md`**, replacing it with a
   one-line pointer under a `Resolved` heading. The open-questions file should
   only ever contain open questions.
5. If the decision changes what an author must do, update
   [`../architecture/AUTHORING_SYSTEMS.md`](../architecture/AUTHORING_SYSTEMS.md)
   and reference the record from there.

## Records are not edited

Once committed, a record is not revised. If a decision is reversed or refined,
write a new one and append a single line to the top of the old one:

```
**Superseded by DEC-NNNN, YYYY-MM-DD.**
```

The reasoning that turned out to be wrong is the most useful part of the
archive, and editing it away removes the only evidence of how the thinking
changed.

## Index

| ID | Date | Question | Resolves |
|---|---|---|---|
| [DEC-0001](DEC-0001-observation-route-selection.md) | 2026-08-16 | When several information-bearing relationships connect the same pair of elements, which carries an observation? | Q1 |
