# create_flutter_app

A simple CLI tool to scaffold Flutter projects with custom setups. Inspired by `create-t3-app`, but built for Flutter!

---

## 🚀 Features

- Interactive prompts to configure your Flutter project
- Add state management, routing, and project structure
- One-liner setup from anywhere

---

## 🧪 Getting Started

### Check it out on pub.dev

You can find the `create_flutter_app` package on [pub.dev](https://pub.dev/packages/create_flutter_app).

### Install globally

To use the CLI tool, you need to activate it globally using Dart's package manager:

```sh
dart pub global activate create_flutter_app
```

### Usage

Once installed, you can run the tool from any directory:

```sh
create_flutter_app
```

This will start an interactive prompt that guides you through the project setup.

#### Interactive Prompts:

The `create_flutter_app` tool provides the following configuration options:

*   **Project Name:** The name of your new Flutter project. This will also be used as the directory name.
*   **State Management:** Choose your preferred state management solution:
    *   `none`: No specific state management boilerplate.
    *   `provider`: Integrates the `provider` package for simple state management.
    *   `riverpod`: Sets up `flutter_riverpod` for a more robust and testable approach.
    *   `bloc`: Configures the project with the `bloc` package for reactive state management.
*   **Routing:** Select a routing solution for navigation:
    *   `none`: Basic Flutter Navigator 1.0.
    *   `navigator2`: Sets up Navigator 2.0 with a basic router delegate.
    *   `goRouter`: Integrates the `go_router` package for declarative routing.
    *   `autoRoute`: Configures `auto_route` for code-generated routing.
*   **Use `flex_color_scheme` for theming:** (yes/no)
    *   If `yes`, the project will include `flex_color_scheme` for advanced theming capabilities.
*   **Create a `LocalStorageService` using `shared_prefs`:** (yes/no)
    *   If `yes`, a utility service for local data persistence using `shared_preferences` will be generated.
*   **Initialize `SizeUtils` for responsive design:** (yes/no)
    *   If `yes`, a helper class for responsive UI adjustments based on screen size will be included.
*   **Include Common Custom Widgets:** (yes/no)
    *   If `yes`, a set of commonly used custom widgets (e.g., custom buttons, text fields) will be added to the project.

---

**Example Usage (GIF/Screenshot Placeholder):**
*(Insert a GIF or screenshot demonstrating the interactive prompts and a successful project creation here.)*
