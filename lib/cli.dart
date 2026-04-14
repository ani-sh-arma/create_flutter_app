import 'package:args/args.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'config.dart';
import 'logger.dart';

/// Reserved Dart keywords that cannot be used as package names.
const _dartKeywords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'main',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'type',
  'typedef',
  'var',
  'void',
  'when',
  'with',
  'while',
  'yield',
};

/// Maximum allowed length for a Flutter project name.
const _maxNameLength = 64;

/// Validates a project name string.
///
/// Returns `null` if the name is valid, otherwise returns a human-readable
/// error message describing why the name is invalid.
String? validateProjectName(String name) {
  if (name.isEmpty) return 'Project name cannot be empty.';
  if (name.length > _maxNameLength) {
    return 'Project name must be at most $_maxNameLength characters.';
  }
  if (name.contains(' ')) return 'Project name cannot contain spaces.';
  if (name.contains('-')) {
    return 'Project name cannot contain dashes — use underscores instead.';
  }
  if (RegExp(r'[A-Z]').hasMatch(name)) {
    return 'Project name must be lowercase (Flutter requires snake_case).';
  }
  if (RegExp(r'^\d').hasMatch(name)) {
    return 'Project name cannot start with a digit.';
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    return 'Project name may only contain lowercase letters, digits, and underscores.';
  }
  if (_dartKeywords.contains(name)) {
    return '"$name" is a reserved Dart keyword and cannot be used as a project name.';
  }
  return null;
}

/// Builds and returns the [ArgParser] used by the CLI entry-point.
ArgParser buildArgParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message and exit.',
    )
    ..addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the tool version and exit.',
    )
    ..addFlag(
      'dry-run',
      negatable: false,
      help:
          'Print what would be created without actually running any commands or writing any files.',
    )
    ..addOption(
      'name',
      abbr: 'n',
      help: 'Project name (snake_case). Skips the interactive name prompt.',
    )
    ..addOption(
      'state-management',
      abbr: 's',
      allowed: StateManagementOption.values.map((e) => e.name).toList(),
      help: 'State management solution to use.',
    )
    ..addOption(
      'routing',
      abbr: 'r',
      allowed: RoutingOption.values.map((e) => e.name).toList(),
      help: 'Routing solution to use.',
    )
    ..addFlag(
      'flex-color-scheme',
      defaultsTo: false,
      help: 'Include flex_color_scheme for theming.',
    )
    ..addFlag(
      'local-storage',
      defaultsTo: false,
      help: 'Generate a LocalStorageService using shared_preferences.',
    )
    ..addFlag(
      'size-utils',
      defaultsTo: false,
      help: 'Generate SizeUtils helper for responsive design.',
    )
    ..addFlag(
      'dotenv',
      defaultsTo: false,
      help: 'Generate a .env file and flutter_dotenv setup.',
    );
}

/// Prompts the user for various Flutter project configuration preferences
/// through interactive command-line questions.
///
/// When [args] provides values for individual options those prompts are
/// skipped.  When all required values are present no interactive prompts
/// are shown at all.
///
/// Returns a [Config] object containing the user's selected preferences.
Future<Config> promptUserPreferences(ArgResults args) async {
  // --- project name ---
  final String name;
  if (args['name'] != null) {
    final error = validateProjectName(args['name'] as String);
    if (error != null) {
      logError(error);
      throw ArgumentError(error);
    }
    name = args['name'] as String;
  } else {
    name = prompts.get(
      'Project Name',
      defaultsTo: 'my_project',
      validate: (p0) {
        final error = validateProjectName(p0);
        if (error != null) {
          logError(error);
          return false;
        }
        return true;
      },
    );
  }

  // --- state management ---
  final StateManagementOption state;
  if (args['state-management'] != null) {
    state = StateManagementOption.values.firstWhere(
      (e) => e.name == args['state-management'],
    );
  } else {
    final stateNames = StateManagementOption.values.map((e) => e.name).toList();
    final stateChoice = prompts.choose<String>(
      'Choose state management:',
      stateNames,
      defaultsTo: StateManagementOption.none.name,
    );
    state = StateManagementOption.values.firstWhere(
      (e) => e.name == stateChoice,
    );
  }

  // --- routing ---
  final RoutingOption routing;
  if (args['routing'] != null) {
    routing = RoutingOption.values.firstWhere((e) => e.name == args['routing']);
  } else {
    final routingNames = RoutingOption.values.map((e) => e.name).toList();
    final routingChoice =
        prompts.choose<String>(
          'Choose routing:',
          routingNames,
          defaultsTo: RoutingOption.none.name,
        ) ??
        RoutingOption.none.name;
    routing = RoutingOption.values.firstWhere((e) => e.name == routingChoice);
  }

  // --- boolean options ---
  final bool useFlexColorScheme;
  if (args.wasParsed('flex-color-scheme')) {
    useFlexColorScheme = args['flex-color-scheme'] as bool;
  } else {
    useFlexColorScheme = prompts.getBool(
      'Use flex_color_scheme for theming?',
      defaultsTo: false,
    );
  }

  final bool createLocalStorageService;
  if (args.wasParsed('local-storage')) {
    createLocalStorageService = args['local-storage'] as bool;
  } else {
    createLocalStorageService = prompts.getBool(
      'Create a LocalStorageService using shared_preferences?',
      defaultsTo: false,
    );
  }

  final bool initializeSizeUtils;
  if (args.wasParsed('size-utils')) {
    initializeSizeUtils = args['size-utils'] as bool;
  } else {
    initializeSizeUtils = prompts.getBool(
      'Initialize SizeUtils for responsive design?',
      defaultsTo: false,
    );
  }

  final bool initializeDotEnv;
  if (args.wasParsed('dotenv')) {
    initializeDotEnv = args['dotenv'] as bool;
  } else {
    initializeDotEnv = prompts.getBool(
      'Initialize flutter_dotenv for environment variables?',
      defaultsTo: false,
    );
  }

  return Config(
    projectName: name,
    stateManagement: state,
    routing: routing,
    useFlexColorScheme: useFlexColorScheme,
    createLocalStorageService: createLocalStorageService,
    initializeSizeUtils: initializeSizeUtils,
    initializeDotEnv: initializeDotEnv,
    dryRun: args['dry-run'] as bool,
  );
}
