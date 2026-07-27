# Library Architecture

## Purpose

Systems Studio is built around a simple idea:

The engine provides the learning infrastructure.

Libraries provide domain knowledge.

The engine should never contain knowledge that belongs to a specific discipline.

Likewise, a library should never duplicate functionality already provided by the engine.

This separation allows Systems Studio to support any subject while maintaining a single reusable educational engine.

---

# Architectural Overview

```
Systems Studio

        │

        ▼

+---------------------------+
|         Engine            |
|---------------------------|
| Navigation                |
| Theme                     |
| Layout                    |
| Visualization             |
| Simulation Framework      |
| Diagrams                  |
| Assessments               |
| AI Integration            |
+---------------------------+

        │

        ▼

+---------------------------+
|        Libraries          |
+---------------------------+
| Cyber Lab                 |
| AI Lab                    |
| Medical Lab               |
| Aerospace Lab             |
| Engineering Lab           |
| Financial Systems Lab     |
+---------------------------+
```

The engine knows nothing about cybersecurity, medicine, engineering, or artificial intelligence.

It only knows how to present educational systems.

---

# What Is a Library?

A Library is a collection of educational systems that teach a specific domain.

Examples:

• Cyber Lab

• AI Lab

• Medical Systems

• Aerospace Systems

• Robotics

Each library shares the same educational philosophy while providing its own content.

---

# Responsibilities of a Library

Every library is responsible for providing:

• Library identity

• Systems

• Lessons

• Perspectives

• Simulations

• Assessments

• Assets

• Routes

The library owns the educational content.

The engine owns the learning experience.

---

# Responsibilities of the Engine

The engine is responsible for:

• Navigation

• Responsive layouts

• Themes

• Shared widgets

• Diagrams

• Simulation framework

• Perspective framework

• Assessment framework

• AI tutoring infrastructure

• Analytics

• Accessibility

• User preferences

• Progress tracking

These capabilities are reusable across every library.

---

# Educational Hierarchy

Every library follows the same structure.

```
Library

    ▼

System

    ▼

Lesson

    ▼

Perspective

    ▼

Diagram

    ▼

Simulation

    ▼

Reflection

    ▼

Assessment
```

Not every lesson requires every step.

However, every educational experience should fit naturally into this hierarchy.

---

# Systems

A System represents a complete concept within a domain.

Cyber Lab examples:

• Password Security

• Networking

• Encryption

• Phishing

Medical examples:

• Circulatory System

• Respiratory System

• Immune System

Engineering examples:

• Feedback Control

• Power Distribution

• Communications

A system is the highest level of reusable educational content.

---

# Perspectives

Systems are best understood from multiple viewpoints.

Examples:

Cybersecurity

• User

• Attacker

• Defender

Engineering

• Designer

• Operator

• Maintainer

Artificial Intelligence

• User

• Model

• Developer

Changing perspective changes understanding.

---

# Simulations

A simulation allows learners to experiment with a system.

Simulations should answer:

"What happens if I change this?"

Learning occurs through interaction rather than observation.

---

# Diagrams

Diagrams visualize relationships.

A diagram should explain structure.

A simulation should explain behavior.

Both are necessary.

---

# Assessments

Assessments measure understanding.

They should favor reasoning over memorization.

Whenever possible, assessments should ask learners to apply concepts instead of recalling facts.

---

# Library Independence

Libraries should not depend on one another.

Cyber Lab should function without AI Lab.

Medical Lab should function without Engineering Lab.

Each library is independently installable and independently maintainable.

---

# Shared Educational Philosophy

Every library adopts the Systems Studio philosophy.

Teach understanding.

Teach systems.

Encourage exploration.

Promote curiosity.

Support experimentation.

Build confidence.

Different subjects.

One philosophy.

---

# Future Growth

The architecture is intentionally open.

New libraries should require no modifications to the engine.

Adding a new library should be equivalent to installing a plugin.

The engine discovers the library.

The library registers itself.

The engine presents it.

No engine changes should be required.

---

# Guiding Principle

If a feature could benefit multiple libraries,
it belongs in the engine.

If a feature teaches a specific subject,
it belongs in a library.

This single rule governs every architectural decision.