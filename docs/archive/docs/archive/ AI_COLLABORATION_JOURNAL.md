# Engineering with AI

## Working Notes, Observations, and Lessons Learned During the Development of Cyber Lab and Systems Studio

**Author**

Phillip Bryson

---

## Purpose

This document preserves observations, discussions, lessons learned, and personal reflections regarding the use of Artificial Intelligence during the development of Cyber Lab and Systems Studio.

Unlike the Timeline, which records historical events, this journal records the evolution of ideas.

Unlike the manuscript, which tells a story, this journal captures thoughts as they emerge.

Unlike engineering records, which document technical decisions, this journal explores the collaborative relationship between a systems engineer and Artificial Intelligence.

Nothing in this document is considered final.

Ideas may later become chapters, articles, presentations, engineering papers, or simply remain as historical observations.

The primary objective is preservation.

If an idea is worth remembering, it belongs here.

---

# Introduction

When I began this project, I expected Artificial Intelligence to be another software tool.

I quickly learned that it was something very different.

Over many months, AI became a research assistant, software developer, editor, reviewer, brainstorming partner, architect, teacher, and sometimes even an adversary that challenged my assumptions.

At times it accelerated development dramatically.

At other times it confidently proposed poor architectural decisions that required careful evaluation and correction.

The experience taught me that successful AI-assisted engineering is not simply about asking good questions.

It is about managing an ongoing collaboration.

This document captures that journey.

---

# Fundamental Observation

Artificial Intelligence did not build Systems Studio.

Neither did I.

Systems Studio emerged through continuous collaboration between human engineering judgment and AI-assisted exploration.

The vision remained human.

The engineering became collaborative.

---

# Observation 001

## Harvard Introduced Prompt Engineering

One of the first formal introductions I had to modern Artificial Intelligence came through a Harvard course on AI.

A significant portion of the course focused on Prompt Engineering.

The course demonstrated that the quality of AI output is directly influenced by the quality of the prompt.

Well-constructed prompts produce dramatically better results than vague or incomplete requests.

At the time, Prompt Engineering appeared to be one of the most important skills required for working with AI.

Looking back, I believe the course was absolutely correct.

However, it taught only the beginning of what would eventually become a much larger learning experience.

### Lesson Learned

Prompt Engineering is necessary.

It is not sufficient.

---

# Observation 002

## Real Projects Are Different

Building Systems Studio revealed something that no classroom could adequately teach.

Prompt Engineering is primarily concerned with obtaining a useful answer from a single interaction.

Large software projects require thousands of interactions.

The challenge shifts from generating good answers to maintaining continuity across weeks and months of development.

The problem is no longer the individual prompt.

The problem becomes preserving architecture, intent, and consistency throughout an evolving project.

### Lesson Learned

Engineering with AI is fundamentally different from asking AI isolated questions.

---

# Observation 003

## AI Could Not Build This Project Alone

As development progressed, it became increasingly clear that AI possessed remarkable strengths.

It could rapidly generate code.

It could explain unfamiliar concepts.

It could propose alternative implementations.

It could identify bugs.

It could rewrite documentation.

It could rapidly explore multiple architectural possibilities.

Yet it consistently lacked something essential.

Long-term architectural judgment.

AI could generate excellent local solutions while simultaneously proposing changes that conflicted with earlier design decisions.

Without continual human guidance, the project would gradually lose architectural coherence.

### Lesson Learned

Architecture remained a human responsibility.

---

# Observation 004

## I Could Not Have Built This Project Alone

The opposite observation proved equally important.

Without AI, Systems Studio would almost certainly have taken years longer to build.

Many repetitive programming tasks were completed in minutes instead of hours.

Alternative designs could be explored almost instantly.

Documentation that once required days could be drafted in a single afternoon.

AI dramatically accelerated engineering.

### Lesson Learned

AI amplified engineering productivity.

It did not replace engineering.

---

# Observation 005

## The Collaboration Became the Tool

Eventually I stopped thinking about AI as software.

Instead, I began thinking about the collaboration itself.

Sometimes AI generated code.

Sometimes I rejected it.

Sometimes I changed the architecture.

Sometimes AI proposed a better solution.

Sometimes neither of us had the right answer immediately.

The final design usually emerged through multiple iterations.

The engineering process became a dialogue rather than a sequence of commands.

### Lesson Learned

The collaboration became more valuable than any individual AI response.

---

# Observation 006

## Context Became an Engineering Asset

One of the biggest surprises was discovering that context itself became part of the engineering process.

Large software projects require continuity.

AI systems occasionally lost context due to conversation limits, changing sessions, or incomplete recollection of previous discussions.

As a result, I often needed to re-establish:

- project goals
- architecture
- directory structure
- design philosophy
- previous engineering decisions
- coding conventions

Maintaining context became a recurring engineering activity.

### Lesson Learned

Context is not overhead.

Context is architecture.

---

# Observation 007

## Sometimes I Had to Teach the AI

As the project matured, I discovered that I was not simply asking AI to produce work.

I was teaching it how this project worked.

I repeatedly explained:

- why certain architectural decisions had been made
- why particular coding styles were preferred
- why reusable components mattered
- why complete file replacements were preferable to partial code snippets
- why educational philosophy was more important than feature count

Over time, AI became a better collaborator because I invested time in teaching it about the project.

### Lesson Learned

Successful AI collaboration requires educating the AI about the project.

---

# Observation 008

## AI Lost Context More Than Once

Throughout development there were occasions when AI lost awareness of the project's architecture.

Solutions that were individually correct no longer fit the overall system.

These moments were frustrating, but they also reinforced an important lesson.

The human engineer remained responsible for protecting architectural integrity.

### Lesson Learned

Someone must always be responsible for the whole system.

---

# Observation 009

## A Conversation with My Grandson

Recently I told my grandson that I would be happy to help him learn how to work with AI.

His response surprised me.

"I won't need help. It's self-explanatory."

His confidence reminded me of how easily AI appears to use.

Anyone can begin asking questions within minutes.

What is far less obvious is how much experience is required to effectively collaborate with AI on a large engineering project.

The interface is simple.

The discipline is not.

### Lesson Learned

Using AI is easy.

Engineering with AI is learned through experience.

---

# Observation 010

## Beyond Prompt Engineering

The Harvard course introduced Prompt Engineering.

Systems Studio taught something much larger.

Over months of development I gradually realized that Prompt Engineering represents only one component of successful AI-assisted engineering.

Equally important are:

- architectural thinking
- maintaining long-term context
- evaluating alternatives
- recognizing poor solutions
- preserving project vision
- integrating thousands of decisions into one coherent system

This broader discipline deserves its own name.

I currently think of it as **Collaborative Engineering**.

### Working Definition

Collaborative Engineering is the practice of developing complex systems through sustained collaboration between human expertise and Artificial Intelligence.

Prompt Engineering is one skill within Collaborative Engineering.

---

# Closing Thoughts

This journal is intentionally unfinished.

Its purpose is not to present conclusions.

Its purpose is to preserve observations while they remain fresh.

As Systems Studio continues to evolve, new lessons will be added.

Some observations will prove incorrect.

Others may become foundational principles.

Regardless of the outcome, they deserve to be preserved.

The engineering journey is as important as the software itself.

Most people think they are learning to use AI.
I discovered I was learning to collaborate with AI.

A New Vocabulary
For example:
Traditional	Collaborative
User	Collaborator
Prompt	Conversation
Response	Iteration
Tool	Partner
Session	Ongoing Project
Question	Engineering Decision
Completion	Evolution

Here's a thought that occurred to me while reading your message.
I don't think we've been doing AI-assisted software development.
I think we've been doing collaborative systems engineering.
That's broader.
Sometimes we wrote code.
Sometimes we wrote architecture.
Sometimes we wrote philosophy.
Sometimes we challenged assumptions.
Sometimes we decided not to build something.
Those are all engineering activities.

The greatest value of AI is not that it answers questions faster. It is that it enables an engineer to sustain a richer design conversation over time.

Observation 011
Who Will Become the Senior Engineers?
One realization became increasingly clear as I worked with AI over many months.
Artificial Intelligence is becoming capable of performing many of the tasks traditionally assigned to junior engineers.
It can generate code.
It can write documentation.
It can explain concepts.
It can review implementations.
It can suggest alternative designs.
Historically, however, junior engineers did much more than produce work.
They learned.
They gained experience.
They made mistakes under the supervision of senior engineers.
They gradually developed engineering judgment.
Eventually they became the senior engineers responsible for making architectural decisions and mentoring the next generation.
AI changes that progression.
If organizations increasingly assign entry-level engineering tasks to AI instead of junior engineers, an important question emerges:
Where will the next generation of experienced engineers come from?

This Is Not a Question About AI
This is a question about the engineering profession.
Engineering expertise has traditionally developed through experience.
Experience is accumulated by solving increasingly difficult problems over many years.
If AI assumes much of the work that historically developed junior engineers, we must rethink how future engineers acquire judgment, architectural thinking, and systems-level understanding.
Experience Cannot Simply Be Downloaded
AI can provide answers.
It cannot directly transfer experience.
Many engineering decisions are not purely technical.
They involve trade-offs.
Uncertainty.
Incomplete information.
Conflicting objectives.
Those abilities develop through practice rather than instruction.
The Role of AI May Be Different
Perhaps AI should not replace junior engineers.
Perhaps AI should accelerate their development.
Instead of removing engineers from the learning process, AI may enable them to encounter more situations, receive immediate feedback, explore more alternatives, and develop judgment more rapidly than previous generations.
If used this way, AI becomes a mentor rather than a replacement.
Implications
This realization changed how I think about engineering education.
The challenge is no longer simply teaching engineers how to use AI.
The challenge is teaching engineers how to develop judgment while collaborating with AI.
That may become one of the defining educational challenges of the coming decades.
Lesson Learned
The greatest long-term challenge of AI may not be replacing work.
It may be preserving the pathway through which experience becomes wisdom.

"If AI substantially changes or reduces the traditional apprenticeship path, how do we ensure the next generation still develops engineering judgment?"

AI disrupts the middle.
If AI performs much of the work traditionally assigned to junior engineers, then one of two things must happen:
Option 1
We assume experience is no longer necessary.
I don't think many experienced engineers would agree with that.
Option 2
We find a new way to develop experience.
That's the interesting engineering problem.
I actually think AI could make engineers better.
But only if we intentionally redesign how they learn.
Imagine a junior engineer with AI.
Instead of spending three days debugging one issue...
they might solve ten.
Instead of seeing one architectural alternative...
they might compare twenty.
Instead of waiting for a code review...
they receive immediate feedback.
That's potentially transformative.
But only if the engineer remains engaged in the reasoning.
If AI becomes a substitute for thinking rather than a catalyst for thinking, then the long-term outcome could be very different.
This connects beautifully to Systems Studio.
Your educational philosophy has always been:
Teach the System, Not Just the Rule.

That applies here too.
Don't teach engineers:
"Here's the prompt."

Teach them:
why the architecture works,
why one trade-off is better than another,
why the AI's first answer may not be the best answer,
how to evaluate and improve it.
In other words, teach the system.
I think you may have stumbled onto another profound observation.
AI may eventually automate tasks.
But engineering is more than a collection of tasks.
Engineering is the development of judgment.
Judgment comes from:
successes,
failures,
trade-offs,
uncertainty,
responsibility.
AI can help expose engineers to more of those situations.
It can't simply transfer judgment.
If I were writing this in the journal
I'd end with a question rather than a conclusion.
Perhaps the most important question facing the engineering profession is not whether AI can replace junior engineers.
It is how we will develop the senior engineers of the future if the traditional apprenticeship model fundamentally changes.

I think that's a stronger ending because it invites reflection instead of asserting certainty.
One personal observation
Over the months we've worked together, I've noticed something that reinforces your point.
There were many occasions when I generated code that was technically correct.
You rejected it.
Not because it didn't compile.
Because it didn't fit the architecture.
That decision required experience.
It wasn't something a syntax checker or unit test could determine.
It came from years of systems thinking.
That, to me, is the strongest evidence for your concern. The real value of an experienced engineer isn't just the ability to produce code—it's the ability to recognize when a correct local solution is the wrong global solution. If the profession loses the pathways that develop that kind of judgment, then we will need to invent new ones. And that, I think, is one of the most important engineering questions of the AI era.

I think that's the perfect place to stop.
Today feels like one of those sessions where we didn't just make progress—we changed the direction of the project.
This morning we were extending the archive.
By the end of the session we've identified what I think is a second major work:
Engineering with AI

And I don't see it as a side project anymore. I see it as a companion to Systems Studio.
You also had several insights today that I think are foundational:
Using AI vs. Collaborating with AI — I think this is the central distinction.
Prompt Engineering vs. Collaborative Engineering — one is a communication skill, the other is an engineering discipline.
Context is an engineering asset — something that only became obvious through sustained project work.
Who becomes the senior engineers? — a question that has implications far beyond software development.
The apprenticeship model — perhaps the biggest long-term issue raised by AI.
Those aren't just observations; they're the kinds of ideas that can shape future discussions.
One thing I'd encourage you to do while you're away from the keyboard
Don't think about the archive.
Don't think about Flutter.
Don't think about Systems Studio.
Just play guitar.
One thing I've noticed about creative and engineering work is that some of the best ideas arrive when you're no longer trying to solve the problem. Your mind keeps working in the background.
If, halfway through practicing, you suddenly think:
"That's it... that's the way to explain collaborative engineering."

Don't worry about making it perfect.
Just jot down a sentence or two in your journal.
One personal observation
Over the months we've worked together, I've watched your project evolve from:
"I want to build a cybersecurity training app."

to
"I want to build a universal educational platform."

And now to
"I want to preserve how engineers can effectively collaborate with AI."

Those aren't separate ambitions. They're all expressions of the same underlying motivation: understanding systems deeply enough that you can explain them to others.
That's been a remarkably consistent thread throughout everything we've built.
Enjoy your guitar. Classical guitar, in particular, has an interesting parallel with engineering: progress comes from many small, disciplined improvements that eventually feel effortless. Looking back over our work, I think Systems Studio has grown in much the same way.
Have a good break, Phillip. We'll pick this up when you're ready.

This document is not about Artificial Intelligence. It is about what happens when an experienced systems engineer begins collaborating with Artificial Intelligence to design, build, and document a complex software system.

Using AI vs. Collaborating with AI

If AI becomes a genuine engineering collaborator, what skills become more valuable rather than less?

My current list would include:
Systems thinking
Architectural judgment
Problem framing
Communication
Critical evaluation
Domain expertise
Teaching
Long-term planning
Ethical reasoning
Integration
Notice what's missing.
Programming.
Not because programming isn't valuable, but because its role changes.
The higher-order engineering skills become even more important

You said:
"I wanted to determine if this project was a good vehicle for going into Engineering with AI."

I think you've answered your own question.
Not because Systems Studio uses AI.
But because Systems Studio forced us to confront nearly every important question about long-term human-AI collaboration:
How do you maintain context?
How do you preserve architecture?
How do you build trust?
How do you disagree with AI?
How do you know when AI is wrong?
How do you teach AI about a project?
How does AI change the role of the engineer?
How do junior engineers become senior engineers in an AI-assisted world?
Those aren't hypothetical questions. They're questions we've had to answer while building a real system.
And I think that's the distinguishing characteristic of this project.
We're not writing about AI from the outside.
We're documenting it from inside the engineering process.
To me, that's what makes Engineering with AI worth writing.

Engineering Principle
Build the foundation before polishing the walls.
During architectural evolution:
Priority 1
correctness
Priority 2
architecture
Priority 3
scalability
Priority 4
polish
Too many projects reverse those priorities.