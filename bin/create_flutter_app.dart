import 'package:create_flutter_app/cli.dart';
import 'package:create_flutter_app/config.dart';
import 'package:create_flutter_app/logger.dart';
import 'package:create_flutter_app/scaffolder.dart';

void main(List<String> arguments) async {
  logInfo(arguments.toString());
  final Config config = await promptUserPreferences();

  logInfo("Selected Configuration\n$config");
  await scaffoldProject(config);
}
