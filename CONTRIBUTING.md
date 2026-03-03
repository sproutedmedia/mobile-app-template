# Contributing to {{PROJECT_NAME}}

Thanks for your interest in contributing! This guide will help you get started.

## Quick Start

1. **Fork** the repository on GitHub
2. **Clone** your fork and run the [setup guide](docs/SETUP.md)
3. **Create a branch** from `main` (see [branch naming](#branch-naming))
4. **Make your changes** and verify they pass linting and tests
5. **Open a pull request** against `main`

## Branch Naming

Use descriptive prefixes for your branches:

```
feature/description    - New features
fix/description        - Bug fixes
refactor/description   - Code refactoring
docs/description       - Documentation updates
```

See the [Development Guide](docs/DEVELOPMENT.md#branch-naming) for full details.

## Commit Messages

Use [conventional commits](https://www.conventionalcommits.org/):

```
feat: add user authentication
fix: resolve crash on startup
refactor: extract network layer
docs: update setup guide
```

See the [Development Guide](docs/DEVELOPMENT.md#commit-messages) for more examples.

## Pre-PR Checklist

Before opening a pull request, make sure:

- [ ] Code compiles on both platforms (or the one you changed)
- [ ] Linters pass (`swiftlint` for iOS, `./gradlew ktlintCheck detekt` for Android)
- [ ] Tests pass
- [ ] No new warnings introduced
- [ ] Documentation updated if needed
- [ ] Self-reviewed your own diff

## Pull Request Process

1. Fill out the [PR template](.github/PULL_REQUEST_TEMPLATE.md) completely
2. Keep PRs focused — one feature or fix per PR
3. Link related issues using `Closes #123` in the PR description
4. Ensure CI checks pass before requesting review
5. Address review feedback promptly

## Code Review

- Be respectful and constructive
- Explain *why*, not just *what* should change
- Approve when satisfied; don't block on nitpicks
- Reviewers should respond within 2 business days

## Code Style

- **iOS**: Follow SwiftLint rules in `.swiftlint.yml`, format with SwiftFormat
- **Android**: Follow ktlint conventions, pass detekt static analysis
- **Both**: Use MVVM pattern, keep views/screens thin, business logic in ViewModels

See the [Development Guide](docs/DEVELOPMENT.md#code-style) for platform-specific details.

## Reporting Bugs

Use the [Bug Report](https://github.com/{{GITHUB_OWNER}}/{{PROJECT_NAME}}/issues/new?template=bug_report.md) template. Include:
- Platform and OS version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots or logs if applicable

## Requesting Features

Use the [Feature Request](https://github.com/{{GITHUB_OWNER}}/{{PROJECT_NAME}}/issues/new?template=feature_request.md) template. Include:
- Problem you're trying to solve
- Proposed solution
- Acceptance criteria

## Issue Labels

| Label | Purpose |
|-------|---------|
| `bug` | Something isn't working |
| `feature` | New functionality |
| `enhancement` | Improvement to existing feature |
| `docs` | Documentation changes |
| `good first issue` | Good for newcomers |

## Recognition

All contributors are recognized in release notes. Thank you for helping improve {{PROJECT_NAME}}!
