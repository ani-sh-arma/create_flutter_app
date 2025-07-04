import 'dart:io';
import 'dart:async';

import 'package:create_flutter_app/config.dart';
import 'package:create_flutter_app/logger.dart';
import 'package:create_flutter_app/templates.dart';

/// Scaffolds a new Flutter project based on the provided [config].
///
/// This function orchestrates the entire project creation process:
/// 1. Creates the base Flutter project.
/// 2. Adds necessary dependencies based on user choices.
/// 3. Generates and modifies project files.
/// 4. Formats the newly generated project.
Future<void> scaffoldProject(Config config) async {
  logInfo("Creating project...");
  await _createProject(config);
  logInfo("Adding dependencies...");
  await _addDependencies(config);
  logInfo("Generating project files...");
  await _generateProjectFiles(config);

  logInfo("Formatting project...");
  final projectDir = Directory(config.projectName);

  final result = await Process.run(
    'dart',
    ['format', '.'],
    runInShell: true,
    workingDirectory: projectDir.path,
  );

  if (result.exitCode == 0) {
    logInfo("[ Formatted Project ]\n${result.stdout}");
  } else {
    logError("[ Formatting Project Failed ]\n${result.stderr}");
  }
  logSuccess("Project created successfully!");
}

/// Creates a new Flutter project with the given [config.projectName].
///
/// Throws an [Exit] exception if a project with the same name already exists
/// or if the Flutter SDK is not found.
Future<void> _createProject(Config config) async {
  final projectDir = Directory(config.projectName);

  if (await projectDir.exists()) {
    logError(
      "Error: A project named '${config.projectName}' already exists. Please delete it or choose a different name.",
    );
    exit(1);
  }

  try {
    final result = await Process.run('flutter', [
      'create',
      config.projectName,
    ], runInShell: true);

    if (result.exitCode == 0) {
      logInfo("[ Creating Project ]\n${result.stdout}");
    } else {
      logError("[ Creating Project Failed ]\n${result.stderr}");
    }
  } on ProcessException catch (e) {
    logError(
      "Error: Flutter command not found. Please ensure Flutter SDK is installed and added to PATH.\nDetails: ${e.message}",
    );
    exit(1);
  }
}

/// Adds necessary Dart/Flutter dependencies to the newly created project
/// based on the user's [config].
Future<void> _addDependencies(Config config) async {
  List<String> dependencies = [];

  switch (config.stateManagement) {
    case StateManagementOption.none:
      break;
    case StateManagementOption.provider:
      dependencies.add('provider');
      break;
    case StateManagementOption.riverpod:
      dependencies.add('flutter_riverpod');
      break;
    case StateManagementOption.bloc:
      dependencies.add('flutter_bloc');
      break;
    case StateManagementOption.getx:
      dependencies.add('get');
      break;
  }

  switch (config.routing) {
    case RoutingOption.none:
      break;
    case RoutingOption.goRouter:
      dependencies.add('go_router');
      break;
  }

  if (config.useFlexColorScheme) {
    dependencies.add('flex_color_scheme');
  }

  if (config.createLocalStorageService) {
    dependencies.add('shared_preferences');
  }

  if (config.initializeDotEnv) {
    dependencies.add('flutter_dotenv');
  }

  if (dependencies.isNotEmpty) {
    logInfo("Adding dependencies: $dependencies");
    final projectDir = Directory(config.projectName);
    logDebug("[Project Dir] ${projectDir.absolute}");
    final result = await Process.run(
      'flutter',
      ['pub', 'add', ...dependencies],
      runInShell: true,
      workingDirectory: projectDir.path,
    );

    if (result.exitCode == 0) {
      logInfo("[ Adding Dependencies ]\n${result.stdout}");
    } else {
      logError("[ Adding Dependencies Failed ]\n${result.stderr}");
    }
  }
}

/// Generates and modifies various project files based on the user's [config].
///
/// This includes handling utility files, state management setup, routing,
/// theming, and creating constant files.
Future<void> _generateProjectFiles(Config config) async {
  final projectDir = Directory(config.projectName);
  String mainImports = '';
  String homePageContent = Templates.homePageContent;
  String mainFileContent = Templates.mainTemplate;

  mainFileContent = _replaceAsyncPlaceholder(mainFileContent, config);

  // Handle utility files
  final utilityFilesResult = await _handleUtilityFiles(
    config,
    projectDir,
    mainFileContent,
    mainImports,
  );
  mainFileContent = utilityFilesResult['mainFileContent']!;
  mainImports = utilityFilesResult['mainImports']!;

  // Handle state management files
  final stateManagementResult = await _handleStateManagementFiles(
    config,
    projectDir,
    mainFileContent,
    homePageContent,
    mainImports,
  );
  mainFileContent = stateManagementResult['mainFileContent']!;
  homePageContent = stateManagementResult['homePageContent']!;
  mainImports = stateManagementResult['mainImports']!;

  // Handle routing files
  final routingResult = await _handleRoutingFiles(
    config,
    projectDir,
    mainFileContent,
    mainImports,
  );
  mainFileContent = routingResult['mainFileContent']!;
  mainImports = routingResult['mainImports']!;

  // Handle theme files
  final themeResult = await _handleThemeFiles(
    config,
    projectDir,
    mainFileContent,
    mainImports,
  );
  mainFileContent = themeResult['mainFileContent']!;
  mainImports = themeResult['mainImports']!;

  // Create constant files
  await _createConstantFiles(projectDir);

  // Write final project files
  await _writeFinalProjectFiles(
    projectDir,
    mainFileContent,
    homePageContent,
    mainImports,
  );
}

/// Replaces the `{{async}}` placeholder in the main file content based on config.
///
/// If `initializeDotEnv` or `createLocalStorageService` is true,
/// the placeholder is replaced with 'async', otherwise with an empty string.
String _replaceAsyncPlaceholder(String mainFileContent, Config config) {
  if (config.initializeDotEnv || config.createLocalStorageService) {
    return mainFileContent.replaceAll('{{async}}', 'async');
  } else {
    return mainFileContent.replaceAll('{{async}}', '');
  }
}

/// Handles the generation and updates for utility files like `size_utils.dart`,
/// `.env`, and `local_storage_service.dart` based on the [config].
///
/// Returns a map containing the updated `mainFileContent` and `mainImports`.
Future<Map<String, String>> _handleUtilityFiles(
  Config config,
  Directory projectDir,
  String mainFileContent,
  String mainImports,
) async {
  if (config.initializeSizeUtils) {
    mainImports += 'import \'utils/size_utils.dart\';\n';
    mainFileContent = mainFileContent.replaceAll('{{sizeUtils}}', '''
    final SizeUtils sizeUtils = SizeUtils();
    sizeUtils.init(context);
    ''');
    final sizeUtilsFile = File('${projectDir.path}/lib/utils/size_utils.dart');
    await sizeUtilsFile.create(recursive: true);
    await sizeUtilsFile.writeAsString(Templates.sizeUtilsContent);
    logDebug('Successfully generated and updated ${sizeUtilsFile.path}');
  } else {
    mainFileContent = mainFileContent.replaceAll('{{sizeUtils}}', '');
  }

  if (config.initializeDotEnv) {
    mainImports += 'import \'package:flutter_dotenv/flutter_dotenv.dart\';\n';
    mainFileContent = mainFileContent.replaceAll('{{dotEnv}}', '''
    await dotenv.load(fileName: '.env');
    ''');
    final dotEnvFile = File('${projectDir.path}/.env');
    await dotEnvFile.create(recursive: true);
    await dotEnvFile.writeAsString(Templates.dotEnvContent);

    logDebug('Successfully generated and updated ${dotEnvFile.path}');
  } else {
    mainFileContent = mainFileContent.replaceAll('{{dotEnv}}', '');
  }

  if (config.createLocalStorageService) {
    mainImports += 'import \'services/local_storage_service.dart\';\n';
    mainFileContent = mainFileContent.replaceAll('{{localStorage}}', '''
    await LocalStorageService.init();
    ''');
    final localStorageFile = File(
      '${projectDir.path}/lib/services/local_storage_service.dart',
    );
    await localStorageFile.create(recursive: true);
    await localStorageFile.writeAsString(Templates.localStorageServiceContent);

    logDebug('Successfully generated and updated ${localStorageFile.path}');
  } else {
    mainFileContent = mainFileContent.replaceAll('{{localStorage}}', '');
  }

  return {
    'mainFileContent': mainFileContent,
    'mainImports': mainImports,
  };
}

/// Handles state management related file generation and main file content updates
/// based on the [config].
///
/// Returns a map containing the updated `mainFileContent`, `homePageContent`,
/// and `mainImports`.
Future<Map<String, String>> _handleStateManagementFiles(
  Config config,
  Directory projectDir,
  String mainFileContent,
  String homePageContent,
  String mainImports,
) async {
  if (config.stateManagement == StateManagementOption.provider) {
    mainImports += 'import \'package:provider/provider.dart\';\n';
    mainImports += 'import \'providers/counter_provider.dart\';\n';
    mainFileContent = mainFileContent.replaceAll('{{materialAppWrapper}}', '''
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        // Add more providers here
      ],
      child: ${Templates.materialAppContent.replaceAll(";", ",")}
    );
    ''');
    final counterProviderFile = File(
      '${projectDir.path}/lib/providers/counter_provider.dart',
    );
    await counterProviderFile.create(recursive: true);
    await counterProviderFile.writeAsString(
      StateManagementTemplates.counterProviderContent,
    );

    homePageContent = StateManagementTemplates.proviiderHomePageContent;

    logDebug('Successfully generated and updated ${counterProviderFile.path}');
  } else if (config.stateManagement == StateManagementOption.riverpod) {
    mainImports +=
        'import \'package:flutter_riverpod/flutter_riverpod.dart\';\n';
    mainFileContent = mainFileContent.replaceAll('{{materialAppWrapper}}', '''
    ProviderScope(
      child: ${Templates.materialAppContent.replaceAll(";", ",")}
    );
    ''');
    homePageContent = StateManagementTemplates.riverpodHomePageContent;

    logDebug('Successfully generated and updated files for Riverpod');
  } else if (config.stateManagement == StateManagementOption.bloc) {
    mainImports += 'import \'package:flutter_bloc/flutter_bloc.dart\';\n';
    mainImports += 'import \'cubits/counter_cubit.dart\';\n';
    mainFileContent = mainFileContent.replaceAll('{{materialAppWrapper}}', '''
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CounterCubit()),
        // Add more blocs here
      ],
      child: ${Templates.materialAppContent.replaceAll(";", ",")}
    );
    ''');
    final counterCubitFile = File(
      '${projectDir.path}/lib/cubits/counter_cubit.dart',
    );
    await counterCubitFile.create(recursive: true);
    await counterCubitFile.writeAsString(
      StateManagementTemplates.cubitTemplate,
    );

    homePageContent = StateManagementTemplates.blocHomePageContent;

    logDebug('Successfully generated and updated files for BLoC');
  } else if (config.stateManagement == StateManagementOption.getx) {
    mainImports += 'import \'package:get/get.dart\';\n';
    mainFileContent = mainFileContent.replaceAll(
      '{{materialAppWrapper}}',
      Templates.materialAppContent,
    );

    final counterControllerFile = File(
      '${projectDir.path}/lib/controllers/counter_controller.dart',
    );
    await counterControllerFile.create(recursive: true);
    await counterControllerFile.writeAsString(
      StateManagementTemplates.getxControllerContent,
    );

    homePageContent = StateManagementTemplates.getxHomePageContent;

    logDebug('Successfully generated and updated files for GetX');
  } else {
    mainFileContent = mainFileContent.replaceAll(
      '{{materialAppWrapper}}',
      Templates.materialAppContent,
    );
  }

  return {
    'mainFileContent': mainFileContent,
    'homePageContent': homePageContent,
    'mainImports': mainImports,
  };
}

/// Handles routing related file generation and main file content updates
/// based on the [config].
///
/// Returns a map containing the updated `mainFileContent` and `mainImports`.
Future<Map<String, String>> _handleRoutingFiles(
  Config config,
  Directory projectDir,
  String mainFileContent,
  String mainImports,
) async {
  if (config.routing == RoutingOption.goRouter) {
    mainImports += 'import \'router/router.dart\';\n';

    final goRouterFile = File('${projectDir.path}/lib/router/router.dart');
    await goRouterFile.create(recursive: true);
    await goRouterFile.writeAsString(
      Templates.goRouterContent.replaceAll("const HomePage()", "HomePage()"),
    );
    logDebug('Successfully generated and updated ${goRouterFile.path}');

    final routeNamesFile = File('${projectDir.path}/lib/router/routes.dart');
    await routeNamesFile.create(recursive: true);
    await routeNamesFile.writeAsString(Templates.routeNames);

    if (config.stateManagement == StateManagementOption.getx) {
      mainFileContent = mainFileContent.replaceAll(
        '{{materialApp}}',
        'GetMaterialApp',
      );
    } else {
      mainFileContent = mainFileContent.replaceAll(
        '{{materialApp}}',
        'MaterialApp.router',
      );
    }
    mainFileContent = mainFileContent.replaceAll('{{router}}', '''
    routerConfig: appRouter,
    ''');
    mainFileContent = mainFileContent.replaceAll('{{home}}', '');

    logDebug('Successfully generated and updated ${routeNamesFile.path}');
  } else {
    if (config.stateManagement == StateManagementOption.getx) {
      mainFileContent = mainFileContent.replaceAll(
        '{{materialApp}}',
        'GetMaterialApp',
      );
    } else {
      mainFileContent = mainFileContent.replaceAll(
        '{{materialApp}}',
        'MaterialApp',
      );
    }
    mainFileContent = mainFileContent.replaceAll('{{router}}', '');
    mainImports += 'import \'home_page.dart\';\n';
    mainFileContent = mainFileContent.replaceAll(
      '{{home}}',
      ' home: HomePage(),',
    );
  }
  return {
    'mainFileContent': mainFileContent,
    'mainImports': mainImports,
  };
}

/// Handles theme related file generation and main file content updates
/// based on the [config].
///
/// Returns a map containing the updated `mainFileContent` and `mainImports`.
Future<Map<String, String>> _handleThemeFiles(
  Config config,
  Directory projectDir,
  String mainFileContent,
  String mainImports,
) async {
  if (config.useFlexColorScheme) {
    mainImports += 'import \'constants/theme.dart\';\n';
    mainFileContent = mainFileContent.replaceAll('{{theme}}', '''
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    ''');

    final appThemeFile = File('${projectDir.path}/lib/constants/theme.dart');
    await appThemeFile.create(recursive: true);
    await appThemeFile.writeAsString(Templates.appThemeContent);

    logDebug('Successfully generated and updated ${appThemeFile.path}');
  } else {
    mainFileContent = mainFileContent.replaceAll('{{theme}}', '');
  }
  return {
    'mainFileContent': mainFileContent,
    'mainImports': mainImports,
  };
}

/// Creates constant files like `colors.dart` and `assets.dart` within the
/// project's `lib/constants` directory.
Future<void> _createConstantFiles(Directory projectDir) async {
  final colorsFile = File('${projectDir.path}/lib/constants/colors.dart');
  await colorsFile.create(recursive: true);
  await colorsFile.writeAsString(Templates.colorsContent);
  logDebug('Successfully generated and updated ${colorsFile.path}');

  final assetsFile = File('${projectDir.path}/lib/constants/assets.dart');
  await assetsFile.create(recursive: true);
  await assetsFile.writeAsString(Templates.assetsContent);
  logDebug('Successfully generated and updated ${assetsFile.path}');
}

/// Writes the final `main.dart` and `home_page.dart` files to the project directory.
Future<void> _writeFinalProjectFiles(
  Directory projectDir,
  String mainFileContent,
  String homePageContent,
  String mainImports,
) async {
  final mainFile = File('${projectDir.path}/lib/main.dart');
  mainFileContent = mainFileContent.replaceAll('{{imports}}', mainImports);
  await mainFile.writeAsString(mainFileContent);
  logDebug('Successfully generated and updated ${mainFile.path}');

  final homePageFile = File('${projectDir.path}/lib/home_page.dart');
  await homePageFile.writeAsString(homePageContent);
  logDebug('Successfully generated and updated ${homePageFile.path}');
}
