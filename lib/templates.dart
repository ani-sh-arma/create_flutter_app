/// A collection of static string templates used for generating Flutter project files.
///
/// These templates are used by the scaffolder to create the initial
/// structure and content of a new Flutter application based on user choices.
class Templates {
  /// Template for the main `lib/main.dart` file.
  ///
  /// Placeholders:
  /// - `{{imports}}` — additional import statements
  /// - `{{async}}` — replaced with `async` when async init is needed
  /// - `{{localStorage}}` — LocalStorageService.init() call or empty
  /// - `{{dotEnv}}` — dotenv.load() call or empty
  /// - `{{materialAppWrapper}}` — the root widget returned by MyApp.build()
  static String mainTemplate = '''
import 'package:flutter/material.dart';
{{imports}}

void main() {{async}} {
  WidgetsFlutterBinding.ensureInitialized();
  {{localStorage}}
  {{dotEnv}}
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return {{materialAppWrapper}}
  }
}
''';

  /// Template for the `MaterialApp` widget content.
  ///
  /// Placeholders:
  /// - `{{materialApp}}` — `MaterialApp` or `MaterialApp.router`
  /// - `{{title}}` — the project name used as the app title
  /// - `{{theme}}` — theme / darkTheme properties or empty
  /// - `{{home}}` — `home:` property or empty
  /// - `{{router}}` — `routerConfig:` property or empty
  /// - `{{builder}}` — `builder:` property (used for SizeUtils) or empty
  static String materialAppContent = '''
{{materialApp}}(
    title: '{{title}}',
    {{theme}}
    {{home}}
    {{router}}
    {{builder}}
  );
''';

  /// Template for the default `lib/home_page.dart` file (no state management).
  ///
  /// This is a clean, minimal scaffold — not a counter clone.
  static String homePageContent = '''
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Welcome! Start building your app here.'),
      ),
    );
  }
}
''';

  /// Template for the `lib/utils/size_utils.dart` file.
  ///
  /// The baseline dimensions 393 × 852 are the logical pixel dimensions of an
  /// iPhone 14 Pro.  Update these values to match the design spec you are
  /// working from so that `relativeScreenWidth` / `relativeScreenHeight`
  /// scale correctly on all devices.
  static String sizeUtilsContent = '''
import 'package:flutter/material.dart';

/// Utility class for responsive screen-size calculations.
///
/// Call [SizeUtils.init] once in the `MaterialApp.builder` callback (or
/// inside `didChangeDependencies` of your root widget) so that a valid
/// [MediaQuery] is available.
///
/// The baseline dimensions [_designWidth] × [_designHeight] default to the
/// logical pixel size of an **iPhone 14 Pro** (393 × 852 dp).  Adjust them
/// to match your own design specification.
class SizeUtils {
  // Baseline device dimensions used for relative scaling.
  // Change these to match your design file's canvas size.
  static const double _designWidth = 393;
  static const double _designHeight = 852;

  static late double screenWidth;
  static late double screenHeight;
  static late bool isMobile;

  /// Width scale factor relative to the design baseline.
  static late double relativeScreenWidth;

  /// Height scale factor relative to the design baseline.
  static late double relativeScreenHeight;

  /// Initialises [SizeUtils] from the given [context].
  ///
  /// Must be called from a widget that has a [MediaQuery] ancestor, e.g.
  /// from inside `MaterialApp.builder`.
  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    isMobile = size.width < 600;
    relativeScreenWidth = screenWidth / _designWidth;
    relativeScreenHeight = screenHeight / _designHeight;
  }
}
''';

  /// Template for the `lib/services/local_storage_service.dart` file.
  static String localStorageServiceContent = '''
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> setList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  static List<String>? getList(String key) {
    return _prefs.getStringList(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }
}
''';

  /// Template for the `.env` file.
  ///
  /// ⚠️  Do NOT commit this file — it is already added to `.gitignore`.
  static String dotEnvContent = '''
# .env — environment variables for this project.
#
# WARNING: Do NOT commit this file. It is listed in .gitignore.
# Add all sensitive configuration values here and load them via flutter_dotenv.

# Example:
# API_KEY=your_api_key
# API_SECRET=your_api_secret
''';

  /// Template for the `lib/router/router.dart` file when using GoRouter.
  static String goRouterContent = '''
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';
import '../home_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.home,
  // Only log navigation events in debug builds.
  debugLogDiagnostics: kDebugMode,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomePage(),
    ),
    // Add more routes here.
  ],
);
''';

  /// Template for the `lib/router/routes.dart` file (GoRouter).
  static String routeNames = '''
class Routes {
  const Routes._();

  static const home = '/';
  // Add more route paths here.
}
''';

  /// Template for the `lib/router/router.dart` file when using AutoRoute.
  static String autoRouterContent = '''
import 'package:auto_route/auto_route.dart';
import 'router.gr.dart';

/// Application router generated by auto_route.
///
/// Run `dart run build_runner build` (or `watch`) to regenerate [router.gr.dart]
/// after adding or removing routes.
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        // Add more routes here.
      ];
}

/// Singleton router instance — create it once and reuse.
final appRouter = AppRouter();
''';

  /// Template for the `lib/constants/theme.dart` file when using FlexColorScheme.
  static String appThemeContent = '''
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use the same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your app or
/// upgrade the package to version 8.2.0.
///
/// Use it in a [MaterialApp] like this:
///
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
/// );
/// ```
abstract final class AppTheme {
  /// Light mode theme.
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.greys,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  /// Dark mode theme.
  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.greys,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
''';

  /// Template for the `lib/constants/colors.dart` file.
  static String colorsContent = '''
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Add your app colours here.
  // Example:
  static const primaryBlack = Color(0xFF000000);
}
''';

  /// Template for the `lib/constants/assets.dart` file.
  static String assetsContent = '''
abstract final class Assets {
  static const String basePath = 'assets/images/';

  // Add your asset paths here.
  // Example:
  // static const String logo = '\${basePath}logo.png';
}
''';
}

/// A collection of static string templates specifically for state management
/// related files, used by the scaffolder to generate boilerplate code.
class StateManagementTemplates {
  /// Template for the `lib/home_page.dart` file when using Provider.
  static String providerHomePageContent = '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/counter_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: Consumer<CounterProvider>(
          builder: (context, counterProvider, child) {
            return Text(
              'Count: \${counterProvider.counter}',
              style: Theme.of(context).textTheme.headlineMedium,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterProvider>().increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';

  /// Template for the `lib/providers/counter_provider.dart` file when using Provider.
  static String counterProviderContent = '''
import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }
}
''';

  /// Template for the `lib/home_page.dart` file when using Riverpod.
  ///
  /// Uses [NotifierProvider] — the modern Riverpod API that does not require
  /// code generation.  The provider is defined in `providers/counter_notifier.dart`.
  static String riverpodHomePageContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/counter_notifier.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: Text(
          'Count: \$counter',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';

  /// Template for `lib/providers/counter_notifier.dart` when using Riverpod.
  ///
  /// Uses [NotifierProvider] — the idiomatic modern Riverpod approach.
  static String counterNotifierContent = '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple counter implemented with [Notifier] / [NotifierProvider].
///
/// This is the modern Riverpod pattern — prefer it over the legacy
/// [StateProvider] + `.state++` approach.
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);
''';

  /// Template for the `lib/home_page.dart` file when using BLoC / Cubit.
  static String blocHomePageContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/counter_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: BlocBuilder<CounterCubit, int>(
          builder: (context, state) {
            return Text(
              'Count: \$state',
              style: Theme.of(context).textTheme.headlineMedium,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterCubit>().increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';

  /// Template for `lib/cubits/counter_cubit.dart` when using BLoC.
  static String cubitTemplate = '''
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
''';

  /// Template for the `lib/home_page.dart` file when using AutoRoute.
  ///
  /// The `@RoutePage()` annotation marks this widget as a routable page.
  /// Remember to regenerate after any route changes:
  /// `dart run build_runner build`
  static String autoRouteHomePageContent = '''
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Welcome! Start building your app here.'),
      ),
    );
  }
}
''';
}
