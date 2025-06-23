import 'package:ansicolor/ansicolor.dart';

final _green = AnsiPen()..green();
final _red = AnsiPen()..red(bold: true);
final _blue = AnsiPen()..blue();
final _yellow = AnsiPen()..yellow();

void logInfo(String message) => print(_blue('[INFO] $message'));
void logSuccess(String message) => print(_green('[✓] $message'));
void logWarning(String message) => print(_yellow('[!] $message'));
void logError(String message) => print(_red('[✗] $message'));
