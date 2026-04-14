## 1.3.0

- **Removed** GetX state management option.
- **Added** AutoRoute as a routing option, with automatic `auto_route_generator` and `build_runner` dev-dependency setup.
- **Added** non-interactive CLI flags: `--name`, `--state-management`, `--routing`, `--flex-color-scheme`, `--local-storage`, `--size-utils`, `--dotenv`.
- **Added** `--dry-run` flag to preview scaffolding output without touching the file system.
- **Added** `--version` (`-v`) flag to print the tool version.
- **Added** project name validation (snake_case, no reserved Dart keywords, max 64 chars).
- **Added** standard `lib/` folder structure: `features/`, `models/`, `services/`, `utils/`, `constants/` (each tracked with `.gitkeep`).
- **Added** `flex_color_scheme` theming support with a pre-configured `AppTheme` (light + dark).
- **Added** `LocalStorageService` scaffold using `shared_preferences`.
- **Added** `SizeUtils` responsive design helper.
- **Added** `flutter_dotenv` environment variable setup (`.env` auto-added to `.gitignore`).
- **Added** BLoC / Cubit state management scaffolding with a `CounterCubit` example.
- **Added** Riverpod scaffolding using the modern `NotifierProvider` API.
- **Added** `dart format` pass applied to the generated project after scaffolding.
- **Improved** typed scaffold context to replace brittle `Map<String, String>` pattern.
- **Improved** SIGINT handler for clean-up of partial project directories on Ctrl+C.

## 1.0.0

- Initial release.
