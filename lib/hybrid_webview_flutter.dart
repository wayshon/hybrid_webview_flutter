import 'dart:async';

import 'package:flutter/services.dart';

class HybridWebviewFlutter {
  static const MethodChannel _channel =
      const MethodChannel('hybrid_webview_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
