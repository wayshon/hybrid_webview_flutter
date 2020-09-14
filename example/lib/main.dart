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
        // url: 'https://m.baidu.com',
        url:
            'https://calcbit.com/resource/flutter/hybrid_webview_flutter/fe-file/index.html',
        callback: (String method, dynamic content) async {
          if (method == 'jsCallFlutter') {
            final obj = content[2];
            final arr = content[3];
            print('=============== ${obj}');
            print('=============== ${obj is Map}');
            print('=============== ${arr is List}');
            setState(() {
              jsResult = content.toString();
            });
            return ['I callback from Flutter', true, 666];
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
                          .invokeMethod('flutterCallJs', [
                        'flutter: ${new DateTime.now().millisecondsSinceEpoch}',
                        'from Flutter'
                      ]);
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
