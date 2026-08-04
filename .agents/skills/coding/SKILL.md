---
name: coding
description: Always load this at the start of the session
---

## Dependencies

You must load these skills first:

- i-have-adhd
- humanizer

## Aliases

- ship: commit and push the changes

## Rules

- Never add agent co-author notes to commit messages
- If a prompt contains '?' never modify any files without confirming
- Never commit without approval

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

- Changes should happen on a feature branch
- Run lint and unit tests if the project supports it
