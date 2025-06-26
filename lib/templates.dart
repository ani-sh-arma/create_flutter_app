class Templates {
  static String mainTemplate = '''
    import 'package:flutter/material.dart';
    import 'home_page.dart';
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

  static String materialAppContent = '''
  {{materialApp}}(
    title: 'Create Flutter App',
    {{theme}}
    {{home}}
    {{router}}
  );
  ''';

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

  static String dotEnvContent = '''
    .env files are for storing environment variables.
    Please make sure to add anytype of sensitive information in this file.

    # Example
    API_KEY=your_api_key
    API_SECRET=your_api_secret
    ''';
}




      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // ),


      // home: const HomePage(),
