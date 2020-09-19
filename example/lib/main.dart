import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:hybrid_webview_flutter/hybrid_webview_flutter.dart';
import 'package:hybrid_webview_flutter/src/hybrid_webview.dart';
import 'package:hybrid_webview_flutter/src/hybrid_cookie_manager.dart';

const _HOST = "calcbit.com";
const _URL = "https://${_HOST}/session-test/";
const _HOST_DEBUG = "localhost:3000";
const _URL_DEBUG = "http://${_HOST_DEBUG}";

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HybridWebview webView;

  String jsResult = '';
  String jsCallback = '';
  String cookieResponse = '';
  String validateResponse = '';

  @override
  void initState() {
    super.initState();
    webView = new HybridWebview(
        url:
            'https://calcbit.com/resource/flutter/hybrid_webview_flutter/fe-file/index.html',
        bridgeListener: this.bridgeListener);
  }

  Future<dynamic> bridgeListener(String method, dynamic content) async {
    if (method == 'exchangeHeight') {
      setState(() {
        jsResult = 'webview clientHeight: ${content[0]}';
      });
      return context.size.height;
    } else if (method == 'webViewDidStartLoad') {
      print('webViewDidStartLoad === ');
    } else if (method == 'webViewDidFinishLoad') {
      print('webViewDidFinishLoad === ');
    } else if (method == 'didFailLoadWithError') {
      print('didFailLoadWithError === $content');
    } else if (method == 'scrollViewWillBeginDragging') {
      print('scrollViewWillBeginDragging === ');
    } else if (method == 'scrollViewDidEndDragging') {
      print('scrollViewDidEndDragging === $content');
    } else if (method == 'scrollForwardTop') {
      print('scrollForwardTop === $content');
    } else if (method == 'scrollForwardBottom') {
      print('scrollForwardBottom === $content');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Container(
              color: Colors.blueGrey,
              child: Column(
                children: <Widget>[
                  Text(jsCallback),
                  RaisedButton(
                    child: Text("call js"),
                    onPressed: () async {
                      List results =
                          await webView.invokeMethod('getUserAgent', 'flutter');
                      setState(() {
                        jsCallback = results[0];
                      });
                    },
                  ),
                  Center(
                    child: Container(
                      width: 200,
                      height: 400,
                      child: webView,
                    ),
                  ),
                  Text(jsResult),
                  RaisedButton(
                    child: Text("test native session"),
                    onPressed: () async {
                      String res = await HybridWebviewFlutter.testSession(_URL);
                      setState(() {
                        cookieResponse = res;
                      });
                    },
                  ),
                  Text(cookieResponse),
                  RaisedButton(
                    child: Text("validate flutter session"),
                    onPressed: validateCookie,
                  ),
                  Text(validateResponse),
                  RaisedButton(
                    child: Text("set cookie"),
                    onPressed: () async {
                      await HybridWebviewFlutter.setCookie(
                          domain: _HOST,
                          name: "my_save",
                          value: "vvvvvvv",
                          exp: 666666);
                    },
                  ),
                  RaisedButton(
                    child: Text("get cookie"),
                    onPressed: () async {
                      List res = await HybridWebviewFlutter.getCookie(_URL);
                      print(res);
                    },
                  ),
                ],
              ))),
    );
  }

  validateCookie() async {
    final url = _URL;
    try {
      var dio = Dio();
      // var cookieJar = CookieJar();
      // dio.interceptors.add(CookieManager(cookieJar));
      // // Print cookies
      // print(cookieJar.loadForRequest(Uri.parse(url)));
      dio.interceptors.add(HybridCookieManager());
      Response response = await dio.get(url);
      print(response.headers);
      setState(() {
        validateResponse = response.data.toString();
      });
    } catch (exception) {
      setState(() {
        validateResponse = 'error';
      });
    }
  }
}
