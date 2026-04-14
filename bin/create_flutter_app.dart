import 'dart:io';

import 'package:args/args.dart';
import 'package:create_flutter_app/cli.dart';
import 'package:create_flutter_app/scaffolder.dart';

/// Tool version — keep in sync with pubspec.yaml.
const _version = '1.3.0';

void main(List<String> arguments) async {
  final parser = buildArgParser();

  late final ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.writeln(parser.usage);
    exit(64); // EX_USAGE
  }

  if (args['help'] as bool) {
    stdout.writeln('create_flutter_app — scaffold a new Flutter project\n');
    stdout.writeln('Usage: create_flutter_app [options]\n');
    stdout.writeln(parser.usage);
    exit(0);
  }

  if (args['version'] as bool) {
    stdout.writeln('create_flutter_app v$_version');
    exit(0);
  }

  final config = await promptUserPreferences(args);
  await scaffoldProject(config);
}
