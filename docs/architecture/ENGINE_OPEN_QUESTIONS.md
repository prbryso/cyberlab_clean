# Engine Open Questions

Unresolved questions about engine semantics, recorded so that they are decided
deliberately rather than settled by accident in whichever phase happens to hit
them first.

Each entry states the question, what exposed it, what the engine does today,
the options, and what would force a decision. None of them is a bug report —
these are places where the current behaviour is defensible but was never chosen.

**Provisional leans are not decisions.** Each entry ends with one because having
a working position is better than having none, but a lean can be reversed by
whoever picks the question up, without ceremony.

**When a question is settled**, copy `../decisions/DECISION_TEMPLATE.md` to
`../decisions/DEC-NNNN-short-slug.md`, fill it in, then **delete the entry from
this file** and add a line to the *Resolved* table at the bottom. This file
should only ever contain open questions. The full convention is in
[`../decisions/README.md`](../decisions/README.md).

---

## Q2. Presence vs involvement

**Status: open. No forcing event yet.**

### The question

Should the engine be able to represent an actor who is *present* but has not yet
been reached by anything?

### What exposed it

Phishing's recipient. Relevance is defined purely as "observed something or
performed an action" (`simulation_run.dart:229`), which is a good rule and
should not be weakened. But it means a person who is simply *there* — a
recipient sitting at their desk before any message arrives — cannot be modelled
as there. They can only be modelled as having been reached.

The surfacing pattern converts presence into an occurrence, which works and is
truthful. The open question is whether that is the right permanent answer or
a workaround that will look strained in a system where presence genuinely
precedes any event.

### What the engine does today

`SimulationRun` seeds `_relevantActors` from `scenario.initialActors` and adds
observers as observations arrive. There is exactly one notion — relevance — and
it means involvement.

### Options

- **Leave it.** Presence-without-involvement may simply be uninteresting: an
  actor nothing has happened to has nothing to do. Surfacing handles the cases
  that matter.
- **Add a distinct notion of standing presence,** separate from involvement,
  which the UI could render differently ("here, but nothing has reached them").
  Risk: a second concept adjacent to relevance, and the engine has been
  deliberately parsimonious about adding nouns.

### What would force a decision

A system where an actor must be visibly present from the start *and* it would be
false to author an occurrence that reaches them. Phishing did not qualify —
surfacing is genuinely true there, not a workaround.

### Provisional lean

Leave it. Do not create a concept because we have found a new noun. Revisit if
a third system strains.

---

## Q3. `maximumDistance` as a per-system or per-relationship property

**Status: open, low priority.**

### The question

Is one hop always right, or is it right for these two systems?

### What exposed it

Nothing yet — this is a pre-emptive entry. Phishing appeared to need distance 2
and turned out not to: the correct repair was an authored surfacing behaviour,
not a longer reach. That is one data point in favour of the current default, not
a proof.

### What the engine does today

`maximumDistance` is a constructor parameter defaulting to `1`, set once per
index. Beyond hop 1 an observation degrades to `existenceOnly` — a mechanism
that exists but that no authored content currently reaches, since nothing is
built at distance greater than 1.

### The tension

The `existenceOnly` fidelity level is currently unexercised. Either a future
system will need it, or it is speculative machinery that should be removed. Both
outcomes are informative and neither is currently known.

### What would force a decision

A system where an element genuinely does relay — a network, a supply chain, a
rumour — where "an element is not a wire" is the wrong claim rather than a
useful constraint.

### Provisional lean

Hold. Resist raising the default globally under any circumstances; if a relaying
system arrives, the question is whether *that system* configures a longer reach,
not whether the default changes.

---

## Q4. `declaredBy` has no runtime role

**Status: open, low priority. Documentation may be sufficient.**

### The question

Should the engine do anything with `StudioEventType.declaredBy`?

### What exposed it

Phishing is the first system where `declaredBy` and the runtime source disagree
— `link_opened` is declared by the recipient and sourced at `link_target`;
`message_reported` is declared by the recipient and sourced at
`reporting_channel`. Both are correct. In Password Security the two always
coincide, so nobody had to think about it.

### What the engine does today

`declaredBy` is authorial metadata. Observation, propagation, and the causal
record all use the runtime source (`action.target` or `behavior.owner`). Nothing
reads `declaredBy` at runtime.

### The risk

An author reasoning about who will observe an event by looking at `declaredBy`
will be wrong precisely in the interesting cases. That is a documentation
problem today (`AUTHORING_SYSTEMS.md` §5 addresses it) and could become a
validator problem later.

### Why a validator rule is *not* proposed

A rule flagging divergence would fire on Phishing's two correct events. There is
no static way to distinguish intentional divergence from a mistake, because both
look identical.

### Provisional lean

Documentation only. Revisit only if a real defect is ever traced to this.

---

## Q5. Whether surfacing should be permitted to write state

**Status: open, pending a third system.**

### The question

`AUTHORING_SYSTEMS.md` §6 requires a surfacing behaviour to have no outcomes and
no effects. Is that rule too strict?

### What exposed it

The Phishing Phase 2.5 design decision. Writing a `Presented` state value was
considered and rejected: it would duplicate `message.delivery`, allow the two to
drift, and invite gating the recipient's actions on presentation as well as
delivery — which would assert that an unseen message cannot be acted on.

That reasoning is sound for Phishing. It has not been tested anywhere else.

### What would force a decision

A system that needs surfacing *and* has a genuine reason for the surface to
record something — a queue depth, a display that can be full, an interface that
can be occupied. If that arrives, relax the rule deliberately rather than
working around it.

### Provisional lean

Keep the rule until a system breaks it, then record why.

---

## Resolved

*Questions removed from this file, with the record that settled them.*

| Question | Decision | Date |
|---|---|---|
| Q1. Route selection: specificity vs authored order | [`DEC-0001-observation-route-selection.md`](../decisions/DEC-0001-observation-route-selection.md) | 2026-08-16 |

### Q1 — resolution summary

- Multiple equal-distance observation routes are **retained** rather than
  discarded at discovery.
- Learner-facing surfaces **select a single deterministic route**, so one
  observation per observer per occurrence still results.
- Selection prefers **semantic meaning over authored order**.
- **Authored ordering is only a final tie-break**, and is not a semantic
  property of a system.

**Still to be validated.** The rule ranks event-specific carriage above
notification semantics. That ordering is a judgement made in advance of
evidence: no authored system has produced a case where a `notifies`
relationship and an event-filtered channel both carry the same event, so the
relative order of those two criteria is **not proven** and remains future
validation. See the *Future validation* section of DEC-0001.
