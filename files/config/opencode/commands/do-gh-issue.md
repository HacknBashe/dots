Read the gh issue that correlates with this branch (use the `github-issue-lookup` skill). Come up with a plan, work on the ticket, then commit your changes (use the `git-commit` skill), push them, and create a PR (use the `pr-create` skill).

When creating the PR, create it as a **draft** PR. Do NOT open it in the browser. Tell the `pr-create` skill to use agent/draft mode (i.e. `--draft`, no `--web`).

When you push up the branch, you should wait until it finishes building to ensure that the blazar build passes. Every time you push a branch you should request or rerequest a review from sidekick (use the `sidekick-review` skill). If there is a review pending, wait for comments before wrapping up.

Ensure the feedback makes sense before implementing it. If it doesn't leave a comment explaining why you aren't doing it. If it makes sense,
resolve the thread and implement the feedback.

After sidekick accepts the PR with no requested changes, **stop**. Leave the PR as a draft. Do NOT mark it as ready for review. The user will review it themselves and decide when to take it out of draft.
