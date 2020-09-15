import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hybrid_webview_flutter/hybrid_webview_flutter.dart';
import 'package:hybrid_webview_flutter/src/hybrid_webview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HybridWebview webView;
  final GlobalKey<HybridWebviewState> _globalKey = GlobalKey();

  String jsResult = '';
  String jsCallback = '';

  @override
  void initState() {
    super.initState();
    webView = new HybridWebview(
        key: _globalKey,
        url:
            'https://calcbit.com/resource/flutter/hybrid_webview_flutter/fe-file/index.html',
        callback: (String method, dynamic content) async {
          if (method == 'exchangeHeight') {
            setState(() {
              jsResult = 'webview clientHeight: $content';
            });
            return [context.size.height];
          }
          return null;
        });
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
                      List results = await _globalKey.currentState.channel
                          .invokeMethod(
                              '__flutterCallJs', ['getUserAgent', 'flutter']);
                      setState(() {
                        jsCallback = results.toString();
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
                ],
              ))),
    );
  }
}
