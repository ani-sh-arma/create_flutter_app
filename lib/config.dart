enum StateManagementOption { none, provider, riverpod, bloc }

enum RoutingOption { none,navigator2, goRouter, autoRoute }

class Config {
  final String projectName;
  final StateManagementOption stateManagement;
  final RoutingOption routing;
  final bool useFirebase;

  Config({
    required this.projectName,
    required this.stateManagement,
    required this.routing,
    required this.useFirebase,
  });

  @override
  String toString() {
    return '''
      Project: $projectName
      State Management: ${stateManagement.name}
      Routing: ${routing.name}
      Firebase: ${useFirebase ? "Yes" : "No"}
    ''';
  }
}
