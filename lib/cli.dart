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
        return false;
      }
      if (p0.contains(' ')) {
        return false;
      }
      if (p0.contains('-')) {
        return false;
      }
      return true;
    },
  );

  final stateNames = StateManagementOption.values.map((e) => e.name).toList();
  final stateChoice = prompts.choose<String>(
    'Choose state management:',
    stateNames,
    defaultsTo: StateManagementOption.none.name,
  );
  final state = StateManagementOption.values.firstWhere(
    (e) => e.name == stateChoice,
  );

  String routingChoice = "";
  RoutingOption routing = RoutingOption.none;

  if (state != StateManagementOption.getx) {
    final routingNames = RoutingOption.values.map((e) => e.name).toList();
    routingChoice =
        prompts.choose<String>(
          'Choose routing:',
          routingNames,
          defaultsTo: RoutingOption.none.name,
        ) ??
        "none";
    routing = RoutingOption.values.firstWhere((e) => e.name == routingChoice);
  } else {
    logInfo(
      'Note: GetX does not support multiple pages out of the box. You will need to manage routing manually.',
    );
  }

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
