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

  @override
  void initState() {
    super.initState();
    webView = HybridWebview(url: 'https://m.baidu.com');
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
            child: Center(
              child: Container(
                width: 200,
                height: 400,
                child: webView,
              ),
            )),
      ),
    );
  }
}
