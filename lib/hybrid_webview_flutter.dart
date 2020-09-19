import 'dart:async';

import 'package:flutter/services.dart';

class CookieItem {
  final String name;
  final String value;
  CookieItem(this.name, this.value);
}

class HybridWebviewFlutter {
  static const MethodChannel _channel =
      const MethodChannel('hybrid_webview_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> testSession(String urlString) async {
    final String res = await _channel.invokeMethod('testSession', urlString);
    return res;
  }

  static Future<bool> setCookie({
    String domain,
    String name,
    String value,
    int exp,
  }) async {
    bool result = await _channel.invokeMethod('setCookie', [
      domain,
      name,
      value,
      exp,
    ]);
    return result;
  }

  static Future<List<Map>> getCookie(String url) async {
    final List res = await _channel.invokeMethod('getCookie', url);
    List<Map> listMap = new List<Map>.from(res);
    return listMap;
  }
}
