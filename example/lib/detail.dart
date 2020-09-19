import 'package:flutter/material.dart';
import 'package:hybrid_webview_flutter/src/hybrid_webview.dart';

class Detail extends StatefulWidget {
  String url;

  Detail({
    @required this.url,
  });

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  HybridWebview webView;

  List<IconButton> actions = [];

  @override
  void initState() {
    super.initState();
    webView = new HybridWebview(
        url: '${widget.url}?t=${new DateTime.now().millisecondsSinceEpoch}',
        bridgeListener: this.bridgeListener);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example detail'),
              actions: actions,
            ),
            body: Container(
              child: webView,
            )));
  }

  Future<dynamic> bridgeListener(String method, dynamic content) async {
    if (method == 'setRightBarItems') {
      List<Map> itemsMap = new List<Map>.from(content);
      List<IconButton> items = [];
      itemsMap.forEach((v) {
        String iconType = v['icon'];
        IconData iconData;
        switch (iconType) {
          case 'list':
            iconData = Icons.list;
            break;
          case 'scanner':
            iconData = Icons.scanner;
            break;
          default:
            iconData = Icons.help;
            break;
        }
        final item = new IconButton(
            icon: new Icon(iconData),
            onPressed: () async {
              final results =
                  await webView.invokeMethod('barItemCallback', iconType);
              print(results);
            });
        items.add(item);
      });
      setState(() {
        actions = items;
      });
    }
    return null;
  }
}
