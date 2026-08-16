# Authoring Systems

*A practitioner's guide to writing a `StudioSystemDetail`.*

This is not an SSAS component document. It describes no component and proposes
no design. It records what two authored systems — Password Security and
Phishing — taught us about writing a third, so that the next author does not
rediscover it by watching tests fail.

Everything here is derived from content that exists. Where a pattern has been
seen once, this document says so. Where it has been seen twice in independent
systems, it says that too, because the difference matters: a shape observed
once is an idiom that worked, and a shape observed twice is a pattern you can
plan around.

---

## 1. Purpose

Authoring a system in Systems Studio is not writing a lesson. It is making a
set of claims about how something works, and then letting a run demonstrate
them. The engine will not narrate, grade, sequence, or recommend. Whatever the
learner comes to understand, they come to understand by exploring the
consequences of what you authored.

That puts unusual weight on the model being *true*. A lesson can be vague and
still be useful. A model that is vague produces runs that are wrong in ways
nobody notices.

## 2. Background — what exposed the need for this document

Password Security was authored first and, without anyone intending it, chose
the easy shape at almost every decision point. Phishing was authored second and
chose differently — not deliberately, but because the subject matter demanded
it. The gap between them is where every lesson below came from.

The single most consequential difference: in Password Security, `login_interface`
is simultaneously the surface a person looks at, the target of the attacker's
action, and the source of the resulting event. Three roles, one node. Phishing
separates them — the gateway decides, the inbox surfaces, the link target and
reporting channel receive actions — and that separation is what exposed most of
what follows.

A note on how these lessons were found: several of them appeared as failing
tests that looked like test bugs and turned out to be model defects, or as
model defects that turned out to be stale test premises. Distinguishing the two
is most of the work. When a test fails, the first question is not "how do I
make this pass" but "which of these two things is lying."

---

## 3. Element vs wire

**An element is not a wire.**

`StudioObservabilityIndex.maximumDistance` defaults to `1`. Information travels
one relationship hop from where an occurrence happened, and no further. A
component that sits between a source and an observer does not conduct the
occurrence onward. It hears about it, and that is all.

This is a deliberate constraint, not a limitation waiting to be lifted. Raising
`maximumDistance` globally would make every element in every system a relay,
and would hand distant observers `existenceOnly` fidelity — a vague awareness
of something they may have no business knowing about at all. It would also
change what every actor in every already-authored system can observe, silently.

**What to do instead.** If information needs to travel further than one hop, an
element in the middle must *produce its own occurrence*. It does not forward;
it reacts and emits. See §6 (surfacing) and §9 (notification variants), which
are both applications of this one rule.

**How you will discover you have violated it.** An actor who obviously ought to
be involved never becomes relevant, and never gets offered the actions you
authored for them. If you find yourself seeding an actor in a scenario so that
your tests can proceed, stop: you have probably found a missing occurrence, not
a missing scenario.

---

## 4. Observation vs knowledge

The engine models **observation**: whether an occurrence reached an element,
through what channel, at what distance, and with what fidelity. It deliberately
does not model **knowledge**, **belief**, **awareness**, or **understanding**.

This distinction is load-bearing and easy to erode. Both authored systems have
rejected a "belief" state variable at least once, and Phishing has a test that
asserts no outcome anywhere writes one.

The reason is not squeamishness. A model that records what a person believes
has to decide what they *should* believe, and at that point the exploration
environment has quietly become an assessment system. Phishing works precisely
because a reasonable person can go either way; a model that graded the choice
would be teaching something else.

**Practical consequences:**

- Do not author state variables named for mental states — `belief`, `aware`,
  `suspects`, `trusts`, `understands`.
- Do not gate an action on whether an actor has "understood" something.
- State variables describe the *system*: what has been delivered, what
  filtering is in force, what classification something has been given, whether
  access is still confined to its owner. `message.classification` is legitimate
  because it records what the *system* has been told, not what a person thinks.

**The related trap:** state and occurrence are also different things. See §10.

---

## 5. `declaredBy` vs runtime source

`StudioEventType.declaredBy` is **authorial attribution** — whose event this
conceptually is. It has no runtime role.

The **runtime source** of an event is determined by mechanism:

| Emitted by | `event.source` | `event.participants` |
|---|---|---|
| An action | `action.target` | `[action.initiator, action.target]` |
| A behaviour | `behavior.owner` | `[behavior.owner]` |

These two readings can disagree, and that is not an error.

In Password Security they never disagree, which is why the distinction went
unnoticed for nine phases. In Phishing they disagree twice, correctly:

- `link_opened` is `declaredBy: recipient` — it is the person's act — but is
  sourced at `link_target`, because that is where it happens.
- `message_reported` is `declaredBy: recipient` but sourced at
  `reporting_channel`, which is what puts it one hop from the security team.

**Why you must hold both in mind.** Observation is computed from the runtime
source, never from `declaredBy`. If you reason about who will observe an event
by looking at `declaredBy`, you will be wrong exactly in the interesting cases.
When an action's event needs to reach someone, the question is *what is the
action's target*, because that is where the occurrence lands.

**There is no validator rule for this and should not be**, because a rule
flagging divergence would fire on correct content. Read the table above
instead.

---

## 6. The surfacing pattern

**Status: one confirmed instance (Phishing). Needs a second system.**

*Shape.* An element whose job is to put information in front of a person emits
its own event when it does so. The person observes that event, not the upstream
decision that produced the information.

```
message_delivered      (mail_gateway decides)
        |
        v
inbox.present_message  (behaviour: no branch, no effect)
        |
        v
message_presented      (sourced at inbox)
        |
        v
recipient becomes relevant, and can act
```

*Why it exists.* The recipient is two hops from the gateway. Delivery could
never reach them (§3), so nothing put the message in front of the person it was
addressed to. The alternatives were worse: lengthening observation violates §3
globally, and a direct gateway→recipient edge is structurally false, because
the gateway never hands anything to a person.

*What it buys beyond reachability.* It makes expressible a fact the model
previously could not state at all — **a message can be delivered and not yet
seen**. Unread mail harms nobody. Delivery is a property of the mail system;
surfacing is a property of a person's attention. A model that treats them as
one event cannot distinguish them.

*Rules for authoring it.*

- The surfacing behaviour has **no outcomes and no effects**. A surface does not
  judge what it is showing. If it branches, it is deciding, and it is not a
  surface.
- Model surfacing as an **event, not state**. A `Presented` state value would
  invite gating the person's actions on it, which asserts that a message nobody
  has looked at cannot be acted on — a different and untrue claim. It would
  also duplicate the delivery variable and let the two drift apart.
- **Do not gate the person's actions on the surfacing event.** In Phishing,
  `open_link` and `report_message` remain gated on `message.delivery ==
  Delivered`. Availability of an action and awareness of information are
  separate concepts, and the model is more honest for keeping them apart.
- The explanation must describe an **occurrence, not a result**. "The message
  appeared in the recipient's view. What happens next depends on what they
  decide to do." No success, failure, safety, danger, or *should*.

*When you need it.* Any time an element that decides and an element that
displays are different nodes. Password Security did not need it because those
two roles were one node — which is the degenerate case, not a counterexample.

---

## 7. The decision actor pattern

**Status: one confirmed instance (Phishing recipient). Needs a second system.**

*Shape.* An actor with two or more actions available **at the same time**,
under **identical preconditions**, with nothing in the model marking either as
preferred, correct, recommended, or safer.

In Phishing, `recipient.open_link` and `recipient.report_message` share the
precondition `message.delivery == Delivered`. Both are offered together. The
model says nothing about which to choose.

*Why the symmetry is the point.* Phishing works because a reasonable person can
go either way. If the model graded the choice — through wording, ordering,
availability, or an outcome that calls one of them a mistake — it would be
teaching compliance rather than showing a system.

*Rules for authoring it.*

- Identical preconditions. If one action is available before the other, you
  have encoded a preference whether you meant to or not.
- No verdict vocabulary anywhere in either action's `explanation` or
  `guidingQuestion`. Phishing has a test that scans for `success`, `failed`,
  `correct`, `should`, `safe`, `danger` and similar.
- Consequences may differ enormously. That is not grading — that is the system.
  `open_link` compromises the account and tells the attacker; `report_message`
  raises a classification and reaches the security team. Both explanations
  describe what happened, neither describes what ought to have happened.
- No automatic behaviour may resolve the choice. Something *may* be triggered by
  the state that makes both available — surfacing is — but it must change no
  state, or it will move one of the preconditions.

*Contrast.* Password Security has no decision actor. Its `user` has no authored
actions at all; the attacker and administrator have one each. Its human is a
witness. Phishing's human is a decider, and that is the whole difference.

---

## 8. The blind spot pattern

**Status: two confirmed instances (Password Security, Phishing). Confirmed.**

*Shape.* A fact that matters enormously to one party reaches somebody else, and
**nothing in the architecture carries it to the party who needs it**. The
absence is authored deliberately, documented on the relationship that does
exist, and asserted by a test.

Both systems have one, and both put the asymmetry at the centre of the model:

- **Phishing.** `link_target_reports_to_attacker` carries
  `credentials_submitted` to the attacker. Nothing carries the same fact to
  anyone defending the account. The attacker learns the attempt worked; the
  defenders do not.
- **Password Security.** The security team's counterpart, the administrator,
  learns nothing except through `security_monitoring`. A compromise the
  monitoring does not raise an alert about is a compromise nobody hears.

*Rules for authoring it.*

- A blind spot must be **structural**, not incidental. It exists because no edge
  connects those elements, and that is a claim about the system.
- **Document it on the edge that does exist.** Phishing's
  `link_target_reports_to_attacker` carries the comment "Nothing carries the
  same fact to anyone defending the account." A reader of the model should not
  have to notice an absence unaided.
- **Assert it in a test**, positively and negatively:
  `expect(observersOf(run, 'credentials_submitted'), contains('attacker'))` and
  `isNot(contains('security_team'))`. An absence that no test protects will be
  closed accidentally by a later phase.
- Resist the urge to fix it. The blind spot is usually the most interesting
  thing in the system.

---

## 9. Notification variants

**Status: two confirmed instances, of two distinct variants. Confirmed as a
general shape.**

Both systems answer the question "how does the responsible party find out?" and
answer it differently. The shape recurs; the mechanism does not.

**Variant A — machine notification (Password Security).**
`security_monitoring` observes the authentication engine, and on
`authentication_failed` raises **its own** event, `security_alert_raised`, which
reaches the administrator through a `notifies` relationship filtered to that
event type. Monitoring does not relay the failure. It reacts to it and produces
something new.

This is the same mechanic as surfacing (§6) — an element in the middle emitting
rather than conducting — applied to a different problem. Together they are the
general answer to §3.

**Variant B — human notification (Phishing).**
`reporting_channel` has no behaviour and emits nothing of its own. It is the
target of `recipient.report_message`, which is what sources the event there,
one hop from the security team via `reporting_notifies_security_team`.

**The difference is the system fact worth exploring.** In Password Security,
being informed is a property of the architecture — it happens whether or not
anyone chooses to act. In Phishing, being informed is contingent on a human
decision, and in the branch where nobody reports, the security team never
learns anything at all. Neither variant is better. Which one a system has is
one of the more revealing things about it.

*Rules for authoring either.*

- Use `notifies` for the final hop to the responsible party. It sets
  `viaNotification`, which the observation model distinguishes from an ordinary
  channel.
- Filter that hop with `carriedEventTypeIds` once §11 applies, so the
  responsible party receives the alert and not the ambient traffic.
- For Variant A, the monitoring element **must emit its own event type**. If you
  find yourself wanting the administrator to observe `authentication_failed`
  directly, you are trying to make monitoring a wire.

---

## 10. Scenario starting facts vs runtime changes

Two different concepts, deliberately kept apart, and the most common source of
confusion in the situation surfaces.

**`StudioScenario`** establishes a *starting situation*: `initialActors` and
`initialStateOverrides`. It says what was already true when the exploration
began. A scenario is not a script, a level, a difficulty setting, or a sequence.
It has no steps and prescribes no path.

**`StudioSituationSnapshot.differences`** compares **current state against the
scenario's starting state**. It answers "what has changed since this began?" —
which is what a learner needs to orient themselves.

**`StudioOverlayStateSummary`** is a *different concept* and must not be
conflated with it. It collapses the *history* of a variable across a run —
every value it passed through — for the graph overlay. `differences` is
two-point; the overlay summary is a trajectory.

*Rules.*

- Facts a scenario establishes are **starting facts**, and should be surfaced to
  the learner as such. They are not consequences and should never be presented
  as things that happened during the run.
- A scenario names initial actors because they were already present, not
  because they are important. Do not use `initialActors` to make an actor
  prominent — that is a recommendation in disguise. Use it when their presence
  is a genuine premise of the situation.
- **If you are seeding an actor so that a run will work, you have a modelling
  gap, not a scenario.** This is exactly what Phishing's Phase 2 tests did, with
  an explanatory comment, until the surfacing behaviour made it unnecessary.
  The comment was the honest move; the surfacing behaviour was the fix.
- Every authored system must work with **zero scenarios**. The implicit default
  (`StudioScenario.implicit`) is equivalent to current behaviour, and a system
  that only makes sense under an authored scenario is under-modelled.

---

## 11. Event-scoped information flow

Semantics, locked, so that authors do not have to infer them:

- `carriedEventTypeIds == null` means **unrestricted** — the channel carries
  whatever reaches it.
- An **empty list** means the channel carries nothing. That is a legitimate
  statement and indistinguishable from having meant to list something, so the
  validator raises a warning.
- **Every hop** of a multi-hop route must permit the event. One restriction
  anywhere on the path stops it.
- A filtered event produces **no observation** through that route. It does not
  degrade to `existenceOnly`. Filtering is a statement that the information does
  not travel here, not that it arrives vaguely.
- A filter on a relationship whose type carries no information at all
  (`controls`, `threatens`, containment) is an **error** — there is nothing to
  narrow, and the declaration would read as meaningful while doing nothing.

Information flow by relationship type, for reference:

| Types | Flow |
|---|---|
| `interactsWith`, `communicatesWith` | both directions |
| `sendsDataTo`, `sendsCommandTo`, `notifies` | forward only |
| `monitors`, `detects` | backward only |
| everything else, including `controls` and `threatens` | none |

**Parallel channels.** Multiple relationships may connect the same elements.
When several routes can carry an event, the engine selects the semantically
most appropriate route rather than relying on authored order. Broadly: the
shortest route wins; between routes of equal length, one that names the event
in its `carriedEventTypeIds` is preferred over one that carries whatever
reaches it.

Author both relationships when both are true. Phishing's inbox and recipient
are connected twice — a standing two-way interaction, and an event-scoped
surfacing channel — and neither is redundant.

**Authored order is not a system behaviour.** The position of a relationship in
a list says nothing about the system, and a model must not depend on it. See
[`../decisions/DEC-0001-observation-route-selection.md`](../decisions/DEC-0001-observation-route-selection.md).

---

## 12. Facets: three states, not two

`StudioFacetStatus` is tri-state: `known`, `notApplicable`, `unknown`. The
accessor is `.value` (nullable), not `.values`.

`notApplicable` is not a lesser `unknown`. "This element senses nothing" is a
claim about the system; "we have not said what this element senses" is a gap in
the authoring. Phishing asserts the difference explicitly for `message`,
`corporate_account`, and `inbox` — a message does nothing and wants nothing, and
saying so is more useful than leaving it blank.

Use `notApplicable` freely. It is one of the few places the model can say
something confident about an absence.

---

## 13. What is confirmed, and what is not

Two authored systems is a small sample. This table is the honest state of the
evidence, and should be updated as a third system lands.

| Pattern | Instances | Status |
|---|---|---|
| Blind spot (§8) | 2 — PS and Phishing | **Confirmed.** Both asserted by tests. |
| Notification of the responsible party (§9) | 2, in two distinct variants | **Confirmed as a shape.** The variants are the interesting part. |
| Monitoring, Variant A specifically (§9) | 1 — PS `security_monitoring` | Single instance. Strong idiom, not yet recurring. |
| Surfacing (§6) | 1 — Phishing `inbox.present_message` | Single instance. Confirmed as *necessary*; not yet as *recurring*. PS has the degenerate fused case. |
| Decision actor (§7) | 1 — Phishing recipient | Single instance. No PS actor ever has two simultaneous choices. |
| `declaredBy` diverging from runtime source (§5) | 1 system, 2 events | Single system. |

**What a third system should be chosen to test.** Ideally one that is neither a
credential system nor a message system, and that has: a human who decides
between more than two options; a responsible party informed by a third
mechanism; and at least one element that both surfaces and decides, to find out
whether §6 holds when the roles are partially fused rather than fully separate
or fully merged.

**What would falsify a pattern here.** If a third system needs surfacing but
cannot express it without the surfacing element also changing state, §6's
"no effects" rule is too strict and should be relaxed rather than worked around.
If a third system has a decision actor whose options are genuinely asymmetric in
availability, §7 needs a weaker formulation. Write down which of these happens.

---

## 14. Boundaries — what authoring does *not* do

Stated explicitly, because the pull in the other direction is constant.

An authored system does **not**:

- score, grade, or evaluate a learner's choice;
- prescribe a next step, a sequence, or a progress order;
- mark any actor, action, or path as correct, recommended, or safer;
- select an actor for the learner;
- assert what a person believes, understands, or should have noticed;
- narrate what the learner is supposed to conclude.

An authored system **does**:

- make claims about structure, which the architecture graph renders;
- make claims about consequence, which a run demonstrates;
- make claims about who can tell what, which the observation model enforces;
- say what it deliberately does not model, and why;
- leave the conclusion to the person exploring it.

The engine will not enforce most of this. It is the author's job.
