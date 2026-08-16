Every view—Overview, Perspectives, Simulations, AI explanations, Search, and the System Workspace—is simply a different window into that understanding.


Every system is explored through an interactive graph. Every explanation, simulation, and perspective begins there.

# Graph-First Architecture

# System Studio

## Purpose

System Studio is a graph-first platform for understanding complex systems.

The graph is not an illustration added to a lesson.

The graph is the authoritative representation of the system.

Every overview, architecture view, exploration tool, simulation, perspective, learning path, search result, and AI explanation should originate from the same validated system graph.

---

# Core Principle

> The graph is the source of truth.

Libraries describe systems.

The engine converts those descriptions into graphs.

Perspectives query the graphs.

Widgets render the results.

Users explore the system through those views.

The intended flow is:

```text
Library Content
      ↓
StudioSystemDetail
      ↓
StudioGraphBuilder
      ↓
StudioSystemGraph
      ↓
StudioGraphQuery
      ↓
Perspective
      ↓
View Model
      ↓
Widget
Knowledge should not be duplicated across screens.
A screen should not own a second version of the system.
What the Graph Represents
A StudioSystemGraph represents the elements and relationships that define a system.
The graph may contain:
systems
subsystems
components
actors
assets
interfaces
inputs
outputs
boundaries
processes
states
controls
failure modes
incidents
simulations
references
external systems
custom domain elements
Each graph node should have:
a stable identifier
a display label
a type
a description
an optional parent
tags
metadata
Each relationship should have:
a stable identifier
a source
a target
a relationship type
a direction
a label
optional strength
optional metadata
What the Graph Knows
The graph should know facts about the modeled system.
Examples include:
which subsystem contains a component
which actor participates in a process
which component consumes an input
which component produces an output
which interface connects two elements
which asset is protected
which failure affects a subsystem
which control mitigates a failure
which incident illustrates a behavior
which simulation explores a relationship
which reference supports an explanation
The graph should not know how those facts are displayed.
It should not know about cards, tabs, colors, scrolling, or screen layout.
What a Perspective Knows
A perspective is a reusable way of examining a graph.
A perspective asks a specific class of question.
Examples:
Overview: What is this system?
Architecture: How is it organized?
Explore: What is connected to this element?
Failure: What can go wrong?
Dependency: What depends on this?
Security: What can attack or protect this?
Simulation: What happens when conditions change?
Timeline: What happens over time?
User: How does a user experience the system?
Attacker: How could the system be exploited?
Defender: How could the system be protected?
A perspective may:
query the graph
create a focused subgraph
categorize nodes and relationships
build a view model
react to node selection
expose perspective-specific capabilities
A perspective should not contain domain knowledge that belongs in a library.
For example, OverviewPerspective should not know what a password is.
It should only know how to summarize a graph.
What a View Model Knows
A view model contains presentation-ready information derived from the graph.
It translates graph structures into categories that are useful to a renderer.
Examples:
OverviewViewModel

selected node
parent
ancestors
architectural children
actors
assets
inputs
outputs
boundaries
failures
controls
incidents
simulations
references
incoming relationships
outgoing relationships
A view model should:
contain no domain-specific assumptions
contain no navigation code
contain no persistent knowledge separate from the graph
contain no unnecessary Flutter widgets
be suitable for reuse by UI, export, narration, and AI
The graph remains authoritative.
The view model is temporary and derived.
What a Widget Knows
A widget knows how to present a view model.
A widget may know:
layout
spacing
typography
icons
interaction controls
responsive behavior
visual hierarchy
A widget should not independently search system data.
It should not recreate graph queries already performed by the perspective or view model.
The intended boundary is:
Perspective decides what to show.

View model organizes the result.

Widget decides how it looks.
Engine Responsibilities
The engine is domain-independent.
The engine provides:
graph construction
graph validation
graph querying
graph traversal
graph focus
path finding
search
perspective registration
reusable perspectives
reusable visualization
simulation infrastructure
export infrastructure
future AI grounding
The engine should never depend on Cyber Lab, AI Lab, or any other library.
The dependency direction must remain:
Library
   ↓
Engine
Never:
Engine
   ↓
Library
Library Responsibilities
A library provides domain knowledge.
Cyber Lab may provide:
authentication systems
phishing systems
encryption systems
attack relationships
security controls
cybersecurity incidents
cybersecurity simulations
cybersecurity references
optional Cyber Lab perspectives
AI Lab may provide:
training systems
inference systems
language models
data pipelines
AI failure modes
evaluation relationships
AI safety controls
AI simulations
AI references
optional AI-specific perspectives
A library may contribute:
systems
system details
explicit graphs
relationships
simulations
stories
incidents
references
domain-specific perspectives
A library should not modify core engine behavior to add ordinary content.
Standard Perspectives
System Studio should provide reusable standard perspectives.
Initial standard perspectives are:
Overview
Architecture
Explore
Simulate
Future standard perspectives may include:
Dependencies
Failures
Timeline
Comparison
Search
AI Explanation
Data Flow
State Flow
Human Interaction
These perspectives should work across libraries whenever the graph contains the required information.
Library-Specific Perspectives
Some domains require specialized ways of understanding a system.
Cyber Lab may add:
Attack Chain
Threat Model
Trust Boundary
Defensive Coverage
Incident Response
AI Lab may add:
Training Pipeline
Inference Flow
Token Flow
Data Lineage
Evaluation
Hallucination Analysis
Human Oversight
Specialized perspectives may interpret domain-specific node and relationship types.
They must still use the shared graph and perspective framework.
They should not create isolated secondary data models unless a simulation genuinely requires temporary state.
Graph Focus
Large systems cannot be understood by showing every element at once.
System Studio uses graph focus to show the information relevant to the user's current question.
A StudioGraphFocus may specify:
the center node
traversal depth
whether parents are included
whether children are included
whether incoming relationships are included
whether outgoing relationships are included
allowed node types
allowed relationship types
The UI describes the desired focus.
The graph query engine determines the visible subgraph.
The screen should not manually rebuild focused graphs.
Graph Queries
Perspectives should use StudioGraphQuery rather than manually filtering graph lists.
Examples include:
childrenOf
descendantsOf
ancestorsOf
neighborsOf
incomingTo
outgoingFrom
shortestPath
reachableFrom
nodesByType
nodesByTag
searchNodes
boundaryNodes
focusedSubgraph
Future queries may include:
dependenciesOf
dependentsOf
failuresAffecting
controlsMitigating
assetsProtectedBy
attackPaths
trustBoundaryCrossings
incidentsRelatedTo
simulationsRelatedTo
referencesRelatedTo
impactOfFailure
When a reusable query is needed by more than one perspective, it belongs in the graph query engine.
Validation
Every graph must be validated before it is used.
Validation should detect:
duplicate node IDs
duplicate relationship IDs
missing root nodes
invalid root types
broken source references
broken target references
missing parents
invalid parent references
hierarchy cycles
malformed relationships
invalid system IDs
Future validation may also detect:
orphan nodes
unreachable components
unused assets
unmitigated failures
controls with no target
interfaces with missing endpoints
invalid relationship combinations
incomplete system descriptions
The graph engine is the single owner of validation.
Builders create graphs.
Validators check graphs.
Simulation
Simulations should operate on the graph rather than duplicate the system.
A simulation may:
activate an attack path
disable a control
change a state
alter a relationship
apply an event
propagate a failure
compare outcomes
animate traversal
Simulation state may be temporary.
The authoritative system definition remains unchanged unless the user explicitly edits the model.
The simulation engine should answer:
What happens when the system changes?

Multiple Perspectives
A system can be understood differently depending on the observer.
The same graph may be viewed through:
user
attacker
defender
operator
engineer
manager
regulator
safety analyst
privacy analyst
student
A role perspective should not create a separate system.
It should filter, emphasize, annotate, or traverse the same graph differently.
For example:
User Perspective
focus on actions, decisions, friction, and outcomes

Attacker Perspective
focus on opportunities, attack paths, assets, and weaknesses

Defender Perspective
focus on controls, monitoring, detection, and recovery
Learning and Exploration
System Studio is not organized around memorizing pages.
It is organized around exploring relationships.
Learning content may be attached to graph nodes and relationships as:
questions
explanations
stories
incidents
references
simulations
deep dives
media
guided explorations
The graph may help generate:
learning roadmaps
prerequisite paths
related topics
quick paths
guided stories
recommended next explorations
These should be derived from the system model whenever possible.
AI
AI should be grounded in the graph.
The AI layer should first gather relevant graph context:
selected node
ancestors
descendants
neighbors
incoming relationships
outgoing relationships
failures
controls
incidents
references
relevant focused subgraph
The AI may then explain, summarize, compare, or guide exploration.
AI should not silently replace the system model with general knowledge.
When outside knowledge is used, it should be clearly distinguished from graph-grounded information.
The graph provides structure.
References provide evidence.
AI provides explanation.
Search
Search should operate primarily over graph nodes, relationships, tags, descriptions, and metadata.
A search result should lead to a system element, not merely a page.
Selecting a result should allow the user to:
focus the graph
open Overview
open Architecture
explore relationships
view failures
run simulations
inspect references
Search is another way to enter the graph.
Export
Exports should be generated from graph-derived view models.
Possible formats include:
Markdown
PDF
HTML
JSON
diagrams
reports
narrated summaries
Exports should not require custom domain-specific screen scraping.
The graph and perspective models should supply the content.
Authoring
Content authors should describe systems rather than program screens.
Authors should primarily create:
systems
nodes
relationships
metadata
stories
simulations
incidents
references
The engine should provide the standard experience automatically.
The long-term authoring principle is:
Describe systems. Do not program systems.

Architectural Rules
Rule 1: The graph is authoritative
Do not duplicate system knowledge inside widgets or screens.
Rule 2: Perspectives query the graph
Perspectives must obtain knowledge through the graph session and query engine.
Rule 3: View models are derived
View models organize graph results but do not become independent sources of truth.
Rule 4: Widgets render
Widgets control presentation, not domain reasoning.
Rule 5: Libraries depend on the engine
The engine must never depend on a library.
Rule 6: New libraries should be mostly content
Ordinary library additions should not require changes to core engine navigation or graph behavior.
Rule 7: Reusable reasoning belongs in the engine
If multiple perspectives need the same traversal or classification, it belongs in StudioGraphQuery or another engine service.
Rule 8: Domain-specific reasoning belongs in the library
If a query only makes sense for a particular domain, the library may provide a specialized perspective or analyzer.
Rule 9: Focus replaces visual overload
Do not solve complexity by displaying the entire graph.
Show the context relevant to the current question.
Rule 10: Every feature must improve understanding
A feature belongs only if it helps users visualize, explore, simulate, compare, or reason about a system.
Reference Architecture
System Studio Application
│
├── Engine
│   ├── Models
│   ├── Graph
│   │   ├── Builder
│   │   ├── Validator
│   │   ├── Query
│   │   ├── Focus
│   │   ├── Search
│   │   ├── Simulation
│   │   └── Export
│   │
│   ├── Perspectives
│   │   ├── Contract
│   │   ├── Catalog
│   │   ├── Overview
│   │   ├── Architecture
│   │   ├── Explore
│   │   └── Simulation
│   │
│   └── UI
│       ├── Experience Host
│       ├── Graph Canvas
│       ├── Navigation
│       └── Shared Components
│
└── Libraries
    ├── Cyber Lab
    │   ├── Systems
    │   ├── Relationships
    │   ├── Incidents
    │   ├── Simulations
    │   ├── References
    │   └── Optional Perspectives
    │
    └── AI Lab
        ├── Systems
        ├── Relationships
        ├── Incidents
        ├── Simulations
        ├── References
        └── Optional Perspectives

Exactly. I would actually strengthen that section because you've identified the more important architectural rule.
I would replace it with something like this:
# Engine and Library Relationship

The engine is completely domain-independent.

It knows nothing about cybersecurity, artificial intelligence, medicine, finance, aerospace, or any other subject.

Its responsibility is to provide the generic capabilities required to understand any system, including:

- graph construction
- graph validation
- graph querying
- graph traversal
- perspectives
- visualization
- simulation
- search
- export
- AI grounding

Libraries provide the domain knowledge.

A library describes systems by supplying:

- system definitions
- nodes
- relationships
- metadata
- incidents
- simulations
- references
- optional domain-specific perspectives

The engine consumes this information to build a graph and provide a consistent interactive experience.

The dependency direction is always:

Library
    ↓
Engine

The engine never depends on a specific library.

A library depends on the engine because it uses the engine's models, graph services, perspectives, and visualization framework.

Adding a new library should primarily consist of describing new systems rather than modifying engine code.
I also think we should change one phrase that appears throughout the document.
Instead of saying:
The engine consumes the library.

I'd say:
The engine interprets the library's system descriptions.

That sounds subtle, but it's actually much closer to what Systems Studio is doing.
A Cyber Lab author writes:
Password System

Actors
Subsystems
Interfaces
Failures
Relationships
The engine interprets that description and automatically creates:
the graph
the overview
the architecture view
the explorer
the search index
the simulations
the AI context
the exports
The library isn't writing an application. It's describing a system.
That leads to what I think may become one of the core ideas of Systems Studio:
Libraries describe systems. The engine understands them.

I like that sentence because it captures the separation of responsibilities in a way that's easy to remember, and it can become one of the guiding principles for the entire architecture.

# Graph-First Architecture

# System Studio

## Purpose

System Studio is a graph-first platform for understanding complex systems.

The graph is not an illustration added to a lesson.

The graph is the authoritative representation of the system.

Every overview, architecture view, exploration tool, simulation, perspective, learning path, search result, and AI explanation should originate from the same validated system graph.

---

# Core Principle

> The graph is the source of truth.

Libraries describe systems.

The engine converts those descriptions into graphs.

Perspectives query the graphs.

Widgets render the results.

Users explore the system through those views.

The intended flow is:

```text
Library Content
      ↓
StudioSystemDetail
      ↓
StudioGraphBuilder
      ↓
StudioSystemGraph
      ↓
StudioGraphQuery
      ↓
Perspective
      ↓
View Model
      ↓
Widget