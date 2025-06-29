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

Future<void> generateProjectFiles(Config config) async {
  final projectDir = Directory(config.projectName);
  final mainFile = File('${projectDir.path}/lib/main.dart');
  String mainImports = '';
  String homePageContent = Templates.homePageContent;

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
        BlocProvider(create: (_) => CounterBloc()),
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
        'MaterialApp.router',
      );
    }
    mainFileContent = mainFileContent.replaceAll('{{router}}', '');
    mainImports += 'import \'home_page.dart\';\n';
    mainFileContent = mainFileContent.replaceAll(
      '{{home}}',
      ' home: HomePage(),',
    );
  }

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

  final colorsFile = File('${projectDir.path}/lib/constants/colors.dart');
  await colorsFile.create(recursive: true);
  await colorsFile.writeAsString(Templates.colorsContent);

  logDebug('Successfully generated and updated ${colorsFile.path}');

  final assetsFile = File('${projectDir.path}/lib/constants/assets.dart');
  await assetsFile.create(recursive: true);
  await assetsFile.writeAsString(Templates.assetsContent);

  logDebug('Successfully generated and updated ${assetsFile.path}');

  mainFileContent = mainFileContent.replaceAll('{{imports}}', mainImports);

  await mainFile.writeAsString(mainFileContent);

  final homePageFile = File('${projectDir.path}/lib/home_page.dart');
  logDebug('Successfully generated and updated ${mainFile.path}');
  await homePageFile.writeAsString(homePageContent);

  logDebug('Successfully generated and updated ${homePageFile.path}');
}
