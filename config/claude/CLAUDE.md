## Communication

Be extremely concise.
Avoid unnecessary words.
Ask questions for alignment.

## Python

-  Use `uv` for python

## Testing

Prefer black-box tests that test behavior at API boundaries.
For Python, use `pytest` in a functional (not class) style with fixtures.
For tricky problems I like TDD.  I like aligning on tests first for behavior before implementing.

## Git

Don't commit to git without asking me.
Never push.
Use brief messages for small changes.

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
In the plan make sure you have a way to get live feedback about the thing we're building.  Feedback is critical to iterating to success.

### Phase 2: Execution

You do work to implement the plan, raising concerns along the way if something comes up.

### Phase 3: Testing and Iteration

Use our feedback systems (should already be implemented as part of the plan) to get feedback about how well our system works.  Iterate given that feedback.

### Phase 4: Self review

Review our work so far and see if there is anything you can clean up or simplify.  Don't use other agents at this phase.  Do this yourself.

### Phase 5: Agent Review

Spawn a new agent to review your work.  Tell the new agent (as part of your initial spawning) what you're trying to accomplish and how to review it.  Tell it to be critical.  Tell it to send a report of its findings back to you.

Close the agent when you're done.

## Github

You should have access to the github `gh` CLI and the `@mrocklin-ai` bot account.  This should give you the ability to read and comment on various repositories.  When communicating with others, please be concise and friendly.  Be sure to thank them.
