import 'package:prompts/prompts.dart' as prompts;
import 'config.dart';

Future<Config> promptUserPreferences() async {
  final name = prompts.get('Project Name');

  final state = prompts.choose<StateManagementOption>(
    'Choose state management:',
    StateManagementOption.values,
  );

  final routing = prompts.choose<RoutingOption>(
    'Choose routing:',
    RoutingOption.values,
  );

  final useFirebase = prompts.getBool('Use Firebase?', defaultsTo: false);

  final structure = prompts.choose<FolderStructure>(
    'Select folder structure:',
    FolderStructure.values,
  );

  return Config(
    projectName: name,
    stateManagement: state ?? StateManagementOption.bloc,
    routing: routing ?? RoutingOption.goRouter,
    useFirebase: useFirebase,
    folderStructure: structure ?? FolderStructure.basic,
  );
}
