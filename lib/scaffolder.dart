import 'dart:async';
import 'dart:io';

import 'package:create_flutter_app/config.dart';
import 'package:create_flutter_app/logger.dart';
import 'package:create_flutter_app/templates.dart';

// ---------------------------------------------------------------------------
// Typed scaffold context — replaces the brittle Map<String, String> pattern.
// ---------------------------------------------------------------------------

/// Holds the mutable state that is built up as each `_handle*` function runs.
class _ScaffoldContext {
  String mainFileContent;
  String mainImports;
  String homePageContent;

  _ScaffoldContext({
    required this.mainFileContent,
    required this.mainImports,
    required this.homePageContent,
  });
}

// ---------------------------------------------------------------------------
// Public entry-point
// ---------------------------------------------------------------------------

/// Scaffolds a new Flutter project based on the provided [config].
///
/// When [config.dryRun] is `true` the function only prints a summary of what
/// would be created and exits without touching the file system.
///
/// This function orchestrates the entire project creation process:
/// 1. Creates the base Flutter project via `flutter create`.
/// 2. Adds necessary dependencies via `flutter pub add`.
/// 3. Generates and modifies project files.
/// 4. Formats the newly generated project with `dart format`.
Future<void> scaffoldProject(Config config) async {
  if (config.dryRun) {
    _printDryRunSummary(config);
    return;
  }

  final projectDir = Directory(config.projectName);
  late final StreamSubscription<ProcessSignal> sigintSubscription;

  // Register a SIGINT handler so Ctrl+C cleans up any partial output.
  sigintSubscription = ProcessSignal.sigint.watch().listen((_) async {
    logWarning('Scaffolding cancelled. Cleaning up...');
    if (await projectDir.exists()) {
      await projectDir.delete(recursive: true);
      logSuccess('Cleaned up partial project directory.');
    }
    exit(130);
  });

  try {
    logInfo('Creating project...');
    await _createProject(config);

    logInfo('Adding dependencies...');
    await _addDependencies(config);

    logInfo('Generating project files...');
    await _generateProjectFiles(config);

    logInfo('Formatting project...');
    final fmtResult = await Process.run(
      'dart',
      ['format', '.'],
      runInShell: true,
      workingDirectory: projectDir.path,
    );

    if (fmtResult.exitCode == 0) {
      logInfo('[ Formatted Project ]\n${fmtResult.stdout}');
    } else {
      logError('[ Formatting Project Failed ]\n${fmtResult.stderr}');
      exit(1);
    }

    logSuccess('Project created successfully!');
  } finally {
    await sigintSubscription.cancel();
  }
}

// ---------------------------------------------------------------------------
// Dry-run output
// ---------------------------------------------------------------------------

void _printDryRunSummary(Config config) {
  logInfo('=== DRY RUN — nothing will be created ===\n');
  logInfo('Project name   : ${config.projectName}');
  logInfo('State mgmt     : ${config.stateManagement.name}');
  logInfo('Routing        : ${config.routing.name}');
  logInfo('FlexColorScheme: ${config.useFlexColorScheme}');
  logInfo('LocalStorage   : ${config.createLocalStorageService}');
  logInfo('SizeUtils      : ${config.initializeSizeUtils}');
  logInfo('DotEnv         : ${config.initializeDotEnv}');

  final deps = _computeDependencies(config);
  if (deps.isNotEmpty) {
    logInfo('\nDependencies to add: ${deps.join(', ')}');
  }

  logInfo('\nFiles that would be generated:');
  logInfo('  ${config.projectName}/lib/main.dart');
  logInfo('  ${config.projectName}/lib/home_page.dart');
  logInfo('  ${config.projectName}/lib/constants/colors.dart');
  logInfo('  ${config.projectName}/lib/constants/assets.dart');

  // Folder structure
  for (final dir in ['features', 'models', 'services', 'utils', 'constants']) {
    logInfo('  ${config.projectName}/lib/$dir/  (directory)');
  }

  if (config.initializeSizeUtils) {
    logInfo('  ${config.projectName}/lib/utils/size_utils.dart');
  }
  if (config.initializeDotEnv) {
    logInfo('  ${config.projectName}/.env');
  }
  if (config.createLocalStorageService) {
    logInfo('  ${config.projectName}/lib/services/local_storage_service.dart');
  }
  if (config.stateManagement == StateManagementOption.provider) {
    logInfo('  ${config.projectName}/lib/providers/counter_provider.dart');
  }
  if (config.stateManagement == StateManagementOption.riverpod) {
    logInfo('  ${config.projectName}/lib/providers/counter_notifier.dart');
  }
  if (config.stateManagement == StateManagementOption.bloc) {
    logInfo('  ${config.projectName}/lib/cubits/counter_cubit.dart');
  }
  if (config.routing == RoutingOption.goRouter) {
    logInfo('  ${config.projectName}/lib/router/router.dart');
    logInfo('  ${config.projectName}/lib/router/routes.dart');
  }
  if (config.routing == RoutingOption.autoRoute) {
    logInfo('  ${config.projectName}/lib/router/router.dart');
  }
  if (config.useFlexColorScheme) {
    logInfo('  ${config.projectName}/lib/constants/theme.dart');
  }
}

// ---------------------------------------------------------------------------
// flutter create
// ---------------------------------------------------------------------------

Future<void> _createProject(Config config) async {
  final projectDir = Directory(config.projectName);

  if (await projectDir.exists()) {
    logError(
      "Error: A project named '${config.projectName}' already exists. "
      'Please delete it or choose a different name.',
    );
    exit(1);
  }

  try {
    final result = await Process.run('flutter', [
      'create',
      config.projectName,
    ], runInShell: true);

    if (result.exitCode == 0) {
      logInfo('[ Creating Project ]\n${result.stdout}');
    } else {
      logError('[ Creating Project Failed ]\n${result.stderr}');
      exit(1);
    }
  } on ProcessException catch (e) {
    logError(
      'Error: Flutter command not found. Please ensure Flutter SDK is installed '
      'and added to PATH.\nDetails: ${e.message}',
    );
    exit(1);
  }
}

// ---------------------------------------------------------------------------
// flutter pub add
// ---------------------------------------------------------------------------

/// Returns the list of packages that need to be added for [config].
List<String> _computeDependencies(Config config) {
  final deps = <String>[];

  switch (config.stateManagement) {
    case StateManagementOption.none:
      break;
    case StateManagementOption.provider:
      deps.add('provider');
    case StateManagementOption.riverpod:
      deps.add('flutter_riverpod');
    case StateManagementOption.bloc:
      deps.add('flutter_bloc');
  }

  switch (config.routing) {
    case RoutingOption.none:
      break;
    case RoutingOption.goRouter:
      deps.add('go_router');
    case RoutingOption.autoRoute:
      deps.add('auto_route');
  }

  if (config.useFlexColorScheme) deps.add('flex_color_scheme');
  if (config.createLocalStorageService) deps.add('shared_preferences');
  if (config.initializeDotEnv) deps.add('flutter_dotenv');

  return deps;
}

Future<void> _addDependencies(Config config) async {
  final deps = _computeDependencies(config);

  if (deps.isNotEmpty) {
    logInfo('Adding dependencies: $deps');
    final projectDir = Directory(config.projectName);
    final result = await Process.run(
      'flutter',
      ['pub', 'add', ...deps],
      runInShell: true,
      workingDirectory: projectDir.path,
    );

    if (result.exitCode == 0) {
      logInfo('[ Adding Dependencies ]\n${result.stdout}');
    } else {
      logError('[ Adding Dependencies Failed ]\n${result.stderr}');
      exit(1);
    }
  }

  // AutoRoute requires dev dependencies for code generation.
  if (config.routing == RoutingOption.autoRoute) {
    logInfo('Adding AutoRoute dev dependencies...');
    final projectDir = Directory(config.projectName);
    final devResult = await Process.run(
      'flutter',
      ['pub', 'add', '--dev', 'auto_route_generator', 'build_runner'],
      runInShell: true,
      workingDirectory: projectDir.path,
    );

    if (devResult.exitCode == 0) {
      logInfo('[ Adding Dev Dependencies ]\n${devResult.stdout}');
    } else {
      logError('[ Adding Dev Dependencies Failed ]\n${devResult.stderr}');
      exit(1);
    }
  }
}

// ---------------------------------------------------------------------------
// File generation
// ---------------------------------------------------------------------------

Future<void> _generateProjectFiles(Config config) async {
  final projectDir = Directory(config.projectName);

  // Scaffold the standard lib/ folder structure.
  await _createFolderStructure(projectDir);

  var ctx = _ScaffoldContext(
    mainFileContent: Templates.mainTemplate,
    mainImports: '',
    homePageContent: Templates.homePageContent,
  );

  ctx.mainFileContent = _replaceAsyncPlaceholder(ctx.mainFileContent, config);

  ctx = await _handleUtilityFiles(config, projectDir, ctx);
  ctx = await _handleStateManagementFiles(config, projectDir, ctx);
  ctx = await _handleRoutingFiles(config, projectDir, ctx);
  ctx = await _handleThemeFiles(config, projectDir, ctx);

  await _createConstantFiles(projectDir);
  await _writeFinalProjectFiles(projectDir, ctx, config);
}

// ---------------------------------------------------------------------------
// Folder structure
// ---------------------------------------------------------------------------

/// Creates the standard `lib/` folder structure with `.gitkeep` placeholders.
Future<void> _createFolderStructure(Directory projectDir) async {
  const dirs = ['features', 'models', 'services', 'utils', 'constants'];
  for (final dir in dirs) {
    final d = Directory('${projectDir.path}/lib/$dir');
    await d.create(recursive: true);
    // Place a .gitkeep so git tracks the empty directory.
    final gitkeep = File('${d.path}/.gitkeep');
    if (!await gitkeep.exists()) {
      await gitkeep.create();
    }
    logInfo('Created directory: ${d.path}');
  }
}

// ---------------------------------------------------------------------------
// Placeholder helpers
// ---------------------------------------------------------------------------

String _replaceAsyncPlaceholder(String mainFileContent, Config config) {
  final needsAsync =
      config.initializeDotEnv || config.createLocalStorageService;
  return mainFileContent.replaceAll('{{async}}', needsAsync ? 'async' : '');
}

// ---------------------------------------------------------------------------
// Utility files (SizeUtils, .env, LocalStorageService)
// ---------------------------------------------------------------------------

Future<_ScaffoldContext> _handleUtilityFiles(
  Config config,
  Directory projectDir,
  _ScaffoldContext ctx,
) async {
  if (config.initializeSizeUtils) {
    ctx.mainImports += "import 'utils/size_utils.dart';\n";
    // SizeUtils.init() is injected via MaterialApp.builder (see
    // _handleRoutingFiles / _handleStateManagementFiles) so that it runs
    // inside a widget tree that has MediaQuery available.
    ctx.mainFileContent = ctx.mainFileContent.replaceAll('{{sizeUtils}}', '');

    final sizeUtilsFile = File('${projectDir.path}/lib/utils/size_utils.dart');
    await sizeUtilsFile.create(recursive: true);
    await sizeUtilsFile.writeAsString(Templates.sizeUtilsContent);
    logInfo('Generated: ${sizeUtilsFile.path}');
  } else {
    ctx.mainFileContent = ctx.mainFileContent.replaceAll('{{sizeUtils}}', '');
  }

  if (config.initializeDotEnv) {
    ctx.mainImports += "import 'package:flutter_dotenv/flutter_dotenv.dart';\n";
    ctx.mainFileContent = ctx.mainFileContent.replaceAll(
      '{{dotEnv}}',
      "await dotenv.load(fileName: '.env');",
    );

    final dotEnvFile = File('${projectDir.path}/.env');
    await dotEnvFile.create(recursive: true);
    await dotEnvFile.writeAsString(Templates.dotEnvContent);
    logInfo('Generated: ${dotEnvFile.path}');

    // Add .env to the project's .gitignore so it is never committed.
    final gitignoreFile = File('${projectDir.path}/.gitignore');
    if (await gitignoreFile.exists()) {
      final existing = await gitignoreFile.readAsString();
      if (!existing.contains('.env')) {
        await gitignoreFile.writeAsString(
          '$existing\n# Environment variables — never commit these.\n.env\n*.env\n',
        );
        logInfo('Added .env entries to ${gitignoreFile.path}');
      }
    }
  } else {
    ctx.mainFileContent = ctx.mainFileContent.replaceAll('{{dotEnv}}', '');
  }

  if (config.createLocalStorageService) {
    ctx.mainImports += "import 'services/local_storage_service.dart';\n";
    ctx.mainFileContent = ctx.mainFileContent.replaceAll(
      '{{localStorage}}',
      'await LocalStorageService.init();',
    );

    final localStorageFile = File(
      '${projectDir.path}/lib/services/local_storage_service.dart',
    );
    await localStorageFile.create(recursive: true);
    await localStorageFile.writeAsString(Templates.localStorageServiceContent);
    logInfo('Generated: ${localStorageFile.path}');
  } else {
    ctx.mainFileContent = ctx.mainFileContent.replaceAll(
      '{{localStorage}}',
      '',
    );
  }

  return ctx;
}

// ---------------------------------------------------------------------------
// State management files
// ---------------------------------------------------------------------------

Future<_ScaffoldContext> _handleStateManagementFiles(
  Config config,
  Directory projectDir,
  _ScaffoldContext ctx,
) async {
  final materialApp = _buildMaterialAppContent(config);
  final materialAppChild = _materialAppChildExpression(materialApp);

  switch (config.stateManagement) {
    case StateManagementOption.provider:
      ctx.mainImports += "import 'package:provider/provider.dart';\n";
      ctx.mainImports += "import 'providers/counter_provider.dart';\n";
      ctx.mainFileContent = ctx.mainFileContent.replaceAll(
        '{{materialAppWrapper}}',
        'MultiProvider(\n'
            '    providers: [\n'
            '      ChangeNotifierProvider(create: (_) => CounterProvider()),\n'
            '      // Add more providers here.\n'
            '    ],\n'
            '    child: $materialAppChild\n'
            '  );',
      );

      final counterProviderFile = File(
        '${projectDir.path}/lib/providers/counter_provider.dart',
      );
      await counterProviderFile.create(recursive: true);
      await counterProviderFile.writeAsString(
        StateManagementTemplates.counterProviderContent,
      );
      logInfo('Generated: ${counterProviderFile.path}');

      ctx.homePageContent = StateManagementTemplates.providerHomePageContent;

    case StateManagementOption.riverpod:
      ctx.mainImports +=
          "import 'package:flutter_riverpod/flutter_riverpod.dart';\n";
      ctx.mainFileContent = ctx.mainFileContent.replaceAll(
        '{{materialAppWrapper}}',
        'ProviderScope(\n'
            '    child: $materialAppChild\n'
            '  );',
      );

      final counterNotifierFile = File(
        '${projectDir.path}/lib/providers/counter_notifier.dart',
      );
      await counterNotifierFile.create(recursive: true);
      await counterNotifierFile.writeAsString(
        StateManagementTemplates.counterNotifierContent,
      );
      logInfo('Generated: ${counterNotifierFile.path}');

      ctx.homePageContent = StateManagementTemplates.riverpodHomePageContent;

    case StateManagementOption.bloc:
      ctx.mainImports += "import 'package:flutter_bloc/flutter_bloc.dart';\n";
      ctx.mainImports += "import 'cubits/counter_cubit.dart';\n";
      ctx.mainFileContent = ctx.mainFileContent.replaceAll(
        '{{materialAppWrapper}}',
        'MultiBlocProvider(\n'
            '    providers: [\n'
            '      BlocProvider(create: (_) => CounterCubit()),\n'
            '      // Add more blocs here.\n'
            '    ],\n'
            '    child: $materialAppChild\n'
            '  );',
      );

      final counterCubitFile = File(
        '${projectDir.path}/lib/cubits/counter_cubit.dart',
      );
      await counterCubitFile.create(recursive: true);
      await counterCubitFile.writeAsString(
        StateManagementTemplates.cubitTemplate,
      );
      logInfo('Generated: ${counterCubitFile.path}');

      ctx.homePageContent = StateManagementTemplates.blocHomePageContent;

    case StateManagementOption.none:
      ctx.mainFileContent = ctx.mainFileContent.replaceAll(
        '{{materialAppWrapper}}',
        materialApp,
      );
  }

  return ctx;
}

// ---------------------------------------------------------------------------
// Routing files
// ---------------------------------------------------------------------------

Future<_ScaffoldContext> _handleRoutingFiles(
  Config config,
  Directory projectDir,
  _ScaffoldContext ctx,
) async {
  switch (config.routing) {
    case RoutingOption.goRouter:
      ctx.mainImports += "import 'router/router.dart';\n";

      final goRouterFile = File('${projectDir.path}/lib/router/router.dart');
      await goRouterFile.create(recursive: true);
      await goRouterFile.writeAsString(Templates.goRouterContent);
      logInfo('Generated: ${goRouterFile.path}');

      final routeNamesFile = File('${projectDir.path}/lib/router/routes.dart');
      await routeNamesFile.create(recursive: true);
      await routeNamesFile.writeAsString(Templates.routeNames);
      logInfo('Generated: ${routeNamesFile.path}');

      ctx.mainFileContent = ctx.mainFileContent
          .replaceAll('{{materialApp}}', 'MaterialApp.router')
          .replaceAll('{{router}}', 'routerConfig: appRouter,')
          .replaceAll('{{home}}', '');

    case RoutingOption.autoRoute:
      ctx.mainImports += "import 'router/router.dart';\n";

      final autoRouterFile = File('${projectDir.path}/lib/router/router.dart');
      await autoRouterFile.create(recursive: true);
      await autoRouterFile.writeAsString(Templates.autoRouterContent);
      logInfo('Generated: ${autoRouterFile.path}');

      // AutoRoute home page needs @RoutePage() annotation.
      ctx.homePageContent = StateManagementTemplates.autoRouteHomePageContent;

      ctx.mainFileContent = ctx.mainFileContent
          .replaceAll('{{materialApp}}', 'MaterialApp.router')
          .replaceAll(
            '{{router}}',
            'routerDelegate: appRouter.delegate(),\n'
                '    routeInformationParser: appRouter.defaultRouteParser(),',
          )
          .replaceAll('{{home}}', '');

    case RoutingOption.none:
      ctx.mainImports += "import 'home_page.dart';\n";
      ctx.mainFileContent = ctx.mainFileContent
          .replaceAll('{{materialApp}}', 'MaterialApp')
          .replaceAll('{{router}}', '')
          .replaceAll('{{home}}', 'home: const HomePage(),');
  }

  return ctx;
}

// ---------------------------------------------------------------------------
// Theme files
// ---------------------------------------------------------------------------

Future<_ScaffoldContext> _handleThemeFiles(
  Config config,
  Directory projectDir,
  _ScaffoldContext ctx,
) async {
  if (config.useFlexColorScheme) {
    ctx.mainImports += "import 'constants/theme.dart';\n";
    ctx.mainFileContent = ctx.mainFileContent.replaceAll(
      '{{theme}}',
      'theme: AppTheme.light,\n    darkTheme: AppTheme.dark,',
    );

    final appThemeFile = File('${projectDir.path}/lib/constants/theme.dart');
    await appThemeFile.create(recursive: true);
    await appThemeFile.writeAsString(Templates.appThemeContent);
    logInfo('Generated: ${appThemeFile.path}');
  } else {
    ctx.mainFileContent = ctx.mainFileContent.replaceAll('{{theme}}', '');
  }

  return ctx;
}

// ---------------------------------------------------------------------------
// Constant files
// ---------------------------------------------------------------------------

Future<void> _createConstantFiles(Directory projectDir) async {
  final colorsFile = File('${projectDir.path}/lib/constants/colors.dart');
  await colorsFile.create(recursive: true);
  await colorsFile.writeAsString(Templates.colorsContent);
  logInfo('Generated: ${colorsFile.path}');

  final assetsFile = File('${projectDir.path}/lib/constants/assets.dart');
  await assetsFile.create(recursive: true);
  await assetsFile.writeAsString(Templates.assetsContent);
  logInfo('Generated: ${assetsFile.path}');
}

// ---------------------------------------------------------------------------
// Final file writing
// ---------------------------------------------------------------------------

Future<void> _writeFinalProjectFiles(
  Directory projectDir,
  _ScaffoldContext ctx,
  Config config,
) async {
  // Replace remaining top-level placeholders.
  var mainContent = ctx.mainFileContent
      .replaceAll('{{imports}}', ctx.mainImports)
      .replaceAll('{{title}}', config.projectName);

  // Clean up any stray un-replaced placeholders.
  mainContent = mainContent
      .replaceAll('{{sizeUtils}}', '')
      .replaceAll('{{dotEnv}}', '')
      .replaceAll('{{localStorage}}', '')
      .replaceAll('{{theme}}', '')
      .replaceAll('{{home}}', '')
      .replaceAll('{{router}}', '')
      .replaceAll('{{builder}}', '');

  final mainFile = File('${projectDir.path}/lib/main.dart');
  await mainFile.writeAsString(mainContent);
  logInfo('Generated: ${mainFile.path}');

  final homePageFile = File('${projectDir.path}/lib/home_page.dart');
  await homePageFile.writeAsString(ctx.homePageContent);
  logInfo('Generated: ${homePageFile.path}');
}

// ---------------------------------------------------------------------------
// MaterialApp content builder
// ---------------------------------------------------------------------------

/// Builds the MaterialApp (or MaterialApp.router) widget string with all
/// placeholders filled in.  The [config.initializeSizeUtils] flag injects a
/// `builder:` callback that gives [SizeUtils.init] a proper [MediaQuery]
/// context — something that is not available when calling it directly from
/// [MyApp.build].
String _buildMaterialAppContent(Config config) {
  final builderProp =
      config.initializeSizeUtils
          ? 'builder: (context, child) {\n'
              '        SizeUtils.init(context);\n'
              '        return child ?? const SizedBox.shrink();\n'
              '      },'
          : '';

  return Templates.materialAppContent.replaceAll('{{builder}}', builderProp)
  // Routing / home placeholders are resolved later in _handleRoutingFiles.
  // Theme is resolved later in _handleThemeFiles.
  // Keep remaining placeholders intact so downstream handlers can fill them.
  ;
}

/// Removes the trailing semicolon so the MaterialApp expression can be nested
/// inside another widget, such as ProviderScope or MultiProvider.
String _materialAppChildExpression(String materialApp) {
  return materialApp.replaceFirst(RegExp(r';\s*$'), '');
}
