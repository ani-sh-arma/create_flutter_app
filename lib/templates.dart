/// A collection of static string templates used for generating Flutter project files.
///
/// These templates are used by the [Scaffolder] to create the initial
/// structure and content of a new Flutter application based on user choices.
class Templates {
  /// Template for the main `lib/main.dart` file.
  static String mainTemplate = '''
    import 'package:flutter/material.dart';
    {{imports}}

    void main() {{async}} {
      WidgetsFlutterBinding.ensureInitialized();
      {{localStorage}}
      {{dotEnv}}
      runApp(const MyApp());
    }

    class MyApp extends StatelessWidget {
      const MyApp({super.key});

      @override
      Widget build(BuildContext context) {
        {{sizeUtils}}
        return {{materialAppWrapper}}
      }
    }
    ''';

  /// Template for the `MaterialApp` widget content.
  static String materialAppContent = '''
  {{materialApp}}(
    title: 'Create Flutter App',
    {{theme}}
    {{home}}
    {{router}}
  );
  ''';

  /// Template for the default `lib/home_page.dart` file.
  static String homePageContent = '''
    import 'package:flutter/material.dart';
    class HomePage extends StatefulWidget {
      const HomePage({super.key});

      @override
      State<HomePage> createState() => _HomePageState();
    }

    class _HomePageState extends State<HomePage> {
      int _counter = 0;

      void _incrementCounter() {
        setState(() {
          _counter++;
        });
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text("My Home Page"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('You have pushed the button this many times:'),
                Text(
                  '\$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        );
      }
    }

    ''';

  /// Template for the `lib/utils/size_utils.dart` file.
  static String sizeUtilsContent = '''
    import 'package:flutter/material.dart';

    class SizeUtils {
      static late double screenWidth;
      static late double screenHeight;
      static late bool isMobile;

      static late double relativeScreenWidth;
      static late double relativeScreenHeight;

      void init(BuildContext context) {
        screenWidth = MediaQuery.of(context).size.width;
        screenHeight = MediaQuery.of(context).size.height;
        isMobile = MediaQuery.of(context).size.width < 600;
        relativeScreenWidth = SizeUtils.screenWidth / 393;
        relativeScreenHeight = SizeUtils.screenHeight / 852;
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

  /// Template for the `.env` file content.
  static String dotEnvContent = '''
    .env files are for storing environment variables.
    Please make sure to add anytype of sensitive information in this file.

    # Example
    API_KEY=your_api_key
    API_SECRET=your_api_secret
    ''';

  /// Template for the `lib/router/router.dart` file when using GoRouter.
  static String goRouterContent = '''
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';
    import 'routes.dart';
    import '../home_page.dart';

    final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

    final appRouter = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const HomePage(),
        ),
        // Add more routes here
      ],
    );
    ''';

  /// Template for the `lib/router/routes.dart` file.
  static String routeNames = '''
      class Routes {
        static const home = '/';
        // Add more routes here
      }
    ''';

  /// Template for the `lib/constants/theme.dart` file when using FlexColorScheme.
  static String appThemeContent = '''
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your
/// app or upgrade the package to version 8.2.0.
///
/// Use it in a [MaterialApp] like this:
///
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
/// );


abstract final class AppTheme {
  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    // Using FlexColorScheme built-in FlexScheme enum based colors
    scheme: FlexScheme.greys,
    // Component theme configurations for light mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark = FlexThemeData.dark(
    // Using FlexColorScheme built-in FlexScheme enum based colors.
    scheme: FlexScheme.greys,
    // Component theme configurations for dark mode.
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
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
''';

  /// Template for the `lib/constants/colors.dart` file.
  static String colorsContent = '''
  import 'package:flutter/material.dart';

  abstract final class AppColors {
    // Add your colors here
    // Example :
    static const primaryBlack = Color(0xFF000000);
  }
  ''';

  /// Template for the `lib/constants/assets.dart` file.
  static String assetsContent = '''
    class Assets {
      static final String basePath = "assets/images/";

      // Add your assets here
      // Example :

      // static final String logo = '\${basePath}logo.png';
    }
  ''';
}

/// A collection of static string templates specifically for state management
/// related files, used by the [Scaffolder] to generate boilerplate code.
class StateManagementTemplates {
  /// Template for the `home_page.dart` file when using Provider state management.
  static String proviiderHomePageContent = '''
    import 'package:provider/provider.dart';
    import 'package:flutter/material.dart';
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
            onPressed: () {
              context.read<CounterProvider>().increment();
            },
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

  /// Template for the `home_page.dart` file when using Riverpod state management.
  static String riverpodHomePageContent = '''
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';

    final counterProvider = StateProvider((ref) => 0);

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
            onPressed: () {
              ref.read(counterProvider.notifier).state++;
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        );
      }
      }
    ''';

  /// Template for the `home_page.dart` file when using BLoC state management.
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
            onPressed: () {
              context.read<CounterCubit>().increment();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        );
      }
    }
    ''';

  /// Template for the `lib/cubits/counter_cubit.dart` file when using BLoC.
  static String cubitTemplate = '''
    import 'package:flutter_bloc/flutter_bloc.dart';

    class CounterCubit extends Cubit<int> {
      CounterCubit() : super(0);

      void increment() {
        emit(state + 1);
      }
    }
  ''';
}
