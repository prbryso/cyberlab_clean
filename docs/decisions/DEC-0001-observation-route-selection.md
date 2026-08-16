# Observation Route Selection for Multiple Information Paths

**Decision ID:** DEC-0001 (resolves Q1 in `../architecture/ENGINE_OPEN_QUESTIONS.md`)

**Date:** 2026-08-16

**Question:** When two or more information-bearing relationships connect the same pair of elements, which one should carry an observation, and which should the causal record name?

---

## Context

Systems Studio has two complete authored systems: Password Security and Phishing.
The second exposed an assumption the first could not, which is the usual way
these are found.

**Password Security did not expose it.** No pair of elements in that system is
connected by more than one information-bearing relationship. Every observation
has exactly one possible route, so nothing about how a route is chosen was ever
observable, and the question was never asked.

**Phishing exposed it.** The inbox and the recipient are connected twice, and
both relationships are true statements about the system:

```
inbox ──interactsWith──> recipient
       (the standing arrangement between a person and their mail)

inbox ──sendsDataTo──> recipient
       carriedEventTypeIds: ['message_presented']
       (a particular message reaching a person's attention)
```

Neither is redundant. They say different things, and a model that could only
express one of them would be poorer for it.

Route discovery walks `graph.relationships` in authored order and keeps the
first relationship that reaches a node. So which of these two the engine uses —
and therefore which channel a run's causal record names — currently depends on
the order the two appear in the source file. The Phishing model relies on this
today, with a comment in `phishing_detail.dart` explaining that the ordering is
deliberate and load-bearing.

**Relationship ordering is not a meaningful system property.** It is an artefact
of how a file was typed. Nothing about the system being modelled changes when
two entries in a list swap places, and nothing about the engine's answer should
either.

The principle this rests on:

> A learner should understand the system's behaviour from the model, not from
> implementation details of graph traversal.

The comment currently required in `phishing_detail.dart` is the evidence that
the principle is being violated. A model should not have to document the
engine's traversal in order to be read correctly.

### What systems exposed this?

**Password Security — did not expose.** No meaningful parallel information
paths. Every pair of elements is connected at most once by an
information-bearing relationship, so route selection was never exercised.

**Phishing — exposed.** The `inbox → recipient` pair carries two relationships
with different meanings: an unrestricted two-way interaction, and an
event-scoped surfacing channel. Both are legitimate. The engine had no stated
basis for choosing between them.

Two systems, one instance. This decision is being taken on a single observed
occurrence, deliberately, because the alternative is to let file ordering
accumulate semantic weight across a third system before the question is
settled — see *Future validation* below.

## Problem statement

**Current behaviour.** `StudioObservabilityIndex._routesFrom` performs a
breadth-first search from each source node, marking a node as visited on first
arrival and discarding every subsequent relationship that reaches it. The search
iterates `graph.relationships` in authored order. Event-scoped filtering is
applied afterwards, at lookup, by `routesCarrying`.

Three consequences follow.

**Authors cannot predict the result without knowing engine internals.** Nothing
in the authored model indicates that list position matters. An author who
groups relationships by subsystem, or alphabetises them, or inserts a new one in
a natural-reading place, may change what a run reports without any indication
that they have done so.

**Changing relationship ordering can change explanations.** The causal record's
`channelRelationshipIds` is the audit trail for "how did they come to know
that?" — one of the questions the system exists to answer well. Today that
answer depends on file order, so the same model can give two different
explanations of the same run depending on how it was typed.

**Future domains will contain redundant information paths as a matter of
course.** In the two authored systems, parallel information-bearing edges are a
curiosity found once. In industrial control, medical, autonomous and AI systems
they are normal and frequently deliberate: a sensor on both a fieldbus and a
diagnostic channel; a monitor feeding a bedside display and a central station; a
retrieval system feeding both a model and an evaluation harness. In those
domains redundancy is often the property most worth exploring, not an accident
to be tidied away.

There is also a narrower correctness concern, recorded here because it informed
the decision: route discovery is event-agnostic while filtering is
event-specific. Because discovery prunes before knowing which event it will be
asked about, a filtered relationship discovered first permanently shadows an
unrestricted one to the same node. Any event the filter excludes then has no
route at all, even where the author declared an unrestricted channel saying it
should flow. In Phishing this is currently dormant, because the inbox emits one
event.

## Decision

Systems Studio will:

1. **Preserve awareness that multiple observation routes may exist.** Where
   several routes of equal standing reach the same observer, the engine retains
   them rather than discarding all but one at discovery time. What a system says
   about itself is not thrown away because only one answer is presently
   displayed.

2. **Select a deterministic explanatory route for current learner-facing
   surfaces.** Exactly one route is chosen for each observation, so the causal
   record continues to name a single channel and the observation model continues
   to yield one observation per observer per occurrence. Retention is about what
   the engine knows; selection is about what it currently shows.

3. **Prefer semantically meaningful routes over incidental ordering.** The
   choice is made by a stated rule about the meaning of the relationships
   involved, not by their position in a file.

## Route selection rule (provisional, v1)

Applied in order. The first criterion that distinguishes two candidate routes
decides between them.

1. **Shortest observation distance.** A route that reaches the observer in
   fewer hops is preferred. This is existing behaviour and is unchanged.

2. **Event-specific information carriage.** A relationship whose
   `carriedEventTypeIds` names the event in question is preferred over one that
   carries whatever reaches it. Naming an event is an explicit authorial
   statement about that event; carrying everything is a general statement that
   happens to include it.

   Specificity is binary: does this relationship name this event, or not?
   Ranking by list length or filter narrowness would be more clever and less
   explicable, and is deliberately not part of this rule.

3. **Notification semantics.** A `notifies` relationship is preferred over an
   ordinary channel. Notification sets `viaNotification`, which changes the
   observation basis a learner is shown — being told something is a different
   fact from something having reached you — and where both are available, the
   stronger statement should be the one recorded.

4. **Authored order.** A final deterministic tie-break, so that the engine's
   answer is always stable and reproducible.

**Authored order is not a semantic property of the system.** It appears in this
rule solely to guarantee determinism when every meaningful criterion has been
exhausted. It carries no meaning, confers no intent, and must never be relied
upon by an authored model to produce a particular result. A model that depends
on the order of its relationship list is a model with an unstated dependency,
and that dependency is a defect in the model.

## Alternatives considered

**Alternative A — preserve authored order.** Keep current behaviour, and
document that ordering is significant.

**Alternative B — explicit author priority.** Add a priority or ordering field
to `StudioRelationship`, and require authors to disambiguate parallel paths
themselves.

**Alternative C — discard alternate paths.** Choose one route by rule at
discovery time and discard the others permanently, keeping the index's present
shape.

## Why alternatives were rejected

**Alternative A — rejected.** It makes the engine's behaviour depend on a
property the system does not have. An author cannot predict the causal record
without knowing that the search marks nodes visited on first arrival and
iterates in list order, which is knowledge about the implementation rather than
about the model. It is fragile as systems grow: the more relationships a system
has, the more likely an innocuous edit changes an explanation. And it fails on
contact with any domain where redundant paths are normal, which the next system
may well be.

**Alternative B — rejected.** It is explicit, which is its one merit, but it
relocates the problem onto every author rather than solving it. Priority is a
noun that exists to serve an engine need, not to describe anything about the
system being modelled — `AUTHORING_SYSTEMS.md` cautions against creating a
concept because an implementation wants one. It burdens every author with a
field that matters in the small minority of models that have parallel paths, and
it fails silently when set wrongly.

**Alternative C — rejected.** It would fix predictability while still discarding
information the model contains. Once alternate routes are dropped at discovery
they cannot be recovered, which forecloses any later ability to say that
information reaches someone by more than one path. In safety-critical domains
that redundancy is frequently the system property most worth exploring, and an
architecture that destroys it before anyone asks has made a choice it cannot
revisit.

## Consequences

**Positive.**

- Causal explanations become predictable from the model alone. The same system
  gives the same account of the same run regardless of how its source is
  arranged.
- The rule generalises to domains where redundant information paths are normal
  rather than exceptional.
- Accidental model behaviour is reduced: an author reordering, regrouping or
  inserting relationships no longer silently changes what a run reports.
- System meaning is preserved. A model that says information travels two ways
  keeps saying so, whether or not the current interface displays it.

**Negative, and stated plainly.**

- Observation indexing becomes more complex. The index must retain candidate
  routes and apply a tie-break at lookup rather than resolving everything once
  during discovery.
- A future interface may eventually need to display multiple valid paths, and
  deciding how to present that without cluttering the causal record is work this
  decision creates rather than avoids.
- The rule itself is a thing authors must learn. It is one short paragraph
  rather than a per-model field, but it is not nothing.
- Criteria 2 and 3 have not been exercised together by any authored system.
  Their relative order is a judgement made in advance of evidence.

## Systems affected

| System | Change required | Status |
|---|---|---|
| Password Security | None. No pair of elements is connected by more than one information-bearing relationship, so no route selection occurs. | not needed |
| Phishing | None to authored content. Under this rule the surfacing channel still wins for `message_presented`, which is what happens today. The comment in `phishing_detail.dart` explaining that authored order is deliberate becomes unnecessary and should be removed when the rule is implemented. | pending implementation |

No existing test is expected to change. A decision that fixes an unstated
dependency while altering no observable behaviour in either authored system is
about as low-risk as this class of change gets — which is itself part of the
argument for taking it now rather than after a third system has been authored
against the old behaviour.

## Future validation

This decision is taken on one observed instance. It should be treated as
provisional until a system exercises it properly, and revisited — with a
superseding record — if any of the following does not behave as the rule
predicts.

Future systems should specifically test:

- **Redundant communication paths**, where the same information genuinely
  reaches an element by two independent routes and the redundancy is a designed
  property rather than an accident.
- **Multiple observers** of the same occurrence reached by different channels,
  where the causal record must name a different relationship for each.
- **Non-security domains**, since both systems that informed this decision have
  an adversary, and neither has tested whether the rule reads naturally without
  one.
- **Autonomous systems**, where sensing paths commonly fan out to perception,
  logging and diagnostics simultaneously.
- **AI systems**, where a retrieval or generation component typically feeds both
  a consumer and an evaluation harness, and where which of those the causal
  record names materially changes the account given.

The specific thing to watch is criterion 2 against criterion 3: a `notifies`
relationship and an event-filtered channel both carrying the same event. No
authored system has produced that case, and their relative order is the least
evidenced part of this rule.

---

*If this record is later superseded, append a line at the top of the file —
`**Superseded by DEC-NNNN, YYYY-MM-DD.**` — and leave everything else intact.*
