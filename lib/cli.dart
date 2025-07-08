import 'package:prompts/prompts.dart' as prompts;
import 'config.dart';
import 'logger.dart';

/// Prompts the user for various Flutter project configuration preferences
/// through interactive command-line questions.
///
/// This function guides the user through selecting:
/// - Project name
/// - State management solution (Provider, Riverpod, BLoC, GetX, or none)
/// - Routing solution (GoRouter, AutoRoute, Navigator 2.0, or none)
/// - Whether to use `flex_color_scheme` for theming
/// - Whether to create a `LocalStorageService` using `shared_preferences`
/// - Whether to initialize `SizeUtils` for responsive design
/// - Whether to initialize `flutter_dotenv` for environment variables
///
/// Returns a [Config] object containing the user's selected preferences.
Future<Config> promptUserPreferences() async {
  final name = prompts.get(
    'Project Name',
    defaultsTo: 'my_project',
    validate: (p0) {
      if (p0.isEmpty) {
        logError("Project name cannot be empty");
        return false;
      }
      if (p0.contains(' ')) {
        logError("Project name cannot contain spaces");
        return false;
      }
      if (p0.contains('-')) {
        logError(
          "Project name cannot contain dashes, try using underscores instead",
        );
        return false;
      }
      return true;
    },
  );

  final stateNames = StateManagementOption.values.map((e) => e.name).toList();
  StateManagementOption state;
  while (true) {
    final stateChoice = prompts.choose<String>(
      'Choose state management:',
      stateNames,
      defaultsTo: StateManagementOption.none.name,
    );
    state = StateManagementOption.values.firstWhere(
      (e) => e.name == stateChoice,
    );

    if (state == StateManagementOption.getx) {
      logError("❌ Wrong choice, Try using a better state management solution.");
    } else {
      break;
    }
  }

  String routingChoice = "";
  RoutingOption routing = RoutingOption.none;

  final routingNames = RoutingOption.values.map((e) => e.name).toList();
  routingChoice =
      prompts.choose<String>(
        'Choose routing:',
        routingNames,
        defaultsTo: RoutingOption.none.name,
      ) ??
      "none";
  routing = RoutingOption.values.firstWhere((e) => e.name == routingChoice);

  final useFlexColorScheme = prompts.getBool(
    'Use flex_color_scheme for theming?',
    defaultsTo: false,
  );
  final createLocalStorageService = prompts.getBool(
    'Create a LocalStorageService using shared prefs?',
    defaultsTo: false,
  );
  final initializeSizeUtils = prompts.getBool(
    'Initialize SizeUtils for responsive design?',
    defaultsTo: false,
  );
  final initializeDotEnv = prompts.getBool(
    'Initialize DotEnv for environment variables?',
    defaultsTo: false,
  );

  return Config(
    projectName: name,
    stateManagement: state,
    routing: routing,
    useFlexColorScheme: useFlexColorScheme,
    createLocalStorageService: createLocalStorageService,
    initializeSizeUtils: initializeSizeUtils,
    initializeDotEnv: initializeDotEnv,
  );
}
