import 'package:flutter/material.dart';
import 'package:hybrid_webview_flutter/src/hybrid_webview.dart';

class Detail extends StatefulWidget {
  HybridWebview webView;

  Detail({
    @required this.webView,
  });

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Container(
        color: Colors.grey,
        child: widget.webView,
      ),
    ));
  }
}
