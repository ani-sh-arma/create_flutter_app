import 'package:ansicolor/ansicolor.dart';

final _green = AnsiPen()..green();
final _red = AnsiPen()..red(bold: true);
final _blue = AnsiPen()..blue();
final _yellow = AnsiPen()..yellow();
final _magenta = AnsiPen()..magenta();

void logInfo(String message) => print(_blue('[INFO] $message'));
void logSuccess(String message) => print(_green('[✓] $message'));
void logWarning(String message) => print(_yellow('[!] $message'));
void logError(String message) => print(_red('[✗] $message'));
void logDebug(String message) => print(_magenta('[DEBUG] $message'));
