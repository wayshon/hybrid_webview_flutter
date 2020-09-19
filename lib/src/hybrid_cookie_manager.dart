import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hybrid_webview_flutter/hybrid_webview_flutter.dart';

class HybridCookieManager extends Interceptor {
  @override
  Future onRequest(RequestOptions options) async {
    final cookies =
        await HybridWebviewFlutter.getCookie(options.uri.toString());
    final cookie = cookies
        .map((cookie) => "${cookie['name']}=${cookie['value']}")
        .join('; ');
    print(
        'req cookie ================   ${options.headers[HttpHeaders.userAgentHeader]}');
    if (cookie.isNotEmpty) options.headers[HttpHeaders.cookieHeader] = cookie;
  }

  @override
  Future onResponse(Response response) async => _saveCookies(response);

  @override
  Future onError(DioError err) async => _saveCookies(err.response);

  _saveCookies(Response response) async {
    if (response != null && response.headers != null) {
      List<String> cookies = response.headers[HttpHeaders.setCookieHeader];
      if (cookies != null) {
        List<Cookie> list =
            cookies.map((str) => Cookie.fromSetCookieValue(str)).toList();
        for (Cookie cookie in list) {
          String domain = cookie.domain ?? response.request.uri.host;
          String name = cookie.name;
          String value = cookie.value;
          int expires =
              cookie.expires != null ? cookie.expires.millisecond : 10000;
          await HybridWebviewFlutter.setCookie(
              domain: domain, name: name, value: value, exp: expires);
          print(domain);
          print(name);
          print(value);
          print(expires);
        }
        // print('list====================   $list');
      }
    }
  }
}
