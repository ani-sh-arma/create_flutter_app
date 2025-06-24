import 'package:prompts/prompts.dart' as prompts;
import 'config.dart';

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

  final routingNames = RoutingOption.values.map((e) => e.name).toList();
  final routingChoice = prompts.choose<String>(
    'Choose routing:',
    routingNames,
    defaultsTo: RoutingOption.none.name,
  );
  final routing = RoutingOption.values.firstWhere(
    (e) => e.name == routingChoice,
  );

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
