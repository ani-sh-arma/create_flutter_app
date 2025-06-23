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

https://pub.dev/packages/create_flutter_app

### Install globally

```sh
dart pub global activate create_flutter_app
```


### The options for configuration provided by create_flutter_app are:

- Project Name
- State Management (none, provider, riverpod, bloc)
- Routing (none, navigator2, goRouter, autoRoute)
- Firebase (yes, no)
- Select firebase services (firestore, auth, storage, messaging) only if firebase is set to true
- Use flex_color_scheme for theming (yes, no)
- Create a LocalStorageService using shared prefs (yes, no)
- Initialize SizeUtils for responsive design (yes, no)
- Include Common Custom Widgets (yes, no)
