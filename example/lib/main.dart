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

  String jsValue = '';
  String jaCallback = '';

  @override
  void initState() {
    super.initState();
    webView = new HybridWebview(
        key: _globalKey,
        url:
            'https://calcbit.com/resource/flutter/hybrid_webview_flutter/fe-file/index.html',
        callback: (String method, dynamic content) {
          if (method == 'jsCallFlutter') {
            setState(() {
              jsValue = content;
            });
            _globalKey.currentState.channel
                .invokeMethod('flutterCallback', 'I callback from Flutter');
          }
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
                  Text(jsValue),
                  RaisedButton(
                    child: Text("call js"),
                    onPressed: () async {
                      String fromJS = await _globalKey.currentState.channel
                          .invokeMethod('flutterCallJs', [
                        'I from Flutter: ${new DateTime.now().millisecondsSinceEpoch}'
                      ]);
                      setState(() {
                        jaCallback = fromJS;
                      });
                    },
                  ),
                  Center(
                    child: Container(
                      width: 200,
                      height: 400,
                      child: webView,
                    ),
                  )
                ],
              ))),
    );
  }
}
