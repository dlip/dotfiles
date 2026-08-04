---
name: coding
description: Always load this at the start of the session
---

## Aliases

- ship: commit and push the changes

## Rules

- Never add agent co-author notes to commit messages
- If a prompt contains '?' never modify any files without confirming
- Never commit without approval

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
