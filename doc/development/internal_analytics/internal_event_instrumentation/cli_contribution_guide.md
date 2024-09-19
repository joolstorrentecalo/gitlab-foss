---
stage: Monitor
group: Analytics Instrumentation
info: Any user with at least the Maintainer role can merge updates to this content. For details, see https://docs.gitlab.com/ee/development/development_processes.html#development-guidelines-review.
---

# Contributing to the Internal Event CLI

## Priorities of the CLI

1. Feature parity with the instrumentation capabilities as the CLI is the intended entrypoint for all instrumentation tasks
1. Performance and manual testing are top priorities, as the CLI is primarily responsible for giving users a clean & clear UX
1. If a user opts not to use the CLI, danger/specs/pipelines still ensure definition validity/data integrity/functionality/etc

## Guiding UX Principles

- The internal events generator is a one-stop-shop for any engineering tasks related to instrumenting event-based metrics.
- Users don't need to know anything about instrumentation before running the generator.
- The generator protects the user from making mistakes, but it never blocks the user from proceeding. There is always a path forward.
- Users always know roughly how long or how much more work is ahead of them on their task.
- Using the generator isn't strictly necessary. It's a helpful tool, but not required. Invalid user-generated content should not break the generator.
- The generator is fast & does not require rails to be running. A functioning GDK should not be a requirement for usage.
- Force-exiting the generator partway through a task leaves the user's environment in a clean & valid state.
- If a user needs to know or understand something in order to complete a task in the generator, they shouldn't need to switch screens to get more information or context.
- Users should understand the consequences of selecting a particular option or inputting any text based on only the information they see on the screen.

## Interaction & Style Guide

- Color & formatting are not the exclusive mechanism to communicate information/context. Textual labels and explanations should be provided for everything.
- Select menus are preferable to plain text inputs. The first/easiest/default option in a list should be the most common use-case.
- Instead of a multi-select menu with dependencies & validations, consider using a single-select menu listing each allowable combination. This may not always work well, but it is a quicker interaction and makes the outcome of the selection clearer to the user.
- When using the CLI full-screen, each individual interaction should ideally not extend "past the fold" of the screen.
- The entrypoint flows to the CLI should be outcome-based. Each flow should have a progress bar and steps detailed at the top of each screen.
- Always print the `InternalEventsCli::Text::FEEDBACK_NOTICE` when a user exits the CLI.
- Avoid prompts that implicitly require the user to enter information multiple times. Auto-fill with defaults where possible, or use previous selections to infer information.
- It should always be possible to input any valid option. The CLI should never assume the most common use-case is always used.

## Development Practices

- Feature documentation: Co-release documentation updates with CLI updates
  - If the CLI is our recommended entrypoint for all instrumentation, it must always be feature-complete. It should
    not lag behind the documentation or the features we announce to other teams.
- CLI documentation: Rely on inline or co-located documentation of CLI code as much as possible
  - The more likely we are to stumble upon context/explanation while working on the CLI, the more likely we are to a) reduce the likelihood of unused/duplicate code and b) increase code navigability and speed of re-familiarization.
- Testing: Approach tests the same as you would for a frontend application
  - Automated tests should be primarily UX-oriented E2E tests, with supplementary edge case testing and unit tests on an as-needed basis.
  - Apply unit tests in places where they are absolutely necessary to guard against regressions.
- Verification: Always run the CLI directly when adding feature support
  - We don't want to rely only on automated tests. If our goal is great user-experience, then we as users are a critical tool in making sure everything we merge serves that goal. If it's cumbersome & annoying to manually test, then it's probably also cumbersome and annoying to use.

## FAQ

**Q:** Why don't `InternalEventsCli::Event` & `InternalEventsCli::Metric` use `Gitlab::Tracking::EventDefinition` & `Gitlab::Usage::MetricDefinition` respectively?

**A:** Using the `EventDefinition` & `MetricDefinition` classes would require GDK to be running and the rails app to be loaded. The performance of the CLI is critical to its usability, so separate classes are worth the value snappy startup times provide. Ideally, this will be refactored in time such that the same classes can be used for both the CLI & the rails app. For now, the rails app and the CLI share the `json-schemas` for the definitions as a single source of truth.
