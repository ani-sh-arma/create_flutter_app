/// Defines the available state management options for the Flutter project.
enum StateManagementOption {
  /// No specific state management solution.
  none,

  /// Uses the `provider` package.
  provider,

  /// Uses the `flutter_riverpod` package.
  riverpod,

  /// Uses the `flutter_bloc` package.
  bloc,
}

/// Defines the available routing options for the Flutter project.
enum RoutingOption {
  /// No specific routing solution (uses basic Navigator 1.0).
  none,

  /// Uses the `go_router` package for declarative routing.
  goRouter,

  /// Uses the `auto_route` package with code generation.
  autoRoute,
}

/// Represents the complete configuration for a new Flutter project.
///
/// This class holds all the choices made by the user through the CLI prompts,
/// which are then used by the scaffolder to generate the project.
class Config {
  /// The name of the Flutter project.
  final String projectName;

  /// The chosen state management solution.
  final StateManagementOption stateManagement;

  /// The chosen routing solution.
  final RoutingOption routing;

  /// Whether to include `flex_color_scheme` for theming.
  final bool useFlexColorScheme;

  /// Whether to create a `LocalStorageService` using `shared_preferences`.
  final bool createLocalStorageService;

  /// Whether to initialize `SizeUtils` for responsive design.
  final bool initializeSizeUtils;

  /// Whether to initialize `flutter_dotenv` for environment variables.
  final bool initializeDotEnv;

  /// When true, prints what would be created without actually running any
  /// commands or writing any files.
  final bool dryRun;

  /// Creates a new [Config] instance with the specified project preferences.
  Config({
    required this.projectName,
    required this.stateManagement,
    required this.routing,
    required this.useFlexColorScheme,
    required this.createLocalStorageService,
    required this.initializeSizeUtils,
    required this.initializeDotEnv,
    this.dryRun = false,
  });

  @override
  String toString() {
    return '''
      Project: $projectName
      State Management: ${stateManagement.name}
      Routing: ${routing.name}
      Use FlexColorScheme: ${useFlexColorScheme ? "Yes" : "No"}
      Create LocalStorageService: ${createLocalStorageService ? "Yes" : "No"}
      Initialize SizeUtils: ${initializeSizeUtils ? "Yes" : "No"}
      Initialize DotEnv: ${initializeDotEnv ? "Yes" : "No"}
      Dry Run: ${dryRun ? "Yes" : "No"}
    ''';
  }
}
