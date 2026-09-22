---
name: coding
description: Always load this at the start of the session
---

## Dependencies

You must load these skills first:

- i-have-adhd
- humanizer

## Aliases

- gn: create a new feature branch with a name that suits the request using the command `gn <branch-name>`. It may be used on its own if there is some context or at the start of a prompt relating to a new feature.
- ship:
  - review the changes, and if there are any improvements, ask the user the user if they would like you to apply them
  - commit
  - push the changes

## Rules

- Never add agent co-author notes to commit messages
- If a prompt contains '?' never modify any files without confirming
- Never commit automatically

## Style

- Less is more. Comments and messages are direct and straight to the point. This applies to code too, the simplest approach that follows clean code practices should be preferred. Minimal comments, prefer to use code structure with descriptive variable and function names instead.

## Workflow styles

The workflow style defines what is required for a change to be accepted. You must inform the user which one you have selected when this skill is loaded.

### Lazy

- Select if the current directory is:
    - ~
    - dotfiles
- Develop on the current branch
- Changes should only have light validation

### Formal (default)

- Plan your changes first, then show the user a brief summary and ask for their confirmation
- Run lint and unit tests if the project supports it
