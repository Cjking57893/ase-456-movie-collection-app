import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlobalErrorHandler {
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        print('Flutter Error: ${details.exception}');
        print('Stack trace: ${details.stack}');
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        print('Platform Error: $error');
        print('Stack trace: $stack');
      }
      return true;
    };
  }
}
