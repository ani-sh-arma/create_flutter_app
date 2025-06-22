enum StateManagementOption { none, provider, riverpod, bloc }

enum RoutingOption { navigator2, goRouter, autoRoute }

enum FolderStructure { basic, featureBased, cleanArchitecture }

class Config {
  final String projectName;
  final StateManagementOption stateManagement;
  final RoutingOption routing;
  final bool useFirebase;
  final FolderStructure folderStructure;

  Config({
    required this.projectName,
    required this.stateManagement,
    required this.routing,
    required this.useFirebase,
    required this.folderStructure,
  });

  @override
  String toString() {
    return '''
      Project: $projectName
      State Management: $stateManagement
      Routing: $routing
      Firebase: ${useFirebase ? "Yes" : "No"}
      Structure: $folderStructure
    ''';
  }
}
