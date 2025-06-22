import 'dart:io';
import 'package:create_flutter_app/config.dart';

Future<void> scaffoldProject(Config config) async {
  await Process.run('flutter', ['create', config.projectName]);

  // Modify files
  // Copy extra templates
  // Inject dependencies
}
