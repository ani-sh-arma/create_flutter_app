import 'package:create_flutter_app/cli.dart';
import 'package:create_flutter_app/config.dart';
import 'package:test/test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // validateProjectName tests
  // ---------------------------------------------------------------------------
  group('validateProjectName', () {
    test('accepts valid snake_case names', () {
      expect(validateProjectName('my_project'), isNull);
      expect(validateProjectName('hello'), isNull);
      expect(validateProjectName('app123'), isNull);
      expect(validateProjectName('my_cool_app_2'), isNull);
    });

    test('rejects empty string', () {
      expect(validateProjectName(''), isNotNull);
    });

    test('rejects names with spaces', () {
      expect(validateProjectName('my project'), isNotNull);
    });

    test('rejects names with dashes', () {
      expect(validateProjectName('my-project'), isNotNull);
    });

    test('rejects names with uppercase letters', () {
      expect(validateProjectName('MyProject'), isNotNull);
      expect(validateProjectName('myProject'), isNotNull);
    });

    test('rejects names starting with a digit', () {
      expect(validateProjectName('1project'), isNotNull);
      expect(validateProjectName('9lives'), isNotNull);
    });

    test('rejects names with special characters', () {
      expect(validateProjectName('my@project'), isNotNull);
      expect(validateProjectName('my.project'), isNotNull);
    });

    test('rejects reserved Dart keywords', () {
      expect(validateProjectName('class'), isNotNull);
      expect(validateProjectName('import'), isNotNull);
      expect(validateProjectName('main'), isNotNull);
      expect(validateProjectName('abstract'), isNotNull);
      expect(validateProjectName('void'), isNotNull);
    });

    test('rejects names longer than 64 characters', () {
      final longName = 'a' * 65;
      expect(validateProjectName(longName), isNotNull);
    });

    test('accepts names exactly 64 characters long', () {
      final maxName = 'a' * 64;
      expect(validateProjectName(maxName), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Config tests
  // ---------------------------------------------------------------------------
  group('Config', () {
    test('toString includes all fields', () {
      final config = Config(
        projectName: 'test_app',
        stateManagement: StateManagementOption.riverpod,
        routing: RoutingOption.goRouter,
        useFlexColorScheme: true,
        createLocalStorageService: false,
        initializeSizeUtils: true,
        initializeDotEnv: false,
        dryRun: true,
      );
      final str = config.toString();
      expect(str, contains('test_app'));
      expect(str, contains('riverpod'));
      expect(str, contains('goRouter'));
      expect(str, contains('Yes')); // useFlexColorScheme
      expect(str, contains('No')); // createLocalStorageService
    });

    test('dryRun defaults to false', () {
      final config = Config(
        projectName: 'my_app',
        stateManagement: StateManagementOption.none,
        routing: RoutingOption.none,
        useFlexColorScheme: false,
        createLocalStorageService: false,
        initializeSizeUtils: false,
        initializeDotEnv: false,
      );
      expect(config.dryRun, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // StateManagementOption / RoutingOption enum tests
  // ---------------------------------------------------------------------------
  group('StateManagementOption', () {
    test('does not include getx', () {
      final names = StateManagementOption.values.map((e) => e.name).toList();
      expect(names, isNot(contains('getx')));
    });

    test('contains expected values', () {
      final names = StateManagementOption.values.map((e) => e.name).toList();
      expect(names, containsAll(['none', 'provider', 'riverpod', 'bloc']));
    });
  });

  group('RoutingOption', () {
    test('contains goRouter and autoRoute', () {
      final names = RoutingOption.values.map((e) => e.name).toList();
      expect(names, containsAll(['none', 'goRouter', 'autoRoute']));
    });
  });

  // ---------------------------------------------------------------------------
  // buildArgParser tests
  // ---------------------------------------------------------------------------
  group('buildArgParser', () {
    test('parses --help flag', () {
      final parser = buildArgParser();
      final result = parser.parse(['--help']);
      expect(result['help'], isTrue);
    });

    test('parses --version flag', () {
      final parser = buildArgParser();
      final result = parser.parse(['--version']);
      expect(result['version'], isTrue);
    });

    test('parses --dry-run flag', () {
      final parser = buildArgParser();
      final result = parser.parse(['--dry-run']);
      expect(result['dry-run'], isTrue);
    });

    test('parses --name option', () {
      final parser = buildArgParser();
      final result = parser.parse(['--name', 'my_app']);
      expect(result['name'], equals('my_app'));
    });

    test('parses --state-management option', () {
      final parser = buildArgParser();
      final result = parser.parse(['--state-management', 'riverpod']);
      expect(result['state-management'], equals('riverpod'));
    });

    test('parses --routing option', () {
      final parser = buildArgParser();
      final result = parser.parse(['--routing', 'goRouter']);
      expect(result['routing'], equals('goRouter'));
    });

    test('rejects unknown --state-management value', () {
      final parser = buildArgParser();
      expect(
        () => parser.parse(['--state-management', 'getx']),
        throwsA(isA<FormatException>()),
      );
    });

    test('boolean flags default to false', () {
      final parser = buildArgParser();
      final result = parser.parse([]);
      expect(result['dry-run'], isFalse);
      expect(result['flex-color-scheme'], isFalse);
      expect(result['local-storage'], isFalse);
      expect(result['size-utils'], isFalse);
      expect(result['dotenv'], isFalse);
    });
  });
}
