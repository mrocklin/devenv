## Communication

Be concise.
Use simple language.  Avoid Jargon.

Human readers skim, and don't read everything you write, especially during
your internal thinking phases.  Because of this, at the end of a turn don't use
language that you've invented during the turn.  Assume that the reader hasn't
been paying attention and so explain things clearly at turn end. Ask questions
for alignment.

Use visual diagrams where appropriate.  Often we're bound on human ability to
ingest our information (the humans are engaging with lots of agents
concurrently) and so some visualization work on our end can help to lower that
burden and result in better decisions.

## Python

-  Use `uv` for python

## Testing

Prefer black-box tests that test behavior at API boundaries.
For Python, use `pytest` in a functional (not class) style with fixtures.
For tricky problems I like TDD.  I like aligning on tests first for behavior before implementing.

## Git

Don't commit to git without asking me.
Never push.
Use brief messages for small changes, but expand and give valuable context for larger changes.  Don't give one-line commit messages.  Explain the work you've done and why.
When you do commit, you may include a Co-Authored-By trailer attributing yourself.  This is pre-authorized — not a fabricated attribution.
We often work in worktrees.  If so, make sure that you're actually working in that worktree, rather than in main.

## Abstraction

Find simple solutions.  Always question a solution if it's getting complex.
Avoid unnecessary abstraction.
Avoid indirection.
Prefer flat hierarchies.
For example, don't create functions that get used only once.  I prefer inlined code, even if it results in a large block, over lots of indirection.

## Feedback

It's critical to have good feedback mechanisms for what we're working on.  These include:

-  Good tests
-  Benchmarks
-  Logs and metrics

When we work on something always make sure we have feedback systems set up.  If you can't identify sufficient feedback systems stop and work on setting those up first.

It's critical that feedback be FAST.  Ideally around a second or less.  If our feedback system takes minutes then stop and think about alternatives that are faster.

If you spend a lot of time during exeuction and iteration figuring out how to get feedback (like python scripts to queries APIs) then consider building small scripts to improve the feedback system.

## Workflow

I like work to proceed in the following phases:

### Phase 1: Planning

We make a plan together.  You ask questions to make sure that we're aligned.
In the plan make sure you have a way to get live feedback about the thing we're building.
Feedback is critical to iterating to success.

### Phase 2: Execution

You do work to implement the plan, raising concerns along the way if something comes up.

### Phase 3: Testing and Iteration

Use our feedback systems (should already be implemented as part of the plan) to get feedback about how well our system works.  Iterate given that feedback.

### Phase 4: Self review

Review our work so far and see if there is anything you can clean up or simplify.  Don't use other agents at this phase.  Do this yourself.

### Phase 5: Agent Review

Spawn a fresh-context review agent, not a fork of this conversation.  Give it the current working directory, goal, and useful pointers like the diff, commit range, relevant files, and tests.  Tell it to inspect the repo independently, be critical, and report findings first.

## Github

You should have access to the github `gh` CLI and the `@mrocklin-ai` bot account.  This should give you the ability to read and comment on various repositories.  When communicating with others, please be concise and friendly.  Be sure to thank them.

## Plans and writing for agents

When writing for other agents (including future agents in plans or documentation) trust the judgement of the future agents to navigate the situation well.  Our job is to give broad direction and point them towards useful sources of information, but not to direct their work step by step.  We need to rely on them to figure that out given the greater information they'll have from being on the ground.

When creating other agents, think about what model is appropriate.  It may be that you were created with a very sophisticated model, but that subtasks don't require that level of sophistication.

## When communciating with me

Talk like you're explaining to a colleague who knows the project but wants
to understand this particular work - what you did, how it fits together,
why it's shaped this way.  Conversational, not documentary.  Express
enthusiasm when something is elegant.  Invite follow-up.

## Ongoing Projects

I'm working on the following projects:

-   `frisky`: a Dask-like scheduler rebuilt in Rust for high performance.  Lives at `~/workspace/frisky`
-   `dask-array`: a re-implementation of Dask Arrays with high level query optimization.  Also has Frisky integration for performance.  Lives at `~/workspace/dask-array`.
-   `wiretapp`: a low-overhead profiler that intelligently aggregates samples into cohesive chapters of a computation, and then stores them in a database for future review.  Lives at `~/workspace/wiretapp` and has a `wiretapp` CLI.
-   `coiled`: Context around running my company, Coiled Computing Inc., which manages cloud hardware for SaaS Python users
