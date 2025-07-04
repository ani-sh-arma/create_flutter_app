# Contributing to `create_flutter_app`

We welcome contributions to `create_flutter_app`! By contributing, you help us improve the tool for everyone. Please take a moment to review this document to make the contribution process as smooth as possible.

## Table of Contents

*   [How Can I Contribute?](#how-can-i-contribute)
    *   [Reporting Bugs](#reporting-bugs)
    *   [Suggesting Enhancements](#suggesting-enhancements)
    *   [Your First Code Contribution](#your-first-code-contribution)
    *   [Pull Requests](#pull-requests)
*   [Development Setup](#development-setup)
    *   [Prerequisites](#prerequisites)
    *   [Cloning the Repository](#cloning-the-repository)
    *   [Running Tests](#running-tests)
    *   [Code Style and Linting](#code-style-and-linting)

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

If you find a bug, please open an issue on our [GitHub Issues page](https://github.com/ani-sh-arma/create_flutter_app/issues). When reporting a bug, please include:

*   A clear and concise description of the bug.
*   Steps to reproduce the behavior.
*   Expected behavior.
*   Actual behavior.
*   Screenshots or error messages if applicable.
*   Your operating system and Dart SDK version.

### Suggesting Enhancements

We love new ideas! If you have a suggestion for an enhancement or a new feature, please open an issue on our [GitHub Issues page](https://github.com/ani-sh-arma/create_flutter_app/issues). Describe your idea clearly and explain why you think it would be a valuable addition.

### Your First Code Contribution

If you're looking to make your first contribution, look for issues labeled `good first issue` on our [GitHub Issues page](https://github.com/ani-sh-arma/create_flutter_app/issues).

### Pull Requests

1.  **Fork the repository** and clone it to your local machine.
2.  **Create a new branch** from `main` for your feature or bug fix: `git checkout -b feature/your-feature-name` or `git checkout -b bugfix/your-bug-fix`.
3.  **Make your changes.**
4.  **Write tests** for your changes if applicable.
5.  **Run tests** to ensure everything is working correctly.
6.  **Ensure your code adheres to the project's code style** (see [Code Style and Linting](#code-style-and-linting)).
7.  **Commit your changes** with a clear and concise commit message. Follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification if possible (e.g., `feat: add new routing option`, `fix: resolve issue with theming`).
8.  **Push your branch** to your forked repository.
9.  **Open a Pull Request** to the `main` branch of the original repository.
    *   Provide a clear title and description for your PR.
    *   Reference any related issues.

## Development Setup

### Prerequisites

*   [Dart SDK](https://dart.dev/get-dart) (version specified in `pubspec.yaml`)
*   Git

### Cloning the Repository

```sh
git clone https://github.com/ani-sh-arma/create_flutter_app.git
cd create_flutter_app
```

### Running Tests

To run the tests for the project:

```sh
dart test
```

### Code Style and Linting

This project uses `dart format` and `lints` for code style and quality. Before submitting a pull request, ensure your code is formatted and passes lint checks:

```sh
dart format .
dart analyze
```

### Generating Documentation

To generate API documentation for the project, you can use the `dart doc` tool:

```sh
dart doc
```

This will generate HTML documentation in the `doc/api` directory. You can then open `doc/api/index.html` in your browser to view the documentation.
