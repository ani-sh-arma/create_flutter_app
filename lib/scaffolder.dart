import 'dart:io';
import 'dart:async';

import 'package:create_flutter_app/config.dart';
import 'package:create_flutter_app/logger.dart';

Future<void> scaffoldProject(Config config) async {
  logInfo("Creating project...");
  await createProject(config);
  logInfo("Adding dependencies...");
  await addDependencies(config);
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
