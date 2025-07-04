import 'package:ansicolor/ansicolor.dart';

final _green = AnsiPen()..green();
final _red = AnsiPen()..red(bold: true);
final _blue = AnsiPen()..blue();
final _yellow = AnsiPen()..yellow();
final _magenta = AnsiPen()..magenta();

/// Logs an informational message to the console in blue.
void logInfo(String message) => print(_blue('[INFO] $message'));

/// Logs a success message to the console in green.
void logSuccess(String message) => print(_green('[✓] $message'));

/// Logs a warning message to the console in yellow.
void logWarning(String message) => print(_yellow('[!] $message'));

/// Logs an error message to the console in red.
void logError(String message) => print(_red('[✗] $message'));

/// Logs a debug message to the console in magenta.
void logDebug(String message) => print(_magenta('[DEBUG] $message'));
