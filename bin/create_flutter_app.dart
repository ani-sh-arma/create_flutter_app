import 'package:create_flutter_app/cli.dart';
import 'package:create_flutter_app/config.dart';

void main(List<String> arguments) async {
  print(arguments);
  final Config config = await promptUserPreferences();

  print(config);
}
