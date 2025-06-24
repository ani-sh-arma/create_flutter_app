class Templates {
  static String mainTemplate = '''
    import 'package:flutter/material.dart';
    {{imports}}

    void main() {
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
}




      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // ),


      // home: const HomePage(),
