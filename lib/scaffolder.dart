import 'dart:io';
import 'dart:async';

import 'package:create_flutter_app/config.dart';
import 'package:create_flutter_app/logger.dart';
import 'package:create_flutter_app/templates.dart';

Future<void> scaffoldProject(Config config) async {
  logInfo("Creating project...");
  await createProject(config);
  logInfo("Adding dependencies...");
  await addDependencies(config);
  logInfo("Generating project files...");
  await generateProjectFiles(config);

  logInfo("Formatting project...");
  final projectDir = Directory(config.projectName);

  final result = await Process.run(
    'dart',
    ['format', '.'],
    runInShell: true,
    workingDirectory: projectDir.path,
  );

  if (result.exitCode == 0) {
    logInfo("[ Formatting Project ]\n${result.stdout}");
  } else {
    logError("[ Formatting Project Failed ]\n${result.stderr}");
  }
  logSuccess("Project created successfully!");
}

Future<void> createProject(Config config) async {
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

Future<void> addDependencies(Config config) async {
  List<String> dependencies = [];

  switch (config.stateManagement) {
    case StateManagementOption.none:
      break;
    case StateManagementOption.provider:
      dependencies.add('provider');
      break;
    case StateManagementOption.riverpod:
      dependencies.add('riverpod');
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
    case RoutingOption.autoRoute:
      dependencies.add('auto_route');
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

Future<void> generateProjectFiles(Config config) async {
  final projectDir = Directory(config.projectName);
  final mainFile = File('${projectDir.path}/lib/main.dart');
  String mainImports = '';

  String mainFileContent = Templates.mainTemplate;

  if (config.initializeDotEnv || config.createLocalStorageService) {
    mainFileContent = mainFileContent.replaceAll('{{async}}', 'async');
  } else {
    mainFileContent = mainFileContent.replaceAll('{{async}}', '');
  }

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

  if (!config.useFlexColorScheme &&
      config.routing == RoutingOption.none &&
      config.stateManagement == StateManagementOption.none) {
    mainFileContent = mainFileContent.replaceAll(
      '{{materialAppWrapper}}',
      Templates.materialAppContent,
    );
    mainFileContent = mainFileContent.replaceAll(
      '{{materialApp}}',
      'MaterialApp',
    );
    mainFileContent = mainFileContent.replaceAll('{{theme}}', '');
    mainFileContent = mainFileContent.replaceAll(
      '{{home}}',
      'home: const HomePage(),',
    );
    mainFileContent = mainFileContent.replaceAll('{{router}}', '');
  }

  mainFileContent = mainFileContent.replaceAll('{{imports}}', mainImports);

  await mainFile.writeAsString(mainFileContent);

  final homePageFile = File('${projectDir.path}/lib/home_page.dart');
  logDebug('Successfully generated and updated ${mainFile.path}');
  await homePageFile.writeAsString(Templates.homePageContent);

  logDebug('Successfully generated and updated ${homePageFile.path}');
}
