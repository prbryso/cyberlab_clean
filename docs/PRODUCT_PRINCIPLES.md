Nothing happens in a system until an actor acts. Simulation begins with an actor selecting an action. Systems Studio then reveals how that action propagates through relationships, produces events, becomes observable, triggers responses, and changes the state of the system.

A simulation starts with an actor action and proceeds by propagating resulting effects and events through system relationships until no further response occurs.

What information must an Action contain so the engine knows what happens when it is selected?

Actor actions are chosen.
System actions are triggered.

The learner starts a simulation by choosing an actor and one of that actor's available actions.

A learner-driven simulation begins when an actor takes an action.

A Flow is the ordered causal trace produced when an action propagates through a system.

Actors do not all need to be active at the start of a simulation. An actor can enter the flow when an event becomes observable to that actor.

An Event is something that has happened in the system that may become observable to one or more actors or system elements.

Events propagate through relationships. Any actor capable of observing an event becomes eligible to participate in the flow.

Actors enter a simulation through awareness.

A perspective is what an actor can know about the system from the observations available to that actor.

Available actions can depend on state and observations.


Actions can target not only system elements, but relationships/interactions between system elements.

Learner-directed simulation begins with an action. System behavior then propagates automatically until another meaningful learner decision becomes available.

f a control is represented as an active system element, it should be modeled as an ordinary graph node capable of facets and later Behaviors.



# Product Principles

## 1. Teach Systems, Not Rules

Every feature should improve understanding.

Never teach memorization when understanding is possible.

---

## 2. Active Learning

Learners should think before they are told.

Questions come before explanations.

---

## 3. Explain Why

Every lesson answers:

Why does this work?

Why does this fail?

Why does the defense succeed?

---

## 4. Think Like the Attacker

Every module explains:

Objectives

Capabilities

Limitations

Decision making

Motivation

---

## 5. Visual First

If something can be explained with a diagram,
don't write three paragraphs.

---

## 6. Interaction Over Reading

Learners should interact every few minutes.

Not every twenty minutes.

---

## 7. Build Intuition

The goal is confidence.

Not memorization.

---

## 8. Reusable Architecture

Every new module should require
new content,

not new software.

---

## 9. Every Screen Has One Purpose

Never overload a screen.

Each screen answers one question.

---

## 10. Professional Quality

Every screen should look like software
someone paid for.



Every node in a system can be understood through five fundamental questions:
Actions — What can this element do?
Goals — What is this element trying to accomplish?
Observations / Monitoring — What can it sense, watch, or infer?
Anomalies / Events — What conditions can it detect, generate, or report?
Relationships — What does it depend on, affect, communicate with, protect, control, or threaten?

And there is a deeper implication here that I really like:
The graph tells us the structure of the system.
These five properties tell us the behavior of its elements.
Actor + Scenario + Flow tells us how that behavior unfolds.
So we're beginning to get a remarkably coherent conceptual model:
SYSTEM
  │
  ├── NODES
  │     ├── Actions
  │     ├── Goals
  │     ├── Observations / Monitoring
  │     ├── Anomalies / Events
  │     └── Relationships
  │
  └── EXPLORATION
        ├── Actor
        ├── Scenario
        └── Flow
That may be the bridge we've been looking for between the system model and the Workspace experience.
And I would keep one principle firmly in mind as we implement it: not every node must have all five categories populated. They are questions we can ask of every node, not mandatory database fields that must always contain something.
That distinction will keep the model flexible enough for actors, components, processes, boundaries, controls, failures, and other node types.

the answer to some questions could be (null)


Exactly. And I think null is meaningful, not a deficiency.
These five are questions that can be asked of every node; they are not requirements that every node have five answers.
For example:
Node	Actions	Goals	Observations	Anomalies / Events	Relationships
User	✓	✓	✓	maybe	✓
Attacker	✓	✓	✓	maybe	✓
Authentication Monitor	✓	✓	✓	✓	✓
Credential Store	✓	maybe	null	✓	✓
Network Boundary	maybe	null	null	✓	✓


This suggests an important modeling principle:
Every node can be examined through the five questions, but some questions may legitimately have no answer for a particular node.

distinguish null from unknown.
null means this concept does not apply to this node.
unknown means it may apply, but we don't currently know the answer.

That's potentially valuable later. Systems Studio could even expose unknowns as places worthy of investigation.
So conceptually we could eventually have:
Actions:                 Defined
Goals:                   Defined
Observations/Monitoring: None
Anomalies/Events:        Unknown
Relationships:           Defined

