import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class LoggerService {
  static File? _logFile;

  static Future<void> init() async {
    if (kIsWeb) {
      debugPrint("LoggerService: Web platform detected. File logging disabled.");
      return;
    }

    try {
      String logDirPath;

      if (kDebugMode && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {

        logDirPath = Directory.current.path;
      } else {

        final dir = await getApplicationDocumentsDirectory();
        logDirPath = dir.path;
      }

      _logFile = File('$logDirPath/beesports_errors.log');

      if (!await _logFile!.exists()) {
        await _logFile!.create();
      }

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        logError(details.exceptionAsString(), details.stack?.toString());
        if (originalOnError != null) {
          originalOnError(details);
        } else {
          FlutterError.presentError(details);
        }
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        logError(error.toString(), stack.toString());
        return true;
      };

      logInfo("LoggerService initialized. Logging to: ${_logFile!.path}");
    } catch (e) {
      debugPrint("Could not initialize LoggerService: $e");
    }
  }

  static Future<void> logError(String error, [String? stack]) async {
    final time = DateTime.now().toIso8601String();
    final logEntry = "[$time] [ERROR] $error\n${stack != null ? 'Stack Trace:\n$stack\n' : ''}----------------------------------------\n";

    debugPrint(logEntry);

    if (_logFile != null && !kIsWeb) {
      try {
        await _logFile!.writeAsString(logEntry, mode: FileMode.append);
      } catch (e) {
        debugPrint("Failed to write to log file: $e");
      }
    }
  }

  static Future<void> logInfo(String message) async {
    final time = DateTime.now().toIso8601String();
    final logEntry = "[$time] [INFO] $message\n----------------------------------------\n";

    debugPrint(logEntry);

    if (_logFile != null && !kIsWeb) {
      try {
        await _logFile!.writeAsString(logEntry, mode: FileMode.append);
      } catch (e) {
        debugPrint("Failed to write to log file: $e");
      }
    }
  }

  static Future<String?> getLogFilePath() async {
    return _logFile?.path;
  }
}
