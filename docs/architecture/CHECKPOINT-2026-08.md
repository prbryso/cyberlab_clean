# Architecture Checkpoint — August 2026

*State of Systems Studio after two complete authored systems.*

This is a snapshot, not a plan. It records what exists, what is settled, what is
merely exercised once, and what is not yet verified at all — so that the next
piece of work starts from an accurate picture rather than from memory.

It changes no behaviour and proposes no changes.

**Read this first if you are returning to the project after a break, or picking
it up for the first time.** `docs/README.md` is still the default Flutter
scaffold and indexes nothing, so this document is currently the closest thing to
an entry point.

---

## 1. Where things stand

Two systems are authored, registered, and reachable through one generic shell.
Neither required an engine change to author, which is the strongest single
signal in this document.

| | Password Security | Phishing |
|---|---|---|
| Actors | 3 | 3 |
| Assets | 3 | 2 |
| Components | 7 | 4 |
| State variables | 7 | 5 |
| Event types | 6 | 9 |
| Actions | 2 | 5 |
| Behaviours | 4 | 4 |
| Relationships | 11 | 11 |
| Scenarios | 3 | 3 |
| Event-scoped filters | 3 | 5 |

Engine: **112 Dart files** — 27 models, 44 UI, 11 simulation, 7 graph, 7
perspectives, 4 services, 3 education. **54 validator rules.** **35 test
files.**

Both systems open at `/<area>/explorer` through `SystemExplorerScreen`, which
names no system and special-cases none. The library tiles route there via
`StudioSystem.entryRoute`.

## 2. What each system contributes

They are deliberately different, and the difference is the point.

**Password Security** is the reference for a system whose human *watches*. Its
`user` has no authored actions; the attacker and administrator have one each.
Its `login_interface` is simultaneously the surface a person looks at, the
target of the attacker's action, and the source of the resulting event — three
roles in one node. Its responsible party, the administrator, is informed by
machinery: monitoring observes the engine and raises its own alert.

**Phishing** is the reference for a system whose human *decides*. Its recipient
faces two decisions in sequence — open or report, then, having seen the page,
submit or not — with nothing marking either. It separates the roles Password
Security fused: the gateway decides, the inbox surfaces, the link target and
reporting channel receive actions. Its responsible party is informed two ways —
by the gateway when it catches something, and by a person when it doesn't — and
in the branch where a compromise actually happens, by nobody at all.

That last asymmetry is the sharpest thing either system says.

## 3. Documentation map

| Document | What it is for |
|---|---|
| `architecture/AUTHORING_SYSTEMS.md` | **How to author a system.** Fourteen sections of practitioner guidance derived from both systems, with honest instance counts in §13. |
| `architecture/ENGINE_OPEN_QUESTIONS.md` | Unresolved engine semantics. Q2–Q5 open; Q1 resolved. Provisional leans, not decisions. |
| `decisions/` | Settled decisions. `DECISION_TEMPLATE.md`, `README.md` (convention + index), `DEC-0001-observation-route-selection.md`. |
| `architecture/ARCHITECTURE_STANDARD.md` | The SSAS nine-section format for component documents. Neither `AUTHORING_SYSTEMS.md` nor this checkpoint follows it; both say so. |
| `PRODUCT_PRINCIPLES.md` | Learner-facing product principles, predating the graph engine. Deliberately holds no engine or authoring rules. |
| `foundation/`, `journey/` | Vision and history. Not operational. |

The pipeline these are meant to form:

```
a system exposes something
        ↓
ENGINE_OPEN_QUESTIONS.md     recorded, costed, not decided
        ↓
DEC-NNNN                     decided, with consequences
        ↓
AUTHORING_SYSTEMS.md         the rule authors follow
```

DEC-0001 has now travelled the whole pipeline once, which is the only evidence
the convention works.

## 4. Confirmed, single-instance, and untested

The distinction matters: a shape seen once is an idiom that worked; a shape seen
twice in independent systems is something to plan around. `AUTHORING_SYSTEMS.md`
§13 holds the authoritative table. In summary:

**Confirmed at two independent instances.** Element vs wire (constrained both
systems). Blind spot (both, both test-asserted). Notification of the responsible
party (two distinct variants — machine and human). Observation vs knowledge
(both rejected a belief variable). Tri-state facets. Surfacing — now confirmed
by `inbox.present_message` and `link_target.present_page`. Scenario patterns:
contrast pair, inherited baseline, single-seed start.

**Single instance — do not make rules from these.** Decision actor (Phishing
only; two decisions inside one model is not two models). Monitoring Variant A
(Password Security only). `declaredBy` diverging from runtime source (Phishing
only).

**Never exercised.** `existenceOnly` fidelity — nothing is authored beyond
distance 1, so the degradation path has never run. 22 of 33
`StudioRelationshipType` values. Non-human actors. Feedback loops against
`behavior.trigger_cycle`. Time, repetition, continuous processes, and any notion
of degree or confidence.

## 5. Open questions and decisions

**Decided.** DEC-0001 — observation route selection. Multiple equal-distance
routes are retained; learner-facing surfaces select one deterministically;
selection prefers semantic meaning over authored order; authored order is a
final tie-break only and is not a property of any system. **Documented, not yet
implemented** — the engine still does first-match BFS, and the comment in
`phishing_detail.dart` explaining that authored order is deliberate remains
load-bearing until it is.

**Open.** Q2 presence vs involvement. Q3 `maximumDistance` as a per-system
property. Q4 `declaredBy` having no runtime role. Q5 whether surfacing may write
state. None is blocking; each has a provisional lean and a stated condition that
would force a decision.

## 6. Known unverified — read before trusting anything below the model layer

**No test suite has been run against the current state of the repository.** The
sandbox this work was done in has no Dart toolchain and cannot reach the SDK, so
every change since the Phishing scenarios landed has been verified structurally
— brace and paren balance, symbol and import sweeps, hand-traced route
discovery and propagation against the authored data — and by nothing else.

Specifically unproven:

- The Phishing final corrections (separating opening from submission; gateway
  detection informing defenders) and every test updated for them.
- `phishing_explorer_test.dart` in its entirety. Its widget finders assume
  layout that may sit below the fold at the configured view size, and its actor
  status assertions may have shifted now that the security team becomes relevant
  in the quarantine scenario.
- `cyber_lab_entry_routes_test.dart`, added with the entry-point fix.
- The two stale-assertion repairs using `StudioAllOf` destructuring and a
  sealed-class switch expression — valid Dart 3 as far as static reading goes,
  but unconfirmed by an analyzer.

Structural checks cannot catch a missing required named parameter. That class of
error has occurred once in this programme and broke every Phishing test at load.
**Treat a green full suite as the first real checkpoint; this document is the
second.**

Everything is also currently **uncommitted**. `docs/architecture/`,
`docs/decisions/` and several foundation documents are untracked, and
`docs/foundation/VISION.md` shows as deleted.

## 7. Readiness for a third system

No blockers. Nothing found in the post-Phishing audit requires an architecture
change before a third domain.

**Safe** — observation and fidelity, relevance by involvement, scenarios and
starting facts, causal derivation, the five-facet model, declarative conditions
and effects, event-scoped filtering, the graph-first pipeline, the generic
shell. All took a second system without modification.

**Watch** — route selection until DEC-0001 is implemented; `trigger_cycle`
against legitimate feedback loops; the absence of any check for over-broad
channels or self-re-offering actions; symbolic-only state if uncertainty becomes
a subject.

**The recurring risk is not the engine.** The three defects that reached a
learner walkthrough — one action carrying two decisions, an action that
re-offered itself, and a channel leaking events it had no business carrying —
were all invisible to the compiler, the validator and the test suite. They were
found by a person using the system. That remains the only instrument that
detects them.

**On domain choice.** Both authored systems have an adversary. Neither has
tested whether the architecture reads naturally without one, and the security
vocabulary in `StudioRelationshipType` (`threatens`, `exploits`, `mitigates`,
`prevents`, `protects`) is currently unexamined because both systems happen to
use it comfortably. A third system in a non-adversarial domain — with an
autonomous non-human actor and a genuine feedback loop — would test more of the
architecture's generality than a third security-adjacent one, and would
establish whether the remaining cybersecurity vocabulary is a naming question or
a structural one.

---

*Snapshot taken 2026-08-16, after DEC-0001 and the Phishing vertical slice.
Supersede rather than edit: a checkpoint that gets updated stops being one.*
