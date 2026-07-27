# Systems Studio Engine API

## Purpose

The Systems Studio Engine API defines the contract between the reusable engine and educational libraries.

The engine provides the infrastructure required to present, navigate, visualize, simulate, and assess complex systems.

Libraries provide the domain-specific knowledge taught through that infrastructure.

This contract allows new libraries to be added without modifying the internal implementation of the engine.

---

# Core Principle

The engine must not contain domain knowledge.

A library must not depend on engine implementation details.

Libraries communicate with the engine only through stable models, interfaces, and registration mechanisms.

The engine asks a library:

- Who are you?
- What systems do you provide?
- What routes do you expose?
- What simulations do you support?
- What assets do you require?

The library answers through the Engine API.

---

# Architectural Boundary

```text
┌──────────────────────────────────────────────┐
│               Systems Studio                 │
├──────────────────────────────────────────────┤
│                                              │
│                  Engine                      │
│                                              │
│  Navigation                                  │
│  Layout                                      │
│  Theme                                       │
│  Shared UI                                   │
│  Diagrams                                    │
│  Simulation Runtime                          │
│  Assessments                                 │
│  Progress                                    │
│  Analytics                                   │
│                                              │
├──────────────── Engine API ──────────────────┤
│                                              │
│                 Libraries                    │
│                                              │
│  Cyber Lab                                   │
│  AI Lab                                      │
│  Engineering Lab                             │
│  Medical Systems Lab                         │
│  Future Libraries                            │
│                                              │
└──────────────────────────────────────────────┘