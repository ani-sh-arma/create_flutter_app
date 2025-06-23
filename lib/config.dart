enum StateManagementOption { none, provider, riverpod, bloc }

enum RoutingOption { none, navigator2, goRouter, autoRoute }

class Config {
  final String projectName;
  final StateManagementOption stateManagement;
  final RoutingOption routing;
  final bool useFlexColorScheme;
  final bool createLocalStorageService;
  final bool initializeSizeUtils;
  final bool includeCommonCustomWidgets;

  Config({
    required this.projectName,
    required this.stateManagement,
    required this.routing,
    required this.useFlexColorScheme,
    required this.createLocalStorageService,
    required this.initializeSizeUtils,
    required this.includeCommonCustomWidgets,
  });

  @override
  String toString() {
    return '''
      Project: $projectName
      State Management: ${stateManagement.name}
      Routing: ${routing.name}
      Use FlexColorScheme: ${useFlexColorScheme ? "Yes" : "No"}
      Create LocalStorageService: ${createLocalStorageService ? "Yes" : "No"}
      Initialize SizeUtils: ${initializeSizeUtils ? "Yes" : "No"}
      Include Common Custom Widgets: ${includeCommonCustomWidgets ? "Yes" : "No"}
    ''';
  }
}
